import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/permission_utils.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scan_result_card.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});
  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return;
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Open Link'), content: Text('Open:\n$url'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Open'))],
    ));
    if (ok == true) await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          onOpen: s.result!.decodedUrl != null ? () => _openUrl(s.result!.decodedUrl!) : null,
          onDismiss: () => n.reset()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner'),
        actions: [IconButton(icon: Icon(s.torchEnabled ? Icons.flash_on : Icons.flash_off,
          color: s.torchEnabled ? AppColors.warning : null), onPressed: () { n.toggleTorch(); _ctrl?.toggleTorch(); })]),
      body: _perm
          ? Stack(children: [
              MobileScanner(controller: _ctrl, onDetect: _detect),
              Center(child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(border: Border.all(color: AppColors.qrColor, width: 2), borderRadius: BorderRadius.circular(16)),
              )),
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
