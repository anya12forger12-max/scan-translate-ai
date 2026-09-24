import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/history_item.dart';

class HistoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  HistoryRemoteDataSource({required this.firestore, required this.firebaseAuth});
  String get _uid => firebaseAuth.currentUser?.uid ?? '';

  Future<List<HistoryItem>> getHistory({int limit = 50}) async {
    if (_uid.isEmpty) throw const AuthException('Not authenticated.');
    final q = await firestore
      .collection('users').doc(_uid).collection('history')
      .orderBy('timestamp', descending: true).limit(limit).get();
    return q.docs.map((d) => _fromDoc(d.id, d.data())).toList();
  }

  Future<void> addItem(HistoryItem item) async {
    if (_uid.isEmpty) throw const AuthException('Not authenticated.');
    await firestore
      .collection('users').doc(_uid).collection('history')
      .doc(item.id).set(_toDoc(item));
  }

  Future<void> deleteItem(String id) async {
    if (_uid.isEmpty) throw const AuthException('Not authenticated.');
    await firestore
      .collection('users').doc(_uid).collection('history').doc(id).delete();
  }

  Future<void> clearHistory() async {
    if (_uid.isEmpty) throw const AuthException('Not authenticated.');
    final snap = await firestore
      .collection('users').doc(_uid).collection('history')
      .limit(500).get();
    final batch = firestore.batch();
    for (final d in snap.docs) batch.delete(d.reference);
    await batch.commit();
  }

  HistoryItem _fromDoc(String id, Map<String, dynamic> d) => HistoryItem(
    id: id,
    type: HistoryItemType.values.firstWhere((e) => e.name == d['type'], orElse: () => HistoryItemType.scan),
    title: d['title'] as String? ?? '',
    subtitle: d['subtitle'] as String? ?? '',
    details: d['details'] as String?,
    timestamp: (d['timestamp'] as Timestamp).toDate(),
    metadata: d['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> _toDoc(HistoryItem item) => {
    'type': item.type.name,
    'title': item.title,
    'subtitle': item.subtitle,
    'details': item.details,
    'timestamp': Timestamp.fromDate(item.timestamp),
    if (item.metadata != null) 'metadata': item.metadata,
  };
}
