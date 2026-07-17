import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/barcode_format.dart';
import '../../domain/entities/scan_result.dart';

class ScanResultModel {
  final String id;
  final String scanType;
  final String formatType;
  final String rawValue;
  final String? displayValue;
  final DateTime scannedAt;
  final bool isFavorite;
  final String userId;

  const ScanResultModel({
    required this.id,
    required this.scanType,
    required this.formatType,
    required this.rawValue,
    this.displayValue,
    required this.scannedAt,
    this.isFavorite = false,
    required this.userId,
  });

  factory ScanResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScanResultModel(
      id: doc.id,
      scanType: data['scanType'] as String? ?? 'qr',
      formatType: data['formatType'] as String? ?? 'unknown',
      rawValue: data['rawValue'] as String? ?? '',
      displayValue: data['displayValue'] as String?,
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] as bool? ?? false,
      userId: data['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'scanType': scanType,
      'formatType': formatType,
      'rawValue': rawValue,
      'displayValue': displayValue,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'isFavorite': isFavorite,
      'userId': userId,
    };
  }

  factory ScanResultModel.fromEntity(ScanResult entity, String userId) {
    return ScanResultModel(
      id: entity.id,
      scanType: entity.scanType.name,
      formatType: entity.formatType.name,
      rawValue: entity.rawValue,
      displayValue: entity.displayValue,
      scannedAt: entity.scannedAt,
      isFavorite: entity.isFavorite,
      userId: userId,
    );
  }

  ScanResult toEntity() {
    return ScanResult(
      id: id,
      scanType: ScanType.values.firstWhere(
        (e) => e.name == scanType,
        orElse: () => ScanType.qr,
      ),
      formatType: BarcodeFormatType.values.firstWhere(
        (e) => e.name == formatType,
        orElse: () => BarcodeFormatType.unknown,
      ),
      rawValue: rawValue,
      displayValue: displayValue,
      scannedAt: scannedAt,
      isFavorite: isFavorite,
    );
  }
}
