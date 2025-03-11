import 'package:flutter/material.dart';

import '../../../core/data/models/reminder_base/reminder_base.dart';
import 'sheet/reminder_sheet.dart';

class SheetHelper {
  void openReminderSheet(
    BuildContext context, {
    ReminderBase? reminder,
    Duration? customDuration,
    bool isNoRush = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => ReminderSheet(
        reminder: reminder,
        isNoRush: isNoRush,
        customDuration: customDuration,
      ),
    );
  }
}
