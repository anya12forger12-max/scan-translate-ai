import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_translate_ai/core/errors/exceptions.dart';
import 'package:scan_translate_ai/core/errors/failures.dart';
import 'package:scan_translate_ai/features/history/data/datasources/history_datasource.dart';
import 'package:scan_translate_ai/features/history/data/repositories/history_repository_impl.dart';
import 'package:scan_translate_ai/features/history/domain/entities/history_item.dart';
import 'package:scan_translate_ai/features/history/presentation/providers/history_provider.dart';

class _FakeHistoryRemoteDataSource implements HistoryRemoteDataSource {
  _FakeHistoryRemoteDataSource(this.docs);

  List<Map<String, dynamic>> docs;
  AppException? failWith;

  String? lastType;
  int? lastLimit;
  int getHistoryCalls = 0;
  String? toggledId;
  bool? toggledFavorite;
  String? deletedId;
  int clearHistoryCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> getHistory({
    int? limit,
    String? type,
  }) async {
    getHistoryCalls++;
    lastType = type;
    lastLimit = limit;
    if (failWith != null) throw failWith!;
    final all = docs;
    if (type == null) return all;
    return all.where((d) => d['scanType'] == type).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getFavorites() async {
    if (failWith != null) throw failWith!;
    return docs.where((d) => d['isFavorite'] == true).toList();
  }

  @override
  Future<void> toggleFavorite(String id, bool favorite) async {
    if (failWith != null) throw failWith!;
    toggledId = id;
    toggledFavorite = favorite;
  }

  @override
  Future<void> deleteItem(String id) async {
    if (failWith != null) throw failWith!;
    deletedId = id;
  }

  @override
  Future<void> clearHistory() async {
    if (failWith != null) throw failWith!;
    clearHistoryCalls++;
  }

  @override
  Future<List<Map<String, dynamic>>> searchHistory(String query) async {
    return getHistory();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw StateError('Unexpected datasource call: ${invocation.memberName}');
  }
}

HistoryRepositoryImpl _repositoryFor(_FakeHistoryRemoteDataSource fake) =>
    HistoryRepositoryImpl(remoteDataSource: fake);

Map<String, dynamic> _doc({
  String id = 'scan-1',
  String scanType = 'qr',
  String formatType = 'qrCode',
  String? rawValue = 'https://example.test/a',
  Object? scannedAt,
  bool isFavorite = false,
  bool includeOptionals = true,
}) {
  final doc = <String, dynamic>{'id': id, 'scanType': scanType};
  if (includeOptionals) {
    doc['formatType'] = formatType;
    doc['rawValue'] = rawValue;
    doc['displayValue'] = 'Example A';
    doc['scannedAt'] = scannedAt ?? Timestamp.fromDate(DateTime(2026, 1, 2));
    doc['isFavorite'] = isFavorite;
  }
  return doc;
}

void main() {
  group('HistoryRepositoryImpl maps Firestore documents onto HistoryItem', () {
    test('maps every populated field, including Timestamp and favorite', () async {
      final fake = _FakeHistoryRemoteDataSource([
        _doc(isFavorite: true, scannedAt: Timestamp.fromDate(DateTime(2026, 3, 4))),
      ]);
      final result = await _repositoryFor(fake).getHistory();

      expect(result.isRight(), isTrue);
      final item = result.getOrElse(() => const <HistoryItem>[]).single;
      expect(item.id, 'scan-1');
      expect(item.scanType, 'qr');
      expect(item.formatType, 'qrCode');
      expect(item.rawValue, 'https://example.test/a');
      expect(item.displayValue, 'Example A');
      expect(item.scannedAt, DateTime(2026, 3, 4));
      expect(item.isFavorite, isTrue);
    });

    test('defaults every omitted field instead of throwing or nulling', () async {
      final fake = _FakeHistoryRemoteDataSource([
        _doc(includeOptionals: false),
      ]);
      final result = await _repositoryFor(fake).getHistory();

      final item = result.getOrElse(() => const <HistoryItem>[]).single;
      expect(item.id, 'scan-1');
      expect(item.formatType, 'unknown');
      expect(item.rawValue, isEmpty);
      expect(item.displayValue, isNull);
      expect(item.isFavorite, isFalse);
    });

    test('defaults an explicit null rawValue to empty, not a null deref', () async {
      final fake = _FakeHistoryRemoteDataSource([_doc(rawValue: null)]);
      final result = await _repositoryFor(fake).getHistory();

      final item = result.getOrElse(() => const <HistoryItem>[]).single;
      expect(item.rawValue, isEmpty);
    });

    test('defaults absent id and scanType keys, not just null ones', () async {
      final missing = <String, dynamic>{
        'formatType': 'qrCode',
        'rawValue': 'https://example.test/a',
        'scannedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
        'isFavorite': false,
      };
      final fake = _FakeHistoryRemoteDataSource([missing]);
      final result = await _repositoryFor(fake).getHistory();

      final item = result.getOrElse(() => const <HistoryItem>[]).single;
      expect(item.id, isEmpty);
      expect(item.scanType, 'unknown');
    });

    test('defaults a null id and scanType the same as absent ones', () async {
      final nulls = <String, dynamic>{'id': null, 'scanType': null};
      final fake = _FakeHistoryRemoteDataSource([nulls]);
      final result = await _repositoryFor(fake).getHistory();

      final item = result.getOrElse(() => const <HistoryItem>[]).single;
      expect(item.id, isEmpty);
      expect(item.scanType, 'unknown');
    });

    test('falls back to the current time when scannedAt is not a Timestamp', () async {
      final fake = _FakeHistoryRemoteDataSource([
        _doc(scannedAt: '2026-01-02T00:00:00Z'),
      ]);
      final before = DateTime.now();
      final result = await _repositoryFor(fake).getHistory();

      final item = result.getOrElse(() => const <HistoryItem>[]).single;
      expect(item.scannedAt.isAfter(before.subtract(const Duration(seconds: 5))),
          isTrue);
    });

    test('forwards the type and limit arguments to the datasource', () async {
      final fake = _FakeHistoryRemoteDataSource([_doc()]);
      await _repositoryFor(fake).getHistory(limit: 25, type: 'barcode');

      expect(fake.lastType, 'barcode');
      expect(fake.lastLimit, 25);
    });

    test('returns a Left failure when the datasource throws', () async {
      final fake = _FakeHistoryRemoteDataSource([_doc()])
        ..failWith = const ServerException('boom');
      final result = await _repositoryFor(fake).getHistory();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('expected a Left failure'),
      );
    });

    test('propagates an auth failure when the datasource throws one', () async {
      final fake = _FakeHistoryRemoteDataSource([_doc()])
        ..failWith = const AuthException('User not authenticated.');
      final result = await _repositoryFor(fake).getHistory();

      expect(result.fold((f) => f, (_) => null), isA<AuthFailure>());
    });

    test('maps only favorites returned by getFavorites', () async {
      final fake = _FakeHistoryRemoteDataSource([
        _doc(id: 'fav', isFavorite: true),
        _doc(id: 'plain', isFavorite: false),
      ]);
      final result = await _repositoryFor(fake).getFavorites();

      final items = result.getOrElse(() => const <HistoryItem>[]);
      expect(items.map((i) => i.id), ['fav']);
    });

    test('delegates the favorite write to the datasource', () async {
      final fake = _FakeHistoryRemoteDataSource([_doc()]);
      final result = await _repositoryFor(fake).toggleFavorite('scan-1', true);

      expect(result.isRight(), isTrue);
      expect(fake.toggledId, 'scan-1');
      expect(fake.toggledFavorite, isTrue);
    });

    test('reports a datasource failure for the favorite write as Left', () async {
      final fake = _FakeHistoryRemoteDataSource([_doc()])
        ..failWith = const ServerException('nope');
      final result = await _repositoryFor(fake).toggleFavorite('scan-1', true);

      expect(result.isLeft(), isTrue);
      expect(fake.toggledId, isNull);
    });
  });

  group('datasource to notifier chain', () {
    test('filters favorites and type over mapped documents', () async {
      final fake = _FakeHistoryRemoteDataSource([
        _doc(id: 'a', scanType: 'qr', isFavorite: true),
        _doc(id: 'b', scanType: 'barcode', isFavorite: false),
        _doc(id: 'c', scanType: 'barcode', isFavorite: true),
      ]);
      final notifier = HistoryNotifier(_repositoryFor(fake));

      await notifier.loadHistory();
      expect(notifier.state.status, HistoryStatus.success);
      expect(notifier.state.items.length, 3);
      expect(notifier.state.filteredItems.length, 3);

      notifier.setFavoritesOnly(true);
      expect(
        notifier.state.filteredItems.map((i) => i.id).toSet(),
        {'a', 'c'},
      );

      notifier.setTypeFilter('barcode');
      expect(notifier.state.filteredItems.map((i) => i.id), ['c']);

      notifier.setTypeFilter(null);
      expect(notifier.state.typeFilter, isNull);
      expect(notifier.state.filteredItems.map((i) => i.id).toSet(), {'a', 'c'});
    });

    test('surfaces the repository failure in the notifier state', () async {
      final fake = _FakeHistoryRemoteDataSource([_doc()])
        ..failWith = const ServerException('boom');
      final notifier = HistoryNotifier(_repositoryFor(fake));

      await notifier.loadHistory();
      expect(notifier.state.status, HistoryStatus.error);
      expect(notifier.state.errorMessage, isNotNull);
    });

    test('keeps search filtering applied over mapped raw values', () async {
      final fake = _FakeHistoryRemoteDataSource([
        _doc(id: 'a', rawValue: 'https://example.test/alpha'),
        _doc(id: 'b', rawValue: 'WIFI:SomethingElse'),
      ]);
      final notifier = HistoryNotifier(_repositoryFor(fake));

      await notifier.loadHistory();
      notifier.setSearchQuery('example.test');
      expect(notifier.state.filteredItems.map((i) => i.id), ['a']);
    });
  });
}
