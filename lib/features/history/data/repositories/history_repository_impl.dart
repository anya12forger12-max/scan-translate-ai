import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource ds;
  HistoryRepositoryImpl({required this.ds});

  @override Future<Either<Failure, List<HistoryItem>>> getHistory({int limit = 50}) async {
    try { return Right(await ds.getHistory(limit: limit)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> addItem(HistoryItem item) async {
    try { return Right(await ds.addItem(item)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> deleteItem(String id) async {
    try { return Right(await ds.deleteItem(id)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> clearHistory() async {
    try { return Right(await ds.clearHistory()); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
}
