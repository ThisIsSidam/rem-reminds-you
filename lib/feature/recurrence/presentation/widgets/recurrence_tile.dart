import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/enums/list_item_pos.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../data/models/recurrence_rule.dart';
import '../providers/recurrence_sheet_provider.dart';

class RecurrenceTile extends ConsumerWidget {
  const RecurrenceTile({required this.rule, this.pos = .middle, super.key});

  final RecurrenceRule rule;
  final ListItemPos pos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RecurrenceRule selected = ref.watch(recurrenceSheetProvider);
    final ColorScheme colors = context.colors;
    final bool isPicked = selected.type == rule.type;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isPicked ? colors.primaryContainer : colors.secondaryContainer,
        borderRadius: pos.getBorderRadius(),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: pos.getBorderRadius()),
        onTap: () => ref.read(recurrenceSheetProvider.notifier).switchTo(rule),
        title: Text(
          rule.name,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: isPicked
                ? colors.onPrimaryContainer
                : colors.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
