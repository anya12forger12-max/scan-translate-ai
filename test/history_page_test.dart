import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_translate_ai/core/errors/failures.dart';
import 'package:scan_translate_ai/features/history/domain/entities/history_item.dart';
import 'package:scan_translate_ai/features/history/domain/repositories/history_repository.dart';
import 'package:scan_translate_ai/features/history/presentation/pages/history_page.dart';
import 'package:scan_translate_ai/features/history/presentation/providers/history_provider.dart';

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository(this._items);

  List<HistoryItem> _items;
  Failure? failWith;
  int getHistoryCalls = 0;

  void replaceAll(List<HistoryItem> items) => _items = items;

  @override
  Future<Either<Failure, List<HistoryItem>>> getHistory({
    int? limit,
    String? type,
  }) async {
    getHistoryCalls++;
    if (failWith != null) return Left(failWith!);
    return Right(_items);
  }

  @override
  Future<Either<Failure, List<HistoryItem>>> getFavorites() async {
    return Right(_items.where((item) => item.isFavorite).toList());
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    _items = _items.where((item) => item.id != id).toList();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String id, bool favorite) async {
    _items = _items
        .map(
          (item) => item.id == id ? item.copyWith(isFavorite: favorite) : item,
        )
        .toList();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    _items = [];
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<HistoryItem>>> searchHistory(String query) async {
    return Right(_items);
  }
}

HistoryItem _item({
  required String id,
  String scanType = 'qr',
  String formatType = 'qrCode',
  String rawValue = 'value',
  bool isFavorite = false,
}) {
  return HistoryItem(
    id: id,
    scanType: scanType,
    formatType: formatType,
    rawValue: rawValue,
    scannedAt: DateTime.utc(2026, 1, 1),
    isFavorite: isFavorite,
  );
}

FilterChip _chip(WidgetTester tester, String label) {
  return tester.widget<FilterChip>(
    find
        .ancestor(of: find.text(label), matching: find.byType(FilterChip))
        .first,
  );
}

Future<void> _pumpPage(WidgetTester tester, HistoryNotifier notifier) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [historyProvider.overrideWith((ref) => notifier)],
      child: const MaterialApp(home: HistoryPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final qrFavorite = _item(id: '1', rawValue: 'FAVORITE-QR', isFavorite: true);
  final qrPlain = _item(id: '2', rawValue: 'PLAIN-QR');
  final barcodePlain = _item(
    id: '3',
    scanType: 'barcode',
    formatType: 'ean13',
    rawValue: 'PLAIN-BARCODE',
  );

  group('HistoryNotifier.loadHistory', () {
    test('loads repository history and populates success state', () async {
      final repo = _FakeHistoryRepository([qrFavorite, qrPlain]);
      final notifier = HistoryNotifier(repo);

      expect(notifier.state.status, HistoryStatus.initial);

      await notifier.loadHistory();

      expect(repo.getHistoryCalls, 1);
      expect(notifier.state.status, HistoryStatus.success);
      expect(notifier.state.items, hasLength(2));
      expect(notifier.state.filteredItems, hasLength(2));
    });

    test('surfaces repository failures as an error state', () async {
      final repo = _FakeHistoryRepository([qrPlain])
        ..failWith = const ServerFailure('Firestore unavailable');

      final notifier = HistoryNotifier(repo);
      await notifier.loadHistory();

      expect(notifier.state.status, HistoryStatus.error);
      expect(notifier.state.errorMessage, 'Firestore unavailable');
    });

    test('keeps favoritesOnly active across a reload', () async {
      final repo = _FakeHistoryRepository([qrFavorite, qrPlain]);
      final notifier = HistoryNotifier(repo);

      await notifier.loadHistory();
      notifier.setFavoritesOnly(true);
      expect(notifier.state.filteredItems.map((i) => i.id), ['1']);

      repo.replaceAll([qrFavorite, qrPlain, barcodePlain]);
      await notifier.loadHistory();

      expect(notifier.state.favoritesOnly, isTrue);
      expect(notifier.state.filteredItems.map((i) => i.id), ['1']);
    });

    test('keeps favoritesOnly active after toggling a favorite', () async {
      final repo = _FakeHistoryRepository([qrFavorite, qrPlain]);
      final notifier = HistoryNotifier(repo);

      await notifier.loadHistory();
      notifier.setFavoritesOnly(true);
      notifier.toggleFavorite('2');

      expect(notifier.state.favoritesOnly, isTrue);
      expect(notifier.state.filteredItems.map((i) => i.id), ['1', '2']);
    });

    test('combines favoritesOnly with a type filter', () async {
      final repo = _FakeHistoryRepository([qrFavorite, qrPlain, barcodePlain]);
      final notifier = HistoryNotifier(repo);

      await notifier.loadHistory();
      notifier.setFavoritesOnly(true);
      notifier.setTypeFilter('barcode');

      expect(notifier.state.filteredItems, isEmpty);

      notifier.setTypeFilter('qr');
      expect(notifier.state.filteredItems.map((i) => i.id), ['1']);
    });

    test('clears a selected type filter when set to null', () async {
      final repo = _FakeHistoryRepository([qrFavorite, qrPlain, barcodePlain]);
      final notifier = HistoryNotifier(repo);

      await notifier.loadHistory();
      notifier.setTypeFilter('barcode');
      expect(notifier.state.typeFilter, 'barcode');
      expect(notifier.state.filteredItems, hasLength(1));

      notifier.setTypeFilter(null);

      expect(notifier.state.typeFilter, isNull);
      expect(notifier.state.filteredItems, hasLength(3));
    });
  });

  group('HistoryPage', () {
    testWidgets('loads persisted history on entry', (tester) async {
      final repo = _FakeHistoryRepository([qrFavorite, barcodePlain]);
      await _pumpPage(tester, HistoryNotifier(repo));

      expect(repo.getHistoryCalls, 1);
      expect(find.text('FAVORITE-QR'), findsOneWidget);
      expect(find.text('PLAIN-BARCODE'), findsOneWidget);
      expect(find.text('No Scan History Yet'), findsNothing);
    });

    testWidgets('shows a dedicated empty state when no history exists', (
      tester,
    ) async {
      await _pumpPage(tester, HistoryNotifier(_FakeHistoryRepository([])));

      expect(find.text('No Scan History Yet'), findsOneWidget);
    });

    testWidgets('Favorites chip filters the rendered list', (tester) async {
      final repo = _FakeHistoryRepository([qrFavorite, qrPlain, barcodePlain]);
      await _pumpPage(tester, HistoryNotifier(repo));

      expect(find.text('PLAIN-QR'), findsOneWidget);

      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('FAVORITE-QR'), findsOneWidget);
      expect(find.text('PLAIN-QR'), findsNothing);
      expect(find.text('PLAIN-BARCODE'), findsNothing);
    });

    testWidgets('Favorites chip shows a favorites-specific empty state', (
      tester,
    ) async {
      final repo = _FakeHistoryRepository([qrPlain]);
      await _pumpPage(tester, HistoryNotifier(repo));

      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('No Favorites Yet'), findsOneWidget);
      expect(find.text('No Scan History Yet'), findsNothing);
    });

    testWidgets('selecting All after a type filter restores every scan', (
      tester,
    ) async {
      final repo = _FakeHistoryRepository([qrFavorite, qrPlain, barcodePlain]);
      await _pumpPage(tester, HistoryNotifier(repo));

      await tester.tap(find.text('Barcode'));
      await tester.pumpAndSettle();
      expect(find.text('PLAIN-BARCODE'), findsOneWidget);
      expect(find.text('PLAIN-QR'), findsNothing);
      expect(_chip(tester, 'Barcode').selected, isTrue);
      expect(_chip(tester, 'All').selected, isFalse);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('PLAIN-QR'), findsOneWidget);
      expect(find.text('PLAIN-BARCODE'), findsOneWidget);
      expect(_chip(tester, 'All').selected, isTrue);
      expect(_chip(tester, 'Barcode').selected, isFalse);
    });

    testWidgets('retry after a load failure re-reads the repository', (
      tester,
    ) async {
      final repo = _FakeHistoryRepository([qrFavorite])
        ..failWith = const ServerFailure('Firestore unavailable');

      await _pumpPage(tester, HistoryNotifier(repo));

      expect(find.text('Firestore unavailable'), findsOneWidget);

      repo.failWith = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(repo.getHistoryCalls, 2);
      expect(find.text('FAVORITE-QR'), findsOneWidget);
      expect(find.text('Firestore unavailable'), findsNothing);
    });
  });
}
