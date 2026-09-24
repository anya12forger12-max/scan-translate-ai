import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/permission_utils.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scan_result_card.dart';

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});
  @override
  ConsumerState<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage> {
  MobileScannerController? _ctrl;
  bool _perm = false;

  @override
  void initState() { super.initState(); _checkPerm(); _ctrl = MobileScannerController(); }

  @override
  void dispose() { _ctrl?.dispose(); super.dispose(); }

  Future<void> _checkPerm() async { final p = await PermissionUtils.requestCamera(); if (mounted) setState(() => _perm = p); }

  void _detect(BarcodeCapture c) {
    if (c.barcodes.isEmpty) return;
    final b = c.barcodes.first;
    if (b.rawValue == null) return;
    HapticUtils.success();
    ref.read(scannerProvider.notifier).onBarcodeDetected(b.rawValue!, b.format.name);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(scannerProvider);
    final n = ref.read(scannerProvider.notifier);

    if (s.status == ScannerStatus.success && s.result != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Result'), leading: IconButton(
          icon: const Icon(Icons.arrow_back), onPressed: () => n.reset())),
        body: ScanResultCard(result: s.result!, onShare: () => Share.share(s.result!.rawValue),
          onDismiss: () => n.reset()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner'),
        actions: [IconButton(icon: Icon(s.torchEnabled ? Icons.flash_on : Icons.flash_off,
          color: s.torchEnabled ? AppColors.warning : null), onPressed: () { n.toggleTorch(); _ctrl?.toggleTorch(); })]),
      body: _perm
          ? Stack(children: [
              MobileScanner(controller: _ctrl, onDetect: _detect),
              Center(child: Container(
                width: 300, height: 200,
                decoration: BoxDecoration(border: Border.all(color: AppColors.barcodeColor, width: 2), borderRadius: BorderRadius.circular(16)),
              )),
              Positioned(bottom: 80, left: 16, right: 16,
                child: Text('Supports: UPC, EAN, Code 39/93/128, PDF417, Data Matrix, Aztec',
                  style: AppTypography.labelSmall.copyWith(color: Colors.white70), textAlign: TextAlign.center)),
            ])
          : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.camera_alt, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text('Camera permission required', style: AppTypography.headlineSmall),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _checkPerm, child: const Text('Grant Permission')),
            ])),
    );
  }
}
