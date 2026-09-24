import 'package:equatable/equatable.dart';
import 'barcode_format.dart';

enum ScanType { qr, barcode, ocr, translation }

class ScanResult extends Equatable {
  final String id, rawValue;
  final String? displayValue;
  final ScanType scanType;
  final BarcodeFormatType formatType;
  final DateTime scannedAt;
  final bool isFavorite;

  const ScanResult({
    required this.id, required this.rawValue, required this.scanType,
    this.formatType = BarcodeFormatType.unknown, this.displayValue,
    required this.scannedAt, this.isFavorite = false,
  });

  ScanResult copyWith({String? id, ScanType? scanType, BarcodeFormatType? formatType,
    String? rawValue, String? displayValue, DateTime? scannedAt, bool? isFavorite}) =>
    ScanResult(id: id ?? this.id, scanType: scanType ?? this.scanType,
      formatType: formatType ?? this.formatType, rawValue: rawValue ?? this.rawValue,
      displayValue: displayValue ?? this.displayValue, scannedAt: scannedAt ?? this.scannedAt,
      isFavorite: isFavorite ?? this.isFavorite);

  String? get decodedUrl => rawValue.startsWith('http') ? rawValue : null;

  @override List<Object?> get props => [id, scanType, formatType, rawValue, displayValue, scannedAt, isFavorite];
}
