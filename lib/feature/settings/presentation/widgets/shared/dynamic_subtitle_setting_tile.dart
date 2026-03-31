import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../providers/settings_provider.dart';
import 'setting_tile.dart';

class DynamicSubtitleSettingTile<T> extends ConsumerWidget {
  const DynamicSubtitleSettingTile({
    required this.leading,
    required this.title,
    required this.onTap,
    super.key,
    this.selector,
    this.subtitleBuilder,
  });

  final IconData leading;
  final String title;
  final T Function(UserSettingsNotifier)? selector;
  final String Function(BuildContext context, T? value)? subtitleBuilder;
  final Future<void> Function(BuildContext context, WidgetRef ref, T? value)
  onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final T? selectedValue = selector != null
        ? ref.watch(userSettingsProvider.select(selector!))
        : null;

    return SettingTile(
      leading: leading,
      title: Text(title, style: context.texts.titleMedium),
      subtitle: subtitleBuilder != null
          ? Text(
              subtitleBuilder!(context, selectedValue),
              style: context.texts.bodySmall,
            )
          : null,
      onTap: () => onTap(context, ref, selectedValue),
    );
  }
}
