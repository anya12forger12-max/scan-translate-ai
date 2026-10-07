import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the Firestore composite indexes declared in `firestore.indexes.json`
/// against the query shapes the datasources can actually build.
///
/// A missing composite index is not a compile error, not an analyzer finding and
/// not a unit-test failure: the query simply fails at runtime with
/// "The query requires an index". That is a total outage of the History screen
/// which no amount of green local testing can see, so the requirement is
/// *derived from the source* here rather than transcribed by hand — a new
/// `where`/`orderBy` combination in a datasource fails this file instead of
/// failing in production.
class _QueryShape {
  _QueryShape(this.collection, this.wheres, this.orders);

  final String collection;
  final List<String> wheres;
  final List<(String, String)> orders;

  /// Equality fields first (ascending), then the ordering fields in order.
  ///
  /// Firestore does not require the trailing implicit `__name__` segment to be
  /// written out, so it is deliberately absent from both sides of this
  /// comparison.
  List<String> get indexFields => [
    ...wheres.map((f) => '$f ASCENDING'),
    for (final (field, direction) in orders) '$field $direction',
  ];

  @override
  String toString() => '$collection ${indexFields.join(', ')}';
}

void main() {
  late Map<String, List<List<String>>> declared;

  setUpAll(() {
    declared = _declaredIndexes();
  });

  test('detector sees the real scan_history query shapes', () {
    final shapes = _scanHistoryShapes();
    expect(
      shapes,
      isNotEmpty,
      reason:
          'no scan_history query shapes were detected — if this is now '
          'zero the detector is broken, not the indexes',
    );
    expect(
      shapes.any((s) => s.orders.isNotEmpty),
      isTrue,
      reason:
          'no ordered scan_history query was detected, so the coverage '
          'check below would pass vacuously',
    );
  });

  test('every scan_history query shape has a declared composite index', () {
    final shapes = _scanHistoryShapes();

    for (final shape in shapes) {
      if (shape.orders.isEmpty) {
        // Single-equality queries are served by Firestore's automatic
        // single-field indexes and need no composite declaration.
        continue;
      }
      final matches = declared[shape.collection] ?? [];
      expect(
        matches.any((m) => m.join('|') == shape.indexFields.join('|')),
        isTrue,
        reason:
            'no declared index covers the query shape [$shape]. Add it to '
            'firestore.indexes.json, or the query fails at runtime with '
            '"The query requires an index".',
      );
    }
  });

  test('declared indexes are not orphans of any real query shape', () {
    final required = _scanHistoryShapes()
        .where((s) => s.orders.isNotEmpty)
        .map((s) => s.indexFields.join('|'))
        .toSet();

    for (final entry in declared.entries) {
      for (final fields in entry.value) {
        expect(
          required,
          contains(fields.join('|')),
          reason:
              'declared index [$fields] on ${entry.key} matches no query '
              'shape in the datasources',
        );
      }
    }
  });

  test('each declared index lists its equality fields ascending before the '
      'ordering field', () {
    for (final entry in declared.entries) {
      for (final fields in entry.value) {
        expect(fields.length, greaterThanOrEqualTo(2));
        for (final f in fields.take(fields.length - 1)) {
          expect(f, endsWith('ASCENDING'));
        }
        expect(fields.last, isNot(endsWith('ASCENDING')));
      }
    }
  });
}

/// Reads `firestore.indexes.json` into {collection: [ [field, ...], ... ]}.
Map<String, List<List<String>>> _declaredIndexes() {
  final file = File('firestore.indexes.json');
  expect(
    file.existsSync(),
    isTrue,
    reason: 'firestore.indexes.json is missing',
  );

  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final result = <String, List<List<String>>>{};
  for (final raw in (decoded['indexes'] as List<dynamic>? ?? const [])) {
    final index = raw as Map<String, dynamic>;
    final collection = index['collectionGroup'] as String?;
    final fields = [
      for (final f in (index['fields'] as List<dynamic>? ?? const []))
        '${(f as Map<String, dynamic>)['fieldPath']} '
            '${(f['order'] as String?) ?? 'ASCENDING'}',
    ];
    result.putIfAbsent(collection ?? '', () => <List<String>>[]).add(fields);
  }
  return result;
}

/// Extracts the collection/where/orderBy shapes the datasources build,
/// resolving `FirebaseConstants.<name>` references to their literal values.
List<_QueryShape> _scanHistoryShapes() {
  final constants = _firebaseConstants();
  final shapes = <_QueryShape>[];

  for (final file in Directory(
    'lib',
  ).listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    if (!file.path.split(Platform.pathSeparator).contains('datasources')) {
      continue;
    }

    var source = file.readAsStringSync();
    for (final entry in constants.entries) {
      source = source.replaceAll(
        'FirebaseConstants.${entry.key}',
        "'${entry.value}'",
      );
    }

    // A shape spans one chained expression; a bare `.where(...)` on its own
    // line continues the shape built above it (that is how the optional
    // `scanType` / `isFavorite` filters are written).
    _QueryShape? current;
    for (final line in source.split('\n')) {
      if (RegExp(r'\.collection\(').hasMatch(line)) {
        final match = RegExp(r"\.collection\('([^']+)'\)").firstMatch(line);
        if (match != null) {
          current = _QueryShape(match.group(1)!, [], []);
          shapes.add(current);
        }
        continue;
      }
      if (current == null) continue;

      for (final m in RegExp(r"\.where\('([^']+)'").allMatches(line)) {
        current.wheres.add(m.group(1)!);
      }
      for (final m in RegExp(
        r"\.orderBy\('([^']+)',\s*descending:\s*(true|false)",
      ).allMatches(line)) {
        current.orders.add((
          m.group(1)!,
          m.group(2) == 'true' ? 'DESCENDING' : 'ASCENDING',
        ));
      }
      if (line.trim() == '}') {
        current = null;
      }
    }
  }
  return shapes;
}

Map<String, String> _firebaseConstants() {
  final file = File('lib/core/constants/firebase_constants.dart');
  if (!file.existsSync()) return {};
  final result = <String, String>{};
  for (final m in RegExp(
    r"static const(?:\s+\w+)?\s+(\w+)\s*=\s*'([^']+)'",
  ).allMatches(file.readAsStringSync())) {
    result[m.group(1)!] = m.group(2)!;
  }
  return result;
}
