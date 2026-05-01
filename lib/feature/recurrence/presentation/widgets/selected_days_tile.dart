import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/enums/list_item_pos.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../data/models/recurrence_rule.dart';
import '../../data/models/selected_days_rule.dart';
import '../providers/recurrence_sheet_provider.dart';

class SelectedDaysRecurrenceTile extends ConsumerWidget {
  const SelectedDaysRecurrenceTile({this.pos = ListItemPos.middle, super.key});

  final ListItemPos pos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RecurrenceRule selected = ref.watch(recurrenceSheetProvider);

    final ColorScheme colors = context.colors;
    final bool isPicked = selected is SelectedDaysRule;

    final SelectedDaysRule activeRule = switch (selected) {
      final SelectedDaysRule rule => rule,
      _ => const SelectedDaysRule(weekdays: {DateTime.monday}),
    };

    final rule = activeRule;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isPicked ? colors.primaryContainer : colors.secondaryContainer,
          borderRadius: pos.getBorderRadius(),
        ),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                if (isPicked) return;

                ref
                    .read(recurrenceSheetProvider.notifier)
                    .switchTo(
                      const SelectedDaysRule(weekdays: {DateTime.monday}),
                    );
              },

              title: Text(
                rule.name,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: isPicked
                      ? colors.onPrimaryContainer
                      : colors.onSecondaryContainer,
                ),
              ),

              subtitle: Text(
                rule.description,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: isPicked
                      ? colors.onPrimaryContainer
                      : colors.onSecondaryContainer,
                ),
              ),
            ),

            if (selected is SelectedDaysRule) _buildDaysSelector(selected, ref),
          ],
        ),
      ),
    );
  }

  Padding _buildDaysSelector(SelectedDaysRule selected, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ColorScheme colors = context.colors;
          const double itemSize = 52;
          const double spacing = 8;

          // Total width needed for all 7 in one row
          const totalWidth = (itemSize * 7) + (spacing * 6);

          final bool singleRow = constraints.maxWidth >= totalWidth;

          Widget buildDayButton(int weekday, String label) {
            final bool active = selected.weekdays.contains(weekday);

            return GestureDetector(
              onTap: () {
                final updated = Set<int>.from(selected.weekdays);

                if (active) {
                  updated.remove(weekday);
                } else {
                  updated.add(weekday);
                }

                ref
                    .read(recurrenceSheetProvider.notifier)
                    .switchTo(selected.copyWith(weekdays: updated));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: itemSize,
                height: itemSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? colors.primary : colors.secondary,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? colors.onPrimary : colors.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          final entries = SelectedDaysRule.days.entries.toList();

          // All days in a single row..
          if (singleRow) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: entries.indexed.map((item) {
                final int index = item.$1;
                final entry = item.$2;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == entries.length - 1 ? 0 : spacing,
                  ),
                  child: buildDayButton(entry.key, entry.value),
                );
              }).toList(),
            );
          }

          // In two rows.. 4 + 3
          // Mon, Tue, Wed, Thur
          final firstRow = entries.take(4);
          // Fri, Sat, Sun
          final secondRow = entries.skip(4);

          Widget buildRow(Iterable<MapEntry<int, String>> row) {
            final rowEntries = row.toList();

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: rowEntries.indexed.map((item) {
                final int index = item.$1;
                final entry = item.$2;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == rowEntries.length - 1 ? 0 : spacing,
                  ),
                  child: buildDayButton(entry.key, entry.value),
                );
              }).toList(),
            );
          }

          return Column(
            children: [
              buildRow(firstRow),
              const SizedBox(height: spacing),
              buildRow(secondRow),
            ],
          );
        },
      ),
    );
  }
}
