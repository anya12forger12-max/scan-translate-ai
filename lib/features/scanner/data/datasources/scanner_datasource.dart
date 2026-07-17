import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:uuid/uuid.dart';

class ScannerRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final Uuid uuid;

  ScannerRemoteDataSource({
    required this.firestore,
    required this.firebaseAuth,
    required this.uuid,
  });

  String get userId => firebaseAuth.currentUser?.uid ?? '';

  Future<Map<String, dynamic>> saveScanResult(Map<String, dynamic> data) async {
    try {
      if (userId.isEmpty) throw const AuthException('User not authenticated.');

      final id = uuid.v4();
      data['id'] = id;
      data['userId'] = userId;
      data['scannedAt'] = FieldValue.serverTimestamp();

      await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .doc(id)
          .set(data);

      data['scannedAt'] = DateTime.now().toIso8601String();
      return data;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to save scan result.');
    }
  }

  Future<List<Map<String, dynamic>>> getScanHistory({
    int? limit,
    String? type,
  }) async {
    try {
      if (userId.isEmpty) throw const AuthException('User not authenticated.');

      var query = firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('scannedAt', descending: true);

      if (type != null) {
        query = query.where('scanType', isEqualTo: type);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch scan history.');
    }
  }

  Future<void> deleteScanResult(String id) async {
    try {
      if (userId.isEmpty) throw const AuthException('User not authenticated.');

      await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .doc(id)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete scan result.');
    }
  }

  Future<void> toggleFavorite(String id, bool favorite) async {
    try {
      if (userId.isEmpty) throw const AuthException('User not authenticated.');

      await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .doc(id)
          .update({'isFavorite': favorite});
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update favorite.');
    }
  }

  Future<void> clearHistory() async {
    try {
      if (userId.isEmpty) throw const AuthException('User not authenticated.');

      final snapshot = await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to clear history.');
    }
  }
}
