import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../providers/settings_provider.dart';

class DropdownSettingTile<T> extends ConsumerWidget {
  const DropdownSettingTile({
    required this.leading,
    required this.title,
    required this.selector,
    required this.items,
    required this.onChanged,
    super.key,
    this.dropdownColor,
  });

  final IconData leading;
  final String title;
  final T Function(UserSettingsNotifier) selector;
  final List<DropdownMenuItem<T>> items;
  final void Function(WidgetRef ref, T value) onChanged;
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final T value = ref.watch(userSettingsProvider.select(selector));

    return ListTile(
      leading: Icon(leading, color: context.colors.primary),
      title: Text(title, style: context.texts.titleMedium),
      trailing: DropdownButton<T>(
        dropdownColor: dropdownColor ?? Theme.of(context).cardColor,
        underline: const SizedBox(),
        padding: const EdgeInsets.only(left: 8, right: 4),
        iconSize: 20,
        style: context.texts.bodyMedium,
        borderRadius: BorderRadius.circular(12),
        value: value,
        items: items,
        onChanged: (T? val) {
          if (val != null) {
            onChanged(ref, val);
          }
        },
      ),
    );
  }
}
