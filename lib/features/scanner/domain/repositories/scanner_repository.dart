import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scan_result.dart';

abstract class ScannerRepository {
  Future<Either<Failure, ScanResult>> processScanResult({
    required String rawValue,
    required String format,
  });

  Future<Either<Failure, void>> saveScanResult(ScanResult result);

  Future<Either<Failure, List<ScanResult>>> getScanHistory({
    int? limit,
    String? type,
  });

  Future<Either<Failure, void>> deleteScanResult(String id);

  Future<Either<Failure, void>> toggleFavorite(String id, bool favorite);

  Future<Either<Failure, void>> clearHistory();
}
