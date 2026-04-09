import 'package:flutter/material.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../permissions/domain/app_permi_handler.dart';

class NotificationHelpScreen extends StatelessWidget {
  const NotificationHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.local.notificationHelpTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(context),
            const SizedBox(height: 24),
            Text(
              context.local.notificationHelpIntro,
              style: context.texts.bodyLarge,
              textAlign: .center,
            ),
            const SizedBox(height: 32),
            _HelpStepTile(
              icon: Icons.battery_saver_outlined,
              title: context.local.notificationHelpBatteryOptimizationTitle,
              description:
                  context.local.notificationHelpBatteryOptimizationDesc,
              onTap: () async =>
                  AppPermissionHandler.requestIgnoreBatteryOptimization(),
            ),
            const SizedBox(height: 16),
            _HelpStepTile(
              icon: Icons.run_circle_outlined,
              title: context.local.notificationHelpAutoStartTitle,
              description: context.local.notificationHelpAutoStartDesc,
              onTap: () async => AppPermissionHandler.openAutoStartSettings(),
            ),
            const SizedBox(height: 16),
            _HelpStepTile(
              icon: Icons.lock_outline,
              title: context.local.notificationHelpLockAppTitle,
              description: context.local.notificationHelpLockAppDesc,
            ),
            const SizedBox(height: 16),
            _HelpStepTile(
              icon: Icons.data_usage_outlined,
              title: context.local.notificationHelpDataSaverTitle,
              description: context.local.notificationHelpDataSaverDesc,
              onTap: () async => AppPermissionHandler.openAppSettings(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.primaryContainer),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.colors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              context.local.notificationHelpBanner,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpStepTile extends StatelessWidget {
  const _HelpStepTile({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colors.surfaceContainerHighest.withAlpha(100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: context.colors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.texts.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: context.texts.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onTap != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(context.local.notificationHelpOpenSettings),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
