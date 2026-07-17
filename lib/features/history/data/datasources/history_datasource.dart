import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';

class HistoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  HistoryRemoteDataSource({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get userId => firebaseAuth.currentUser?.uid ?? '';

  Future<List<Map<String, dynamic>>> getHistory({
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
      throw ServerException(e.message ?? 'Failed to fetch history.');
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      if (userId.isEmpty) throw const AuthException('User not authenticated.');

      final snapshot = await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .where('userId', isEqualTo: userId)
          .where('isFavorite', isEqualTo: true)
          .orderBy('scannedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch favorites.');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      if (userId.isEmpty) throw const AuthException('User not authenticated.');

      final doc = await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .doc(id)
          .get();

      if (!doc.exists) return;
      if (doc.data()?['userId'] != userId) {
        throw const AuthException('Cannot delete another user\'s data.');
      }

      await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .doc(id)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete item.');
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

  Future<List<Map<String, dynamic>>> searchHistory(String query) async {
    try {
      if (userId.isEmpty) throw const AuthException('User not authenticated.');

      final snapshot = await firestore
          .collection(FirebaseConstants.scanHistoryCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('scannedAt', descending: true)
          .get();

      final results = snapshot.docs.where((doc) {
        final data = doc.data();
        final rawValue = data['rawValue'] as String? ?? '';
        return rawValue.toLowerCase().contains(query.toLowerCase());
      }).toList();

      return results.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to search history.');
    }
  }
}
