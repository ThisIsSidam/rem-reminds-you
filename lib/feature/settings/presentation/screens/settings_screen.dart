import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/constants/app_images.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../../../shared/widgets/whats_new_sheet/whats_new_sheet.dart';
import '../providers/settings_provider.dart';
import '../widgets/shared/standard_setting_tile.dart';

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
            StandardSettingTile(
              leading: Icons.palette_outlined,
              title: context.local.settingsPersonalization,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoute.settingsPersonalization.name,
                );
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),

            StandardSettingTile(
              leading: Icons.notifications_active_outlined,
              title: context.local.settingsReminders,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, AppRoute.settingsReminder.name);
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),

            StandardSettingTile(
              leading: Icons.view_agenda_outlined,
              title: context.local.settingsAgenda,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, AppRoute.settingsAgenda.name);
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),

            StandardSettingTile(
              leading: Icons.settings_system_daydream_outlined,
              title: context.local.settingsAdvanced,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, AppRoute.settingsAdvanced.name);
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),

            _buildWhatsNewTile(context),
            const SizedBox(height: 16),
            const SettingsFooter(),
            SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsNewTile(BuildContext context) {
    return StandardSettingTile(
      leading: Icons.new_releases_outlined,
      title: context.local.settingsWhatsNew,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => showWhatsNewSheet(context),
    );
  }

  Widget resetIcon(BuildContext context, UserSettingsNotifier notifier) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () async {
        AppLogger.i('Tapped reset icon');
        final result = await showConfirmationDialog(
          context,
          title: context.local.settingsResetDialogTitle,
        );
        if (result == false || !context.mounted) return;
        notifier.resetSettings();
      },
    );
  }
}

class SettingsFooter extends StatefulWidget {
  const SettingsFooter({super.key});

  @override
  State<SettingsFooter> createState() => _SettingsFooterState();
}

class _SettingsFooterState extends State<SettingsFooter> {
  final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        spacing: 8,
        mainAxisSize: .min,
        children: [
          InkWell(
            borderRadius: .circular(50),
            onTap: () => AppUtils.openUrl(
              'https://github.com/ThisIsSidam/rem-reminds-you',
            ),
            child: SvgPicture.asset(
              AppSvgs.githubIcon.path,
              colorFilter: ColorFilter.mode(context.colors.onSurface, .srcIn),
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: packageInfo,
            builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
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
        ],
      ),
    );
  }
}
