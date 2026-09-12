import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/loading_display.dart';
import '../../domain/entities/scan_result.dart';
import '../widgets/scan_result_card.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanResultPage extends StatelessWidget {
  final ScanResult result;

  const ScanResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${result.formatType.displayName} Result'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScanResultCard(
              result: result,
              onShare: () {
                Share.share(result.rawValue);
              },
              onCopy: () {
                HapticUtils.lightImpact();
              },
              onOpen: result.decodedUrl != null
                  ? () async {
                      final url = result.decodedUrl!;
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        if (!context.mounted) return;
                        final shouldOpen = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Open External Link'),
                            content: Text(
                              'This link came from an untrusted scanned QR '
                              'code. Do you want to open:\n$url',
                            ),
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
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    }
                  : null,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved to history')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
