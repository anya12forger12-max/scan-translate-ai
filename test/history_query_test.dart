import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scan_translate_ai/features/history/data/datasources/history_datasource.dart';
import 'package:scan_translate_ai/features/history/data/repositories/history_repository_impl.dart';

class _FakeHistoryDatasource implements HistoryRemoteDataSource {
  List<Map<String, dynamic>> _records = []; // ignore: prefer_final_fields
  String _userId; // ignore: prefer_final_fields

  _FakeHistoryDatasource(this._userId, {List<Map<String, dynamic>> records = const []})
      : _records = [...records];

  @override
  FirebaseFirestore get firestore => throw UnimplementedError();
  @override
  FirebaseAuth get firebaseAuth => throw UnimplementedError();
  @override
  String get userId => _userId;

  @override
  Future<List<Map<String, dynamic>>> getHistory({int? limit, String? type}) async {
    var filtered = _records.where((r) {
      final userIdMatch = r['userId'] == _userId;
      final typeMatch = type == null || r['scanType'] == type;
      return userIdMatch && typeMatch;
    }).toList();
    if (limit != null && limit < filtered.length) {
      filtered = filtered.take(limit).toList();
    }
    return filtered;
  }

  @override
  Future<List<Map<String, dynamic>>> getFavorites() async => [];
  @override
  Future<void> deleteItem(String id) async {}
  @override
  Future<void> toggleFavorite(String id, bool fav) async {}
  @override
  Future<void> clearHistory() async {}
  @override
  Future<List<Map<String, dynamic>>> searchHistory(String q) async => [];
}

void main() {
  group('HistoryRepository query isolation', () {
    test('getHistory returns only records for the authenticated user', () async {
      final repo = HistoryRepositoryImpl(
        remoteDataSource: _FakeHistoryDatasource('userA', records: [
          {'userId': 'userA', 'scanType': 'qr'},
          {'userId': 'userB', 'scanType': 'barcode'},
        ]),
      );
      final result = await repo.getHistory();
      final items = result.fold((l) => [], (r) => r);
      expect(items.length, 1);
      expect(items.first.scanType, 'qr');
    });

    test('getHistory applies type filter', () async {
      final repo = HistoryRepositoryImpl(
        remoteDataSource: _FakeHistoryDatasource('userA', records: [
          {'userId': 'userA', 'scanType': 'qr'},
          {'userId': 'userA', 'scanType': 'barcode'},
        ]),
      );
      final result = await repo.getHistory(type: 'qr');
      final items = result.fold((l) => [], (r) => r);
      expect(items.length, 1);
      expect(items.first.scanType, 'qr');
    });

    test('getHistory applies limit', () async {
      final repo = HistoryRepositoryImpl(
        remoteDataSource: _FakeHistoryDatasource('userA', records: [
          {'userId': 'userA', 'scanType': 'qr'},
          {'userId': 'userA', 'scanType': 'qr'},
          {'userId': 'userA', 'scanType': 'qr'},
        ]),
      );
      final result = await repo.getHistory(limit: 2);
      final items = result.fold((l) => [], (r) => r);
      expect(items.length, 2);
    });

    test('getHistory returns empty when userId does not match any record', () async {
      final repo = HistoryRepositoryImpl(
        remoteDataSource: _FakeHistoryDatasource('userZ', records: [
          {'userId': 'userA', 'scanType': 'qr'},
        ]),
      );
      final result = await repo.getHistory();
      final items = result.fold((l) => [], (r) => r);
      expect(items.length, 0);
    });
  });
}
