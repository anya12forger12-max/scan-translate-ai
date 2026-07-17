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
                SharePlus.instance.share(
                  ShareParams(text: result.rawValue),
                );
              },
              onCopy: () {
                HapticUtils.lightImpact();
              },
              onOpen: result.decodedUrl != null
                  ? () async {
                      final uri = Uri.parse(result.decodedUrl!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
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
