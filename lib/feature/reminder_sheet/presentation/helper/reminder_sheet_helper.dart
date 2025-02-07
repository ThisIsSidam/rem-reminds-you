import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/reminder_model/reminder_model.dart';
import '../providers/central_widget_provider.dart';
import '../providers/sheet_reminder_notifier.dart';
import '../sheet/reminder_sheet.dart';

class ReminderSheetHelper {
  static void openSheet({
    required BuildContext context,
    ReminderModel? reminder,
    WidgetRef? ref,
    Duration? customDuration,
    bool isNoRush = false,
  }) {
    if (ref == null) {
      final ProviderContainer container = ProviderContainer();
      if (reminder != null) {
        container.read(sheetReminderNotifier).loadValues(reminder);
      } else {
        container.read(sheetReminderNotifier).resetValuesWith(
              customDuration: customDuration,
              isNoRush: isNoRush,
            );
      }

      container.read(centralWidgetNotifierProvider.notifier).reset();
    } else {
      if (reminder != null) {
        ref.read(sheetReminderNotifier).loadValues(reminder);
      } else {
        ref.read(sheetReminderNotifier).resetValuesWith(
              customDuration: customDuration,
              isNoRush: isNoRush,
            );
      }

      ref.read(centralWidgetNotifierProvider.notifier).reset();
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => const ReminderSheet(),
    );
  }
}
