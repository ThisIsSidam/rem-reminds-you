import 'package:Rem/core/models/reminder_model/reminder_model.dart';
import 'package:Rem/feature/reminder_sheet/presentation/providers/central_widget_provider.dart';
import 'package:Rem/feature/reminder_sheet/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_sheet/presentation/sheet/reminder_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderSheetHelper {
  static openSheet({
    required BuildContext context,
    ReminderModel? reminder,
    WidgetRef? ref,
    Duration? customDuration,
    bool isNoRush = false,
  }) {
    if (ref == null) {
      final container = ProviderContainer();
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReminderSheet(),
    );
  }
}
