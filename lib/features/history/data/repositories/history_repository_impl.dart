import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HistoryItem>>> getHistory({
    int? limit,
    String? type,
  }) async {
    try {
      final data = await remoteDataSource.getHistory(limit: limit, type: type);
      return Right(data.map((json) => _mapToItem(json)).toList());
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<HistoryItem>>> getFavorites() async {
    try {
      final data = await remoteDataSource.getFavorites();
      return Right(data.map((json) => _mapToItem(json)).toList());
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      await remoteDataSource.deleteItem(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(
      String id, bool favorite) async {
    try {
      await remoteDataSource.toggleFavorite(id, favorite);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await remoteDataSource.clearHistory();
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<HistoryItem>>> searchHistory(
      String query) async {
    try {
      final data = await remoteDataSource.searchHistory(query);
      return Right(data.map((json) => _mapToItem(json)).toList());
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  HistoryItem _mapToItem(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String? ?? '',
      scanType: json['scanType'] as String? ?? 'unknown',
      formatType: json['formatType'] as String? ?? 'unknown',
      rawValue: json['rawValue'] as String? ?? '',
      displayValue: json['displayValue'] as String?,
      scannedAt: (json['scannedAt'] is Timestamp)
          ? (json['scannedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
