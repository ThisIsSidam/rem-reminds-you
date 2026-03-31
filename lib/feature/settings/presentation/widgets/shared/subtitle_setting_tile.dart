import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../providers/settings_provider.dart';

class SubtitleSettingTile<T> extends ConsumerWidget {
  const SubtitleSettingTile({
    required this.leading,
    required this.title,
    required this.onTap,
    super.key,
    this.selector,
    this.subtitleBuilder,
    this.minVerticalPadding,
  });

  final IconData leading;
  final String title;
  final T Function(UserSettingsNotifier)? selector;
  final String Function(BuildContext context, T? value)? subtitleBuilder;
  final Future<void> Function(BuildContext context, WidgetRef ref, T? value)
  onTap;
  final double? minVerticalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final T? selectedValue = selector != null
        ? ref.watch(userSettingsProvider.select(selector!))
        : null;

    return ListTile(
      leading: Icon(leading, color: context.colors.primary),
      title: Text(title, style: context.texts.titleMedium),
      subtitle: subtitleBuilder != null
          ? Text(
              subtitleBuilder!(context, selectedValue),
              style: context.texts.bodySmall,
            )
          : null,
      minVerticalPadding: minVerticalPadding,
      onTap: () => onTap(context, ref, selectedValue),
    );
  }
}
