import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_result_card.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  bool _hasPermission = false;
  bool _cameraInitialized = false;

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

  void _handleOpenUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Open External Link'),
          content: Text('Do you want to open:\n$url'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open'),
            ),
          ],
        ),
      );
      if (shouldOpen == true) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
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
            onPressed: () {
              scannerNotifier.resetScanner();
              setState(() => _cameraInitialized = false);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ScanResultCard(
                result: scannerState.result!,
                onShare: () {
                  SharePlus.instance.share(
                    ShareParams(text: scannerState.result!.rawValue),
                  );
                },
                onOpen: scannerState.result!.decodedUrl != null
                    ? () => _handleOpenUrl(scannerState.result!.decodedUrl!)
                    : null,
                onSave: () {
                  ref.read(scannerProvider.notifier).resetScanner();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Result saved to history')),
                  );
                },
                onDismiss: () {
                  scannerNotifier.resetScanner();
                  setState(() => _cameraInitialized = false);
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
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
                  label: 'Align QR code within frame',
                  borderColor: AppColors.qrColor,
                ),
                if (scannerState.errorMessage != null)
                  Positioned(
                    bottom: 100,
                    left: 16,
                    right: 16,
                    child: ErrorBanner(
                      message: scannerState.errorMessage!,
                      onDismiss: () => scannerNotifier.resetScanner(),
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
                  const SizedBox(height: 8),
                  Text(
                    'Please grant camera access to scan QR codes.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
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
