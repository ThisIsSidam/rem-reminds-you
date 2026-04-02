import 'package:flutter/material.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../shared/widgets/sheet_handle.dart';
import '../../data/models/recurrence_rule.dart';

Future<RecurrenceRule?> pickRecurrenceRule(
  BuildContext context, {
  RecurrenceRule? selected,
}) {
  return showModalBottomSheet<RecurrenceRule>(
    context: context,
    builder: (_) => RecurrenceRuleSheet(selected: selected ?? RecurrenceRule()),
  );
}

class RecurrenceRuleSheet extends StatelessWidget {
  const RecurrenceRuleSheet({required this.selected, super.key});

  final RecurrenceRule selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 16, 8, context.bottomPadding),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SheetHandle(),
          Text(
            context.local.recurrenceSelectInterval,
            style: context.texts.titleMedium?.copyWith(fontWeight: .bold),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                IntervalTile(rule: RecurrenceRule(), selected: selected),
                const SizedBox(height: 2),
                IntervalTile(rule: RecurrenceRule.daily(), selected: selected),
                const SizedBox(height: 2),
                IntervalTile(rule: RecurrenceRule.weekly(), selected: selected),
                const SizedBox(height: 2),
                IntervalTile(
                  rule: RecurrenceRule.monthly(),
                  selected: selected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntervalTile extends StatelessWidget {
  const IntervalTile({required this.rule, this.selected, super.key});

  final RecurrenceRule rule;
  final RecurrenceRule? selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final bool isPicked = selected?.type == rule.type;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isPicked ? colors.primaryContainer : colors.secondaryContainer,
      ),
      child: ListTile(
        onTap: () => Navigator.pop(context, rule),
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
