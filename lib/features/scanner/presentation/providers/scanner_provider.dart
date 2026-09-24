import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/barcode_format.dart';
import '../../domain/entities/scan_result.dart';

enum ScannerStatus { idle, scanning, success, error }

class ScannerState {
  final ScannerStatus status;
  final ScanResult? result;
  final String? errorMessage;
  final bool torchEnabled;
  const ScannerState({this.status = ScannerStatus.idle, this.result, this.errorMessage, this.torchEnabled = false});
  ScannerState copyWith({ScannerStatus? status, ScanResult? result, String? errorMessage, bool? torchEnabled, bool clrR = false, bool clrE = false}) =>
    ScannerState(status: status ?? this.status, result: clrR ? null : (result ?? this.result),
      errorMessage: clrE ? null : (errorMessage ?? this.errorMessage), torchEnabled: torchEnabled ?? this.torchEnabled);
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier() : super(const ScannerState());
  void onBarcodeDetected(String raw, String fmt) {
    final ft = _mapFormat(fmt);
    state = state.copyWith(status: ScannerStatus.success,
      result: ScanResult(id: DateTime.now().millisecondsSinceEpoch.toString(),
        scanType: ft == BarcodeFormatType.qr ? ScanType.qr : ScanType.barcode,
        formatType: ft, rawValue: raw, scannedAt: DateTime.now()));
  }
  void reset() => state = const ScannerState();
  void toggleTorch() => state = state.copyWith(torchEnabled: !state.torchEnabled);

  BarcodeFormatType _mapFormat(String f) => switch (f.toUpperCase()) {
    'QR' => BarcodeFormatType.qr, 'UPC_A' || 'UPC-A' => BarcodeFormatType.upcA, 'EAN_13' || 'EAN-13' => BarcodeFormatType.ean13,
    'CODE_128' || 'CODE-128' => BarcodeFormatType.code128, 'PDF_417' || 'PDF417' => BarcodeFormatType.pdf417,
    'DATA_MATRIX' || 'DATA-MATRIX' => BarcodeFormatType.dataMatrix, _ => BarcodeFormatType.unknown,
  };
}

final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>((ref) => ScannerNotifier());
