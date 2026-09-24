import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';

class ScannerRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final Uuid uuid;
  ScannerRemoteDataSource({required this.firestore, required this.firebaseAuth, required this.uuid});
  String get uid => firebaseAuth.currentUser?.uid ?? '';

  Future<Map<String, dynamic>> saveScanResult(Map<String, dynamic> data) async {
    if (uid.isEmpty) throw const AuthException('Not authenticated.');
    final id = uuid.v4(); data['id'] = id; data['userId'] = uid; data['scannedAt'] = FieldValue.serverTimestamp();
    await firestore.collection(FirebaseConstants.scanHistoryCollection).doc(id).set(data);
    data['scannedAt'] = DateTime.now().toIso8601String();
    return data;
  }

  Future<List<Map<String, dynamic>>> getScanHistory({int? limit, String? type}) async {
    if (uid.isEmpty) throw const AuthException('Not authenticated.');
    var q = firestore.collection(FirebaseConstants.scanHistoryCollection).where('userId', isEqualTo: uid).orderBy('scannedAt', descending: true);
    if (type != null) q = q.where('scanType', isEqualTo: type);
    if (limit != null) q = q.limit(limit);
    return (await q.get()).docs.map((d) { final m = d.data(); m['id'] = d.id; return m; }).toList();
  }

  Future<void> deleteScanResult(String id) async {
    if (uid.isEmpty) throw const AuthException('Not authenticated.');
    await firestore.collection(FirebaseConstants.scanHistoryCollection).doc(id).delete();
  }

  Future<void> toggleFavorite(String id, bool fav) async {
    if (uid.isEmpty) throw const AuthException('Not authenticated.');
    await firestore.collection(FirebaseConstants.scanHistoryCollection).doc(id).update({'isFavorite': fav});
  }

  Future<void> clearHistory() async {
    if (uid.isEmpty) throw const AuthException('Not authenticated.');
    final snaps = await firestore.collection(FirebaseConstants.scanHistoryCollection).where('userId', isEqualTo: uid).get();
    final batch = firestore.batch();
    for (final d in snaps.docs) batch.delete(d.reference);
    await batch.commit();
  }
}
