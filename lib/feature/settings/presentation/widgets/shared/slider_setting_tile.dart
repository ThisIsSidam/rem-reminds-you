import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../providers/settings_provider.dart';

class SliderSettingTile extends ConsumerWidget {
  const SliderSettingTile({
    required this.leading,
    required this.title,
    required this.selector,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelBuilder,
    super.key,
  });

  final IconData leading;
  final String title;
  final double Function(UserSettingsNotifier) selector;
  final void Function(WidgetRef ref, double value) onChanged;
  final double min;
  final double max;
  final int divisions;
  final String Function(double value) labelBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double value = ref.watch(userSettingsProvider.select(selector));

    return ListTile(
      leading: Icon(leading, color: context.colors.primary),
      title: Text(title, style: context.texts.titleMedium),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (double val) => onChanged(ref, val),
              inactiveColor: Theme.of(context).colorScheme.secondary,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(labelBuilder(value), style: context.texts.bodyMedium),
        ],
      ),
    );
  }
}
