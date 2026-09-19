import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  static const Duration _sameValueDebounce = Duration(milliseconds: 500);
  String? _lastDetectedValue;
  DateTime? _lastDetectedAt;

  void onBarcodeDetected(String rawValue, String format) {
    final now = DateTime.now();
    if (_lastDetectedValue == rawValue &&
        _lastDetectedAt != null &&
        now.difference(_lastDetectedAt!) < _sameValueDebounce) {
      return;
    }
    _lastDetectedValue = rawValue;
    _lastDetectedAt = now;

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
    _lastDetectedValue = null;
    _lastDetectedAt = null;
    state = const ScannerState();
  }

  void toggleTorch() {
    state = state.copyWith(torchEnabled: !state.torchEnabled);
  }

  void setError(String message) {
    state = state.copyWith(status: ScannerStatus.error, errorMessage: message);
  }

  BarcodeFormatType _mapFormat(String format) {
    return switch (format) {
      'qrCode' || 'qr' || 'QR' => BarcodeFormatType.qr,
      'ean13' || 'EAN_13' || 'EAN-13' => BarcodeFormatType.ean13,
      'ean8' || 'EAN_8' || 'EAN-8' => BarcodeFormatType.ean8,
      'upcA' || 'UPC_A' || 'UPC-A' => BarcodeFormatType.upcA,
      'upcE' || 'UPC_E' || 'UPC-E' => BarcodeFormatType.upcE,
      'code39' || 'CODE_39' || 'CODE-39' => BarcodeFormatType.code39,
      'code93' || 'CODE_93' || 'CODE-93' => BarcodeFormatType.code93,
      'code128' || 'CODE_128' || 'CODE-128' => BarcodeFormatType.code128,
      'codabar' || 'CODABAR' => BarcodeFormatType.codabar,
      'itf' || 'ITF' => BarcodeFormatType.itf,
      'pdf417' || 'PDF_417' || 'PDF417' => BarcodeFormatType.pdf417,
      'dataMatrix' || 'DATA_MATRIX' || 'DATA-MATRIX' =>
        BarcodeFormatType.dataMatrix,
      'aztec' || 'AZTEC' => BarcodeFormatType.aztec,
      _ => BarcodeFormatType.unknown,
    };
  }
}

final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>(
  (ref) => ScannerNotifier(),
);
