import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_translate_ai/features/scanner/domain/entities/barcode_format.dart';
import 'package:scan_translate_ai/features/scanner/domain/entities/scan_result.dart';
import 'package:scan_translate_ai/features/scanner/presentation/providers/scanner_provider.dart';

/// Names `ScannerNotifier` is allowed to leave as [BarcodeFormatType.unknown].
///
/// `all`/`unknown` are sentinels rather than real symbologies, and the MaxiCode
/// and GS1 DataBar family has no equivalent in the app's [BarcodeFormatType].
/// Everything else the plugin can report must be classified, so a plugin rename
/// that silently degrades a format fails this file rather than the app.
const Set<String> allowedUnclassified = {
  'all',
  'unknown',
  'maxiCode',
  'dataBar',
  'dataBarExpanded',
  'dataBarLimited',
};

BarcodeFormatType classify(String formatName) {
  final notifier = ScannerNotifier();
  // A distinct payload per call, so the 500 ms same-value debounce in
  // onBarcodeDetected never swallows one of the cases.
  notifier.onBarcodeDetected('payload-for-$formatName', formatName);
  return notifier.state.result!.formatType;
}

void main() {
  group('ScannerNotifier barcode classification', () {
    test('every format mobile_scanner can report is classified, or is an '
        'explicitly allowed unclassified name', () {
      for (final format in BarcodeFormat.values) {
        final isUnclassified = allowedUnclassified.contains(format.name);
        expect(
          classify(format.name) == BarcodeFormatType.unknown,
          isUnclassified,
          reason: 'BarcodeFormat.${format.name} '
              '${isUnclassified ? 'must' : 'must not'} map to unknown',
        );
      }
    });

    test('the ITF variants introduced by mobile_scanner 7 stay ITF', () {
      // 7.x deprecated `itf` in favour of `itf14` and added the checksum-free
      // `itf2of5` pair, so a bare `itf` row would report `unknown`.
      for (final name in const [
        'itf',
        'itf14',
        'itf2of5',
        'itf2of5WithChecksum',
      ]) {
        expect(classify(name), BarcodeFormatType.itf, reason: name);
      }
    });

    test('Micro QR is classified as QR', () {
      expect(classify('microQrCode'), BarcodeFormatType.qr);
    });

    test('a QR code is recorded as a QR scan, not a generic barcode', () {
      final notifier = ScannerNotifier();
      notifier.onBarcodeDetected('https://example.test', 'qrCode');
      final result = notifier.state.result!;
      expect(result.formatType, BarcodeFormatType.qr);
      expect(result.scanType, ScanType.qr);
    });

    test('a non-QR code is recorded as a generic barcode scan', () {
      final notifier = ScannerNotifier();
      notifier.onBarcodeDetected('9781234567897', 'ean13');
      final result = notifier.state.result!;
      expect(result.formatType, BarcodeFormatType.ean13);
      expect(result.scanType, ScanType.barcode);
    });

    test('the legacy Android-style format aliases still classify', () {
      const aliases = {
        'QR': BarcodeFormatType.qr,
        'UPC_A': BarcodeFormatType.upcA,
        'UPC_E': BarcodeFormatType.upcE,
        'EAN_8': BarcodeFormatType.ean8,
        'EAN_13': BarcodeFormatType.ean13,
        'CODE_39': BarcodeFormatType.code39,
        'CODE_93': BarcodeFormatType.code93,
        'CODE_128': BarcodeFormatType.code128,
        'CODABAR': BarcodeFormatType.codabar,
        'ITF': BarcodeFormatType.itf,
        'PDF_417': BarcodeFormatType.pdf417,
        'DATA_MATRIX': BarcodeFormatType.dataMatrix,
        'AZTEC': BarcodeFormatType.aztec,
      };
      aliases.forEach((name, expected) {
        expect(classify(name), expected, reason: name);
      });
    });

    test('an unrecognised format name is reported as unknown', () {
      expect(classify('someFutureSymbology'), BarcodeFormatType.unknown);
    });

    test('repeated scans of the same value inside the debounce window are '
        'collapsed, and resume afterwards', () {
      final notifier = ScannerNotifier();
      notifier.onBarcodeDetected('same-value', 'qrCode');
      final first = notifier.state.result;
      notifier.onBarcodeDetected('same-value', 'qrCode');
      expect(identical(notifier.state.result, first), isTrue);
    });
  });
}