import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../providers/settings_provider.dart';
import 'setting_tile.dart';

class SwitchSettingTile extends ConsumerWidget {
  const SwitchSettingTile({
    required this.leading,
    required this.title,
    required this.selector,
    required this.onChanged,
    super.key,
  });

  final IconData leading;
  final String title;
  final bool Function(UserSettingsNotifier) selector;
  final void Function(WidgetRef ref, bool value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool value = ref.watch(userSettingsProvider.select(selector));

    return SettingTile(
      leading: leading,
      title: Text(title, style: context.texts.titleMedium),
      trailing: Switch(
        value: value,
        onChanged: (bool val) => onChanged(ref, val),
      ),
    );
  }
}
