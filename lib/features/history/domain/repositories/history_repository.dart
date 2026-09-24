import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/history_item.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryItem>>> getHistory({int limit = 50});
  Future<Either<Failure, void>> addItem(HistoryItem item);
  Future<Either<Failure, void>> deleteItem(String id);
  Future<Either<Failure, void>> clearHistory();
}
