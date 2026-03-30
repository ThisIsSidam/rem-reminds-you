import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../../../shared/widgets/whats_new_sheet/whats_new_sheet.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettingsNotifier settingsNotifier = ref.watch(
      userSettingsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          context.local.settingsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: <Widget>[resetIcon(context, settingsNotifier)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            _buildNavigationTile(
              context,
              title: 'Personalization',
              icon: Icons.palette_outlined,
              route: AppRoute.settingsPersonalization,
            ),
            _buildNavigationTile(
              context,
              title: 'Reminder Settings',
              icon: Icons.notifications_active_outlined,
              route: AppRoute.settingsReminder,
            ),
            _buildNavigationTile(
              context,
              title: 'Agenda Settings',
              icon: Icons.view_agenda_outlined,
              route: AppRoute.settingsAgenda,
            ),
            _buildNavigationTile(
              context,
              title: 'Advanced',
              icon: Icons.settings_system_daydream_outlined,
              route: AppRoute.settingsAdvanced,
            ),
            _buildWhatsNewTile(context),
            const SizedBox(height: 16),
            _buildVersionWidget(),
            SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required AppRoute route,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.colors.primary),
      title: Text(title, style: context.texts.titleMedium),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pushNamed(context, route.name);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildWhatsNewTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.new_releases_outlined, color: context.colors.primary),
      title: Text(
        context.local.settingsWhatsNew,
        style: context.texts.titleMedium,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => showWhatsNewSheet(context),
    );
  }

  Widget resetIcon(BuildContext context, UserSettingsNotifier notifier) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        AppLogger.i('Tapped reset icon');
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                context.local.settingsResetDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      AppLogger.i('Reset cancelled');
                      Navigator.pop(context);
                    },
                    child: Text(context.local.settingsNo),
                  ),
                  TextButton(
                    onPressed: () {
                      AppLogger.i('Resetting settings');
                      notifier.resetSettings();
                      Navigator.pop(context);
                    },
                    child: Text(context.local.settingsYes),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVersionWidget() {
    final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
    return Center(
      child: FutureBuilder<PackageInfo>(
        future: packageInfo,
        builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 24,
              width: 24,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return Text(
              'v${snapshot.data!.version}',
              style: context.texts.bodySmall?.copyWith(color: Colors.grey),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
