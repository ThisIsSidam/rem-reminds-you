import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../shared/widgets/save_close_buttons.dart';
import '../../../../shared/widgets/sheet_handle.dart';
import '../../data/models/daily_rule.dart';
import '../../data/models/monthly_rule.dart';
import '../../data/models/no_recurrence_rule.dart';
import '../../data/models/recurrence_rule.dart';
import '../providers/recurrence_sheet_provider.dart';
import 'recurrence_tile.dart';
import 'weekly_recurrence_tile.dart';

Future<RecurrenceRule?> pickRecurrenceRule(
  BuildContext context, {
  RecurrenceRule? selected,
}) {
  return showModalBottomSheet<RecurrenceRule>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ProviderScope(
      overrides: [
        recurrenceSheetProvider.overrideWithBuild(
          (_, _) => selected ?? const NoRecurrenceRule(),
        ),
      ],
      child: const RecurrenceRuleSheet(),
    ),
  );
}

class RecurrenceRuleSheet extends ConsumerWidget {
  const RecurrenceRuleSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(8, 16, 8, context.bottomPadding),
      children: <Widget>[
        const Center(child: SheetHandle()),
        const SizedBox(height: 8),
        Center(
          child: Text(
            context.local.recurrenceSelectInterval,
            style: context.texts.titleMedium?.copyWith(fontWeight: .bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            spacing: 2,
            children: [
              RecurrenceTile(rule: NoRecurrenceRule(), pos: .top),
              RecurrenceTile(rule: DailyRule()),
              WeeklyRecurrenceTile(),
              RecurrenceTile(rule: MonthlyRule(), pos: .bottom),
            ],
          ),
        ),
        SaveCloseButtons(
          onTapSave: () {
            final selected = ref.read(recurrenceSheetProvider);
            Navigator.pop(context, selected);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
