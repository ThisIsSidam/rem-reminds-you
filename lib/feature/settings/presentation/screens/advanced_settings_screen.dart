import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_ext.dart';
import '../widgets/advanced_settings/backup_restore_section.dart';
import '../widgets/advanced_settings/logs_section.dart';

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          context.local.settingsAdvanced,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            const BackupRestoreSection(),
            // Logs don't work properly. They need more work.
            // Till then, they are debugMode only
            if (kDebugMode) ...<Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              const LogsSection(),
            ],
            SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + 16),
          ],
        ),
      ),
    );
  }
}
