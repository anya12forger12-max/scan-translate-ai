import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/privacy_policy/presentation/pages/privacy_policy_page.dart';
import '../features/privacy_policy/presentation/providers/privacy_policy_provider.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import 'router.dart';

class ScanTranslateApp extends ConsumerWidget {
  const ScanTranslateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Scan & Translate AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.materialThemeMode,
      onGenerateRoute: AppRouter.generateRoute,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final status = authState.status;

    if (status == AuthStatus.initial || status == AuthStatus.loading) {
      return const _SplashScreen();
    }

    if (status == AuthStatus.unauthenticated) {
      return const LoginPage();
    }

    if (status == AuthStatus.authenticated || status == AuthStatus.error) {
      return const _AuthenticatedGate();
    }

    return const _SplashScreen();
  }
}

class _AuthenticatedGate extends ConsumerWidget {
  const _AuthenticatedGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const LoginPage();
    }

    return FutureBuilder<bool>(
      future: ref.read(authProvider.notifier).isPrivacyPolicyAccepted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final accepted = snapshot.data ?? false;

        if (!accepted) {
          ref.read(privacyPolicyProvider.notifier).setMustAccept(true);
          return const PrivacyPolicyPage(isMandatory: true);
        }

        return const HomePage();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.translate_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Scan & Translate AI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
