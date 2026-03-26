import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../router/app_routes.dart';
import '../../../../shared/widgets/riverpod/async_widget.dart';
import '../providers/app_startup_provider.dart';
import '../widgets/splash_error.dart';
import '../widgets/splash_loader.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(appStartupProvider, (_, curr) {
      curr.whenData(_handleRouting);
    });
  }

  /// Route user to where needed..
  /// Like, permission screen if not permissions' aren't accepted,
  /// Or Dashboard screen.
  Future<void> _handleRouting(AppRoute route) async {
    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed(route.name);
  }

  @override
  Widget build(BuildContext context) {
    final appStartup = ref.watch(appStartupProvider);

    return Scaffold(
      body: AsyncValueWidget<AppRoute>.orElse(
        value: appStartup,
        orElse: SplashLoader.new,
        error: (_, __) => const SplashErrorWidget(),
      ),
    );
  }
}
