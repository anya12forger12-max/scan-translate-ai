import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/barcode_format.dart';
import '../../domain/entities/scan_result.dart';

enum ScannerStatus { idle, scanning, success, error }

class ScannerState {
  final ScannerStatus status;
  final ScanResult? result;
  final BarcodeFormatType detectedFormat;
  final String? errorMessage;
  final bool torchEnabled;

  const ScannerState({
    this.status = ScannerStatus.idle,
    this.result,
    this.detectedFormat = BarcodeFormatType.unknown,
    this.errorMessage,
    this.torchEnabled = false,
  });

  ScannerState copyWith({
    ScannerStatus? status,
    ScanResult? result,
    BarcodeFormatType? detectedFormat,
    String? errorMessage,
    bool? torchEnabled,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return ScannerState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      detectedFormat: detectedFormat ?? this.detectedFormat,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      torchEnabled: torchEnabled ?? this.torchEnabled,
    );
  }
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier() : super(const ScannerState());

  void onBarcodeDetected(String rawValue, String format) {
    if (state.status == ScannerStatus.scanning) return;

    final formatType = _mapFormat(format);
    state = state.copyWith(
      status: ScannerStatus.success,
      result: ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        scanType: formatType == BarcodeFormatType.qr
            ? ScanType.qr
            : ScanType.barcode,
        formatType: formatType,
        rawValue: rawValue,
        scannedAt: DateTime.now(),
      ),
      detectedFormat: formatType,
    );
  }

  void resetScanner() {
    state = const ScannerState();
  }

  void toggleTorch() {
    state = state.copyWith(torchEnabled: !state.torchEnabled);
  }

  void setError(String message) {
    state = state.copyWith(status: ScannerStatus.error, errorMessage: message);
  }

  BarcodeFormatType _mapFormat(String format) {
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
      _ => BarcodeFormatType.unknown,
    };
  }
}

final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>(
  (ref) => ScannerNotifier(),
);
