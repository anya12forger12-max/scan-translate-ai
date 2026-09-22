import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/permission_rationale_dialog.dart';
import '../../../../app/di/providers.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/scanner_error_view.dart';
import '../widgets/scanner_overlay.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.normal,
    );
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionOnResume();
    }
  }

  /// Re-checks the camera permission when the activity is resumed. The
  /// permission may have been revoked (or granted) from the system settings
  /// while the scanner was backgrounded, and the widget must reflect the new
  /// state instead of keeping a stale permission flag.
  Future<void> _refreshPermissionOnResume() async {
    final granted = await Permission.camera.isGranted;
    if (!mounted) return;
    setState(() => _hasPermission = granted);
  }

  Future<void> _checkPermission() async {
    if (!await Permission.camera.isGranted && mounted) {
      final proceed = await showPermissionRationale(
        context,
        title: 'Camera access',
        message: 'The scanner uses your camera to detect and read QR codes and '
            'barcodes. Nothing is recorded or uploaded just by scanning.',
      );
      if (!proceed) {
        if (mounted) setState(() => _hasPermission = false);
        return;
      }
    }
    final status = await Permission.camera.request();
    final granted = status.isGranted;
    if (mounted) {
      setState(() => _hasPermission = granted);
    }
    if (!granted && mounted && status.isPermanentlyDenied) {
      await _offerOpenSettings();
    }
  }

  /// When the permission is permanently denied the system prompt can no
  /// longer be shown, so the only recovery path is the app settings screen.
  Future<void> _offerOpenSettings() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera permission is off'),
        content: const Text(
            'The scanner needs camera access. You can allow it in the '
            'system settings for this app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    if (openSettings == true) {
      await PermissionUtils.openAppSettings();
      final granted = await Permission.camera.isGranted;
      if (mounted) {
        setState(() => _hasPermission = granted);
      }
    }
  }

  Future<void> _retryScanner() async {
    await _checkPermission();
    if (!mounted || !_hasPermission) return;
    try {
      await _scannerController?.start();
    } on Object catch (error) {
      debugPrint('QrScanner: restart failed: $error');
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
      if (!mounted) return;
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
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ScanResultCard(
                result: scannerState.result!,
                onShare: () {
                  Share.share(scannerState.result!.rawValue);
                },
                onOpen: scannerState.result!.decodedUrl != null
                    ? () => _handleOpenUrl(scannerState.result!.decodedUrl!)
                    : null,
                onSave: () async {
                  final result = scannerState.result!;
                  final outcome =
                      await ref.read(scannerRepositoryProvider).saveScanResult(result);
                  if (!mounted) return;
                  outcome.fold(
                    (failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save: ${failure.message}'),
                        ),
                      );
                    },
                    (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Result saved to history'),
                        ),
                      );
                      ref.read(scannerProvider.notifier).resetScanner();
                    },
                  );
                },
                onDismiss: () {
                  scannerNotifier.resetScanner();
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
                _scannerController?.toggleTorch().catchError((Object e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Flash not available')),
                    );
                  }
                });
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
                  errorBuilder: (context, error, child) => ScannerErrorView(
                    error: error,
                    onRetry: _retryScanner,
                  ),
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