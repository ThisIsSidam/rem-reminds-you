import 'package:Rem/feature/settings/presentation/widgets/sections/backup_restore_section/backup_restore_section.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/gestures_section/gestures_section.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/logs/logs_section.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/new_reminder_settings/new_reminder_section.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/other_section/other_section.dart';
import 'package:Rem/feature/settings/presentation/widgets/sections/user_preferences_section/user_pref_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../shared/utils/logger/global_logger.dart';

class SettingsScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      gLogger.i('Built Settings Screen');
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          resetIcon(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserPreferenceSection(),
            _buildPaddedDivider(),
            GesturesSection(),
            _buildPaddedDivider(),
            NewReminderSection(),
            _buildPaddedDivider(),
            BackupRestoreSection(),
            _buildPaddedDivider(),
            LogsSection(),
            _buildPaddedDivider(),
            OtherSection(),
            _buildVersionWidget()
          ],
        ),
      ),
    );
  }

  Widget _buildPaddedDivider() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16), child: Divider());
  }

  Widget resetIcon(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        gLogger.i('Tapped reset icon');
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Reset Settings to Default?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          gLogger.i('Reset cancelled');
                          Navigator.pop(context);
                        },
                        child: Text("No")),
                    TextButton(
                        onPressed: () {
                          gLogger.i('Resetting settings');
                          // TODO: implement reset settings
                          Navigator.pop(context);
                        },
                        child: Text("Yes"))
                  ],
                ),
              );
            });
      },
    );
  }

  Widget _buildVersionWidget() {
    final packageInfo = PackageInfo.fromPlatform();
    return Center(
      child: FutureBuilder(
          future: packageInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                  height: 24,
                  width: 24,
                  child: const Center(child: CircularProgressIndicator()));
            }

            if (snapshot.hasData) {
              return Text("v${snapshot.data!.version}",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.grey));
            }

            return SizedBox.shrink();
          }),
    );
  }
}
