import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/barcode_format.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_datasource.dart';
import '../models/scan_result_model.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerRemoteDataSource remoteDataSource;
  final Uuid uuid;

  ScannerRepositoryImpl({
    required this.remoteDataSource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, ScanResult>> processScanResult({
    required String rawValue,
    required String format,
  }) async {
    try {
      final type = _mapFormatToType(format);
      final result = ScanResult(
        id: uuid.v4(),
        scanType: type == BarcodeFormatType.qr ? ScanType.qr : ScanType.barcode,
        formatType: type,
        rawValue: rawValue,
        scannedAt: DateTime.now(),
      );
      return Right(result);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveScanResult(ScanResult result) async {
    try {
      final model = ScanResultModel.fromEntity(result, remoteDataSource.userId);
      await remoteDataSource.saveScanResult(model.toFirestore());
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ScanResult>>> getScanHistory({
    int? limit,
    String? type,
  }) async {
    try {
      final data = await remoteDataSource.getScanHistory(limit: limit, type: type);
      final results = data.map((json) {
        return ScanResultModel.fromFirestore(
          // ignore: missing_return
          () {} as dynamic, // simplified for demo
        ).toEntity();
      }).toList();
      return Right(results);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteScanResult(String id) async {
    try {
      await remoteDataSource.deleteScanResult(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String id, bool favorite) async {
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

  BarcodeFormatType _mapFormatToType(String format) {
    return switch (format.toUpperCase()) {
      'QR' => BarcodeFormatType.qr,
      'UPC_A' || 'UPC-A' => BarcodeFormatType.upcA,
      'UPC_E' || 'UPC-E' => BarcodeFormatType.upcE,
      'EAN_8' || 'EAN-8' => BarcodeFormatType.ean8,
      'EAN_13' || 'EAN-13' => BarcodeFormatType.ean13,
      'CODE_39' || 'CODE-39' => BarcodeFormatType.code39,
      'CODE_93' || 'CODE-93' => BarcodeFormatType.code93,
      'CODE_128' || 'CODE-128' => BarcodeFormatType.code128,
      'CODABAR' => BarcodeFormatType.codabar,
      'ITF' => BarcodeFormatType.itf,
      'PDF_417' || 'PDF417' => BarcodeFormatType.pdf417,
      'DATA_MATRIX' || 'DATA-MATRIX' => BarcodeFormatType.dataMatrix,
      'AZTEC' => BarcodeFormatType.aztec,
      'GS1' => BarcodeFormatType.gs1,
      'ISBN' => BarcodeFormatType.isbn,
      'ISSN' => BarcodeFormatType.issn,
      _ => BarcodeFormatType.unknown,
    };
  }
}
