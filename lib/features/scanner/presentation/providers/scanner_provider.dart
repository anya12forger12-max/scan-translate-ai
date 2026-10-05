import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/barcode_format.dart';
import '../../domain/entities/scan_result.dart';

/// The first barcode in [capture] that carries a decoded value, or `null`.
///
/// The plugin hands back whatever ML Kit reported without filtering, and ML
/// Kit's `rawValue` is nullable, so one frame can hold a valueless detection
/// ahead of a perfectly readable code. Taking `barcodes.first` and then bailing
/// out on its null value discards the whole frame — a silent no-op scan — so
/// select on the value rather than on the position.
Barcode? firstDecodedBarcode(BarcodeCapture capture) {
  for (final barcode in capture.barcodes) {
    if (barcode.rawValue != null) return barcode;
  }
  return null;
}

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
    // The keys are `BarcodeFormat.name` values from the mobile_scanner package.
    // 7.x deprecated `itf` in favour of `itf14`, added the `itf2of5` pair, and
    // added `microQrCode`, so those rows carry the newer names as well; without
    // them the plugin's own enum values would fall through to `unknown`.
    return switch (format) {
      'qrCode' || 'microQrCode' || 'qr' || 'QR' => BarcodeFormatType.qr,
      'ean13' || 'EAN_13' || 'EAN-13' => BarcodeFormatType.ean13,
      'ean8' || 'EAN_8' || 'EAN-8' => BarcodeFormatType.ean8,
      'upcA' || 'UPC_A' || 'UPC-A' => BarcodeFormatType.upcA,
      'upcE' || 'UPC_E' || 'UPC-E' => BarcodeFormatType.upcE,
      'code39' || 'CODE_39' || 'CODE-39' => BarcodeFormatType.code39,
      'code93' || 'CODE_93' || 'CODE-93' => BarcodeFormatType.code93,
      'code128' || 'CODE_128' || 'CODE-128' => BarcodeFormatType.code128,
      'codabar' || 'CODABAR' => BarcodeFormatType.codabar,
      'itf' ||
      'itf14' ||
      'itf2of5' ||
      'itf2of5WithChecksum' ||
      'ITF' =>
        BarcodeFormatType.itf,
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
