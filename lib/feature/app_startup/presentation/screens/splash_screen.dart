import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/riverpod/async_widget.dart';
import '../providers/app_startup_provider.dart';
import '../widgets/splash_error.dart';
import '../widgets/splash_loader.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> appStartup = ref.watch(appStartupProvider);
    return Scaffold(
      body: AsyncValueWidget<String?>.orElse(
        value: appStartup,
        orElse: SplashLoader.new,
        error: (_, __) => const SplashErrorWidget(),
      ),
    );
  }
}
