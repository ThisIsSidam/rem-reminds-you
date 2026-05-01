import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../shared/widgets/app_tooltip.dart';
import '../providers/recurrence_sheet_provider.dart';

/// A tile to modify the 'rescheduleFromDueDate' field
/// of [RecurrenceRule].
class RescheduleTile extends ConsumerWidget {
  const RescheduleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = context.colors;
    final isOn = ref.watch(
      recurrenceSheetProvider.select((state) => state.rescheduleFromDueDate),
    );

    return Container(
      margin: const .symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: .circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
        title: Row(
          spacing: 4,
          mainAxisSize: .min,
          children: [
            Text(
              'Reschedule from due date',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: colors.onPrimaryContainer),
            ),
            const AppTooltip(
              message:
                  'If switched on, the reminder will be rescheduled based '
                  "on the due date, if switched off, it'll reschedule based "
                  'when it gets completed, which can even be two days from the '
                  ' due date if postponed.',
            ),
          ],
        ),
        trailing: Switch(
          value: isOn,
          onChanged: (_) => ref
              .read(recurrenceSheetProvider.notifier)
              .switchRescheduleFromDueDate(),
        ),
      ),
    );
  }
}
