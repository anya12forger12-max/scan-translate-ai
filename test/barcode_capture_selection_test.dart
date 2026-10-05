import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_translate_ai/features/scanner/domain/entities/barcode_format.dart';
import 'package:scan_translate_ai/features/scanner/presentation/providers/scanner_provider.dart';

/// A detection ML Kit can legitimately report with no decoded value — its
/// `rawValue` is nullable, and the plugin forwards it unfiltered.
const Barcode valueless = Barcode(
  rawValue: null,
  format: BarcodeFormat.qrCode,
);

const Barcode readableQr = Barcode(
  rawValue: 'https://example.com',
  format: BarcodeFormat.qrCode,
);

const Barcode readableItf = Barcode(
  rawValue: '12345670',
  format: BarcodeFormat.itf14,
);

void main() {
  group('firstDecodedBarcode selects on value, not on position', () {
    test('reads a code that sits behind a valueless detection', () {
      const capture = BarcodeCapture(barcodes: [valueless, readableQr]);

      expect(firstDecodedBarcode(capture)?.rawValue, 'https://example.com');
    });

    test('returns null when the frame decodes nothing at all', () {
      expect(
        firstDecodedBarcode(const BarcodeCapture(barcodes: [valueless])),
        isNull,
      );
      expect(
        firstDecodedBarcode(
          const BarcodeCapture(barcodes: [valueless, valueless]),
        ),
        isNull,
      );
    });

    test('returns null for an empty capture', () {
      expect(firstDecodedBarcode(const BarcodeCapture()), isNull);
    });

    test('still prefers the first code when the frame holds several', () {
      const capture = BarcodeCapture(barcodes: [readableQr, readableItf]);

      expect(firstDecodedBarcode(capture)?.rawValue, 'https://example.com');
    });

    test('preserves the format of a code found past a valueless one', () {
      const capture = BarcodeCapture(barcodes: [valueless, readableItf]);

      expect(firstDecodedBarcode(capture)?.format, BarcodeFormat.itf14);
    });
  });

  group('the selected code is what reaches scanner state', () {
    test('a valueless leading detection no longer swallows the frame', () {
      final notifier = ScannerNotifier();
      addTearDown(notifier.dispose);

      final barcode = firstDecodedBarcode(
        const BarcodeCapture(barcodes: [valueless, readableItf]),
      );
      notifier.onBarcodeDetected(barcode!.rawValue!, barcode.format.name);

      expect(notifier.state.status, ScannerStatus.success);
      expect(notifier.state.result?.rawValue, '12345670');
      expect(notifier.state.detectedFormat, BarcodeFormatType.itf);
    });

    test('a frame that decodes nothing leaves the scanner idle', () {
      final notifier = ScannerNotifier();
      addTearDown(notifier.dispose);

      final barcode = firstDecodedBarcode(
        const BarcodeCapture(barcodes: [valueless]),
      );

      expect(barcode, isNull);
      expect(notifier.state.status, ScannerStatus.idle);
      expect(notifier.state.result, isNull);
    });
  });

  group('same-value debounce', () {
    test('suppresses a repeat of the same value inside the window', () {
      final notifier = ScannerNotifier();
      addTearDown(notifier.dispose);

      notifier.onBarcodeDetected('https://example.com', 'qrCode');
      final firstId = notifier.state.result!.id;

      notifier.onBarcodeDetected('https://example.com', 'qrCode');

      expect(notifier.state.result!.id, firstId);
    });

    test('accepts a different value inside the window', () {
      final notifier = ScannerNotifier();
      addTearDown(notifier.dispose);

      notifier.onBarcodeDetected('https://example.com', 'qrCode');
      notifier.onBarcodeDetected('12345670', 'itf14');

      expect(notifier.state.result?.rawValue, '12345670');
      expect(notifier.state.detectedFormat, BarcodeFormatType.itf);
    });

    test('accepts the same value again once the window has passed', () async {
      final notifier = ScannerNotifier();
      addTearDown(notifier.dispose);

      notifier.onBarcodeDetected('https://example.com', 'qrCode');
      final firstId = notifier.state.result!.id;

      await Future<void>.delayed(const Duration(milliseconds: 520));
      notifier.onBarcodeDetected('https://example.com', 'qrCode');

      expect(notifier.state.result!.id, isNot(firstId));
    });
  });
}
