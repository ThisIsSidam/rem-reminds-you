import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../shared/utils/logger/global_logger.dart';
import '../providers/settings_provider.dart';
import '../widgets/sections/backup_restore_section/backup_restore_section.dart';
import '../widgets/sections/gestures_section/gestures_section.dart';
import '../widgets/sections/new_reminder_settings/new_reminder_section.dart';
import '../widgets/sections/user_preferences_section/user_pref_settings.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettingsNotifier settingsNotifier =
        ref.watch(userSettingsProvider);
    useEffect(
      () {
        gLogger.i('Built Settings Screen');
        return null;
      },
      <Object?>[],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: <Widget>[
          resetIcon(context, settingsNotifier),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const UserPreferenceSection(),
            _buildPaddedDivider(),
            const GesturesSection(),
            _buildPaddedDivider(),
            const NewReminderSection(),
            _buildPaddedDivider(),
            const BackupRestoreSection(),
            // _buildPaddedDivider(),
            // const LogsSection(),
            // _buildPaddedDivider(),
            // const OtherSection(),
            _buildVersionWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaddedDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(),
    );
  }

  Widget resetIcon(
    BuildContext context,
    UserSettingsNotifier notifier,
  ) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        gLogger.i('Tapped reset icon');
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Reset settings to default?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      gLogger.i('Reset cancelled');
                      Navigator.pop(context);
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      gLogger.i('Resetting settings');
                      notifier.resetSettings();
                      Navigator.pop(context);
                    },
                    child: const Text('Yes'),
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
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.grey),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
