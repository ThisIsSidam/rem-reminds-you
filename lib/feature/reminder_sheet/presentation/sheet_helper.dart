import 'package:flutter/material.dart';

import '../../../core/models/reminder_model/reminder_model.dart';
import 'sheet/reminder_sheet.dart';

class SheetHelper {
  void openReminderSheet(
    BuildContext context, {
    ReminderModel? reminder,
    Duration? customDuration,
    bool isNoRush = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.white38,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => ReminderSheet(
        reminder: reminder,
      ),
    );
  }
}
