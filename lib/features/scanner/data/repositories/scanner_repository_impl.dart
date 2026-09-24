import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/barcode_format.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_datasource.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerRemoteDataSource ds;
  final Uuid uuid;
  ScannerRepositoryImpl({required this.ds, required this.uuid});

  @override Future<Either<Failure, ScanResult>> processScanResult({required String rawValue, required String format}) async {
    try {
      final t = _mapFormat(format);
      return Right(ScanResult(id: uuid.v4(), scanType: t == BarcodeFormatType.qr ? ScanType.qr : ScanType.barcode,
        formatType: t, rawValue: rawValue, scannedAt: DateTime.now()));
    } on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> saveScanResult(ScanResult r) async {
    try { await ds.saveScanResult({'scanType': r.scanType.name, 'formatType': r.formatType.name, 'rawValue': r.rawValue, 'isFavorite': r.isFavorite}); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, List<ScanResult>>> getScanHistory({int? limit, String? type}) async {
    try { final d = await ds.getScanHistory(limit: limit, type: type); return Right(d.map((j) => ScanResult(id: j['id'] ?? '', rawValue: j['rawValue'] ?? '', scanType: ScanType.qr, scannedAt: DateTime.now())).toList()); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> deleteScanResult(String id) async {
    try { await ds.deleteScanResult(id); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> toggleFavorite(String id, bool f) async {
    try { await ds.toggleFavorite(id, f); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> clearHistory() async {
    try { await ds.clearHistory(); return const Right(null); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  BarcodeFormatType _mapFormat(String f) => switch (f.toUpperCase()) {
    'QR' => BarcodeFormatType.qr, 'UPC_A' || 'UPC-A' => BarcodeFormatType.upcA, 'EAN_13' || 'EAN-13' => BarcodeFormatType.ean13,
    'CODE_128' || 'CODE-128' => BarcodeFormatType.code128, 'PDF_417' || 'PDF417' => BarcodeFormatType.pdf417,
    'DATA_MATRIX' || 'DATA-MATRIX' => BarcodeFormatType.dataMatrix, 'AZTEC' => BarcodeFormatType.aztec,
    _ => BarcodeFormatType.unknown,
  };
}
