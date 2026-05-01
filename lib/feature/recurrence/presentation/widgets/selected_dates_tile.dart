import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/enums/list_item_pos.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../data/models/selected_dates_rule.dart';
import '../providers/recurrence_sheet_provider.dart';

class SelectedDatesRecurrenceTile extends ConsumerWidget {
  const SelectedDatesRecurrenceTile({this.pos = ListItemPos.middle, super.key});

  final ListItemPos pos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(recurrenceSheetProvider);
    final colors = context.colors;

    final bool isPicked = selected is SelectedDatesRule;

    final SelectedDatesRule rule = switch (selected) {
      final SelectedDatesRule rule => rule,
      _ => const SelectedDatesRule(daysOfMonth: {1}),
    };

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
              dense: true,
              visualDensity: .compact,
              onTap: () {
                if (isPicked) return;

                ref
                    .read(recurrenceSheetProvider.notifier)
                    .switchTo(const SelectedDatesRule(daysOfMonth: {1}));
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

            if (selected is SelectedDatesRule)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(31, (index) {
                    final day = index + 1;

                    final bool active = selected.daysOfMonth.contains(day);

                    return GestureDetector(
                      onTap: () {
                        final updated = Set<int>.from(selected.daysOfMonth);

                        if (active) {
                          updated.remove(day);
                        } else {
                          updated.add(day);
                        }

                        ref
                            .read(recurrenceSheetProvider.notifier)
                            .switchTo(selected.copyWith(daysOfMonth: updated));
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? colors.primary : colors.secondary,
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: active
                                ? colors.onPrimary
                                : colors.onSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
