import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../providers/app_startup_provider.dart';

class SplashErrorWidget extends ConsumerWidget {
  const SplashErrorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(context.local.somethingWentWrong),
            ElevatedButton(
              onPressed: () => ref.invalidate(appStartupProvider),
              child: Text(context.local.retry),
            ),
          ],
        ),
      ),
    );
  }
}
