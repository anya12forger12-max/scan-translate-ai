import 'package:equatable/equatable.dart';
import 'barcode_format.dart';

enum ScanType { qr, barcode, ocr, translation }

class ScanResult extends Equatable {
  static const int maxRawValueLength = 4096;

  final String id;
  final ScanType scanType;
  final BarcodeFormatType formatType;
  final String rawValue;
  final String? displayValue;
  final DateTime scannedAt;
  final bool isFavorite;
  final bool wasTruncated;

  ScanResult({
    required this.id,
    required this.scanType,
    this.formatType = BarcodeFormatType.unknown,
    required String rawValue,
    this.displayValue,
    required this.scannedAt,
    this.isFavorite = false,
    bool? wasTruncated,
  })  : rawValue = _truncate(rawValue),
        wasTruncated = wasTruncated ?? rawValue.length > maxRawValueLength;

  static String _truncate(String value) {
    if (value.length <= maxRawValueLength) return value;
    return '${value.substring(0, maxRawValueLength - 1)}…';
  }

  ScanResult copyWith({
    String? id,
    ScanType? scanType,
    BarcodeFormatType? formatType,
    String? rawValue,
    String? displayValue,
    DateTime? scannedAt,
    bool? isFavorite,
    bool? wasTruncated,
  }) {
    return ScanResult(
      id: id ?? this.id,
      scanType: scanType ?? this.scanType,
      formatType: formatType ?? this.formatType,
      rawValue: rawValue ?? this.rawValue,
      displayValue: displayValue ?? this.displayValue,
      scannedAt: scannedAt ?? this.scannedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      wasTruncated: wasTruncated ?? this.wasTruncated,
    );
  }

  String? get decodedUrl {
    if (rawValue.startsWith('http://') || rawValue.startsWith('https://')) {
      return rawValue;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        scanType,
        formatType,
        rawValue,
        displayValue,
        scannedAt,
        isFavorite,
        wasTruncated,
      ];
}
