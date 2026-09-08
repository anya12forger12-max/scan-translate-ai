import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_result_card.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  ConsumerState<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage> {
  MobileScannerController? _scannerController;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _scannerController = MobileScannerController(
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() => _hasPermission = status.isGranted);
    }
  }

  void _handleDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    HapticUtils.success();
    ref.read(scannerProvider.notifier).onBarcodeDetected(
          barcode.rawValue!,
          barcode.format.name,
        );
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);
    final scannerNotifier = ref.read(scannerProvider.notifier);

    if (scannerState.status == ScannerStatus.success && scannerState.result != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan Result'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => scannerNotifier.resetScanner(),
          ),
        ),
        body: ScanResultCard(
          result: scannerState.result!,
          onShare: () {
            Share.share(scannerState.result!.rawValue);
          },
          onSave: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Result saved to history')),
            );
            scannerNotifier.resetScanner();
          },
          onDismiss: () => scannerNotifier.resetScanner(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        actions: [
          Semantics(
            label: 'Toggle flashlight',
            child: IconButton(
              icon: Icon(
                scannerState.torchEnabled
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                color: scannerState.torchEnabled ? AppColors.warning : null,
              ),
              onPressed: () {
                scannerNotifier.toggleTorch();
                _scannerController?.toggleTorch();
              },
              tooltip: 'Toggle flashlight',
            ),
          ),
        ],
      ),
      body: _hasPermission
          ? Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _handleDetect,
                ),
                const ScannerOverlay(
                  label: 'Align barcode within frame',
                  borderColor: AppColors.barcodeColor,
                ),
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Semantics(
                    label: 'Supported barcode types',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Supports: UPC, EAN, Code 39/93/128, PDF417, Data Matrix, Aztec',
                        style: AppTypography.labelSmall.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'Camera permission required',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _checkPermission,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            ),
    );
  }
}
