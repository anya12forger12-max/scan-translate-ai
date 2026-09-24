import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/home_action.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Scan & Translate', style: AppTypography.titleMedium),
          if (user != null) Text(user.email ?? '', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
        ]),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/settings'), icon: const Icon(Icons.settings)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome${user != null ? ', ${user.displayName ?? user.email?.split('@').first ?? ''}' : ''}!',
                style: AppTypography.headlineSmall.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Scan QR codes, recognize text, translate content instantly.',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85))),
            ]),
          ),
          const SizedBox(height: 24),

          // Quick actions grid
          Text('Quick Actions', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
            itemCount: _actions.length,
            itemBuilder: (ctx, i) => _ActionCard(action: _actions[i], onTap: () {
              final route = _actions[i].route;
              if (route != null) Navigator.pushNamed(context, route);
            }),
          ),
          const SizedBox(height: 24),

          // Recent activity placeholder
          Text('Recent Activity', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Column(children: [
              Icon(Icons.history, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text('No recent activity', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/history'),
                child: const Text('View full history')),
            ])),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: break;
            case 1: Navigator.pushNamed(context, '/history');
            case 2: Navigator.pushNamed(context, '/settings');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final HomeAction action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true, label: action.label,
    child: Material(
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: action.color.withValues(alpha: 0.15)),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: action.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(action.icon, color: action.color, size: 28)),
            const SizedBox(height: 12),
            Text(action.label, style: AppTypography.labelMedium, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
    ),
  );
}

const _actions = [
  HomeAction(label: 'QR Scanner', icon: Icons.qr_code_scanner, color: AppColors.qrColor, route: '/qr-scanner'),
  HomeAction(label: 'Barcode Scanner', icon: Icons.document_scanner, color: AppColors.qrColor, route: '/barcode-scanner'),
  HomeAction(label: 'OCR Text', icon: Icons.text_snippet, color: AppColors.ocrColor, route: '/ocr'),
  HomeAction(label: 'Translate', icon: Icons.translate, color: AppColors.translationColor, route: '/translate'),
  HomeAction(label: 'Camera Translate', icon: Icons.camera_alt, color: AppColors.translationColor, route: '/camera-translate'),
  HomeAction(label: 'History', icon: Icons.history, color: AppColors.info, route: '/history'),
];
