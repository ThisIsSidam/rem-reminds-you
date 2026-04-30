import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/enums/list_item_pos.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../shared/utils/app_utils.dart';
import '../../../../shared/widgets/enter_value_sheet.dart';
import '../../data/models/recurrence_rule.dart';
import '../../data/models/weekly_rule.dart';
import '../providers/recurrence_sheet_provider.dart';

class WeeklyRecurrenceTile extends ConsumerStatefulWidget {
  const WeeklyRecurrenceTile({this.pos = ListItemPos.middle, super.key});

  final ListItemPos pos;

  @override
  ConsumerState<WeeklyRecurrenceTile> createState() =>
      _WeeklyRecurrenceTileState();
}

class _WeeklyRecurrenceTileState extends ConsumerState<WeeklyRecurrenceTile> {
  final WeeklyRule rule = const WeeklyRule();
  late final ValueNotifier<int?> _customWeeksNotifier;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(recurrenceSheetProvider);
    final noOfWeeks = switch (selected) {
      WeeklyRule(:final noOfWeeks) => noOfWeeks,
      _ => 1,
    };
    _customWeeksNotifier = ValueNotifier<int?>(
      noOfWeeks > 2 ? noOfWeeks : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final RecurrenceRule selected = ref.watch(recurrenceSheetProvider);
    final ColorScheme colors = context.colors;
    final bool isPicked = selected is WeeklyRule;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isPicked ? colors.primaryContainer : colors.secondaryContainer,
          borderRadius: widget.pos.getBorderRadius(),
        ),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                if (isPicked) return;
                ref
                    .read(recurrenceSheetProvider.notifier)
                    .switchTo(const WeeklyRule());
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
                selected is WeeklyRule
                    ? selected.description
                    : rule.description,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: isPicked
                      ? colors.onPrimaryContainer
                      : colors.onSecondaryContainer,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPicked ? colors.primary : colors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${selected is WeeklyRule ? selected.noOfWeeks : 1}',
                      style: TextStyle(
                        color: isPicked ? colors.onPrimary : colors.onSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: isPicked ? colors.onPrimary : colors.onSecondary,
                    ),
                  ],
                ),
              ),
            ),

            if (selected is WeeklyRule)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: .spaceAround,
                  children: [
                    _buildWeeksButton(1, selected),
                    _buildWeeksButton(2, selected),
                    _buildCustomWeeksButton(selected),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildWeeksButton(int value, WeeklyRule selected) {
    final colors = context.colors;
    final bool active = selected.noOfWeeks == value;
    return GestureDetector(
      onTap: () => ref
          .read(recurrenceSheetProvider.notifier)
          .switchTo(selected.copyWith(noOfWeeks: value)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? colors.primary : colors.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '$value week${value > 1 ? 's' : ''}',
          style: TextStyle(
            color: active ? colors.onPrimary : colors.onSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomWeeksButton(WeeklyRule seleected) {
    final colors = context.colors;

    return ValueListenableBuilder(
      valueListenable: _customWeeksNotifier,
      builder: (context, value, child) {
        final bool active = seleected.noOfWeeks == value;
        return GestureDetector(
          onTap: () async {
            final int? customWeeks = await showNumInputSheet<int>(
              context,
              value: _customWeeksNotifier.value ?? 3,
              hintText: 'Enter number of weeks',
            );
            if (customWeeks == null || !context.mounted) return;
            if (customWeeks < 1 || customWeeks > 100) {
              return showToast(context, msg: 'Enter a valid number of weeks!');
            }
            _customWeeksNotifier.value = customWeeks;
            ref
                .read(recurrenceSheetProvider.notifier)
                .switchTo(WeeklyRule(noOfWeeks: customWeeks));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: active ? colors.primary : colors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              switch (value) {
                null => '? Weeks',
                1 => '1 Week',
                > 1 => '$value Weeks',
                _ => '? Weeks',
              },
              style: TextStyle(
                color: active ? colors.onPrimary : colors.onSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
