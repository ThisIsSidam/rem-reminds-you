import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/enums/list_item_pos.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../data/models/recurrence_rule.dart';
import '../../data/models/weekly_rule.dart';

class WeeklyRecurrenceTile extends ConsumerStatefulWidget {
  const WeeklyRecurrenceTile({
    required this.selected,
    this.pos = ListItemPos.middle,
    super.key,
  });

  final ListItemPos pos;
  final RecurrenceRule selected;

  @override
  ConsumerState<WeeklyRecurrenceTile> createState() =>
      _WeeklyRecurrenceTileState();
}

class _WeeklyRecurrenceTileState extends ConsumerState<WeeklyRecurrenceTile> {
  final WeeklyRule rule = const WeeklyRule();

  RecurrenceRule get selected => widget.selected;

  void _onTap(int noOfWeeks) =>
      Navigator.pop(context, WeeklyRule(noOfWeeks: noOfWeeks));

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final bool isPicked = selected is WeeklyRule;
    final selectedNoOfWeeks = switch (selected) {
      WeeklyRule(:final noOfWeeks) => noOfWeeks,
      _ => 1,
    };

    return Builder(
      builder: (context) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: isPicked
                ? colors.primaryContainer
                : colors.secondaryContainer,
            borderRadius: widget.pos.getBorderRadius(),
          ),
          child: ListTile(
            onTap: () => _onTap(selectedNoOfWeeks),
            title: Text(
              rule.name,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isPicked
                    ? colors.onPrimaryContainer
                    : colors.onSecondaryContainer,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [1, 2, 3].map((value) {
                final active = selectedNoOfWeeks == value;
                return GestureDetector(
                  onTap: () => _onTap(value),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? colors.primary
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$value',
                      style: TextStyle(
                        color: active
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
