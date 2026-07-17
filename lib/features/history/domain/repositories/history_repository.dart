import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/history_item.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryItem>>> getHistory({
    int? limit,
    String? type,
  });

  Future<Either<Failure, List<HistoryItem>>> getFavorites();

  Future<Either<Failure, void>> deleteItem(String id);

  Future<Either<Failure, void>> toggleFavorite(String id, bool favorite);

  Future<Either<Failure, void>> clearHistory();

  Future<Either<Failure<List<HistoryItem>>, List<HistoryItem>>> searchHistory(
      String query);
}
