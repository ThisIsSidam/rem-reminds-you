import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/reminder_model/reminder_model.dart';
import '../providers/central_widget_provider.dart';
import '../providers/sheet_reminder_notifier.dart';
import '../sheet/reminder_sheet.dart';

class ReminderSheetHelper {
  static void openSheet({
    required BuildContext context,
    required WidgetRef ref,
    ReminderModel? reminder,
    Duration? customDuration,
    bool isNoRush = false,
  }) {
    if (reminder != null) {
      ref.read(sheetReminderNotifier).loadValues(reminder);
    } else {
      ref.read(sheetReminderNotifier).resetValuesWith(
            customDuration: customDuration,
            isNoRush: isNoRush,
          );
    }

    ref.read(centralWidgetNotifierProvider.notifier).reset();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => const ReminderSheet(),
    );
  }
}
