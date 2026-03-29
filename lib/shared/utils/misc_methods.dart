import 'package:flutter/material.dart';

class MiscMethods {
  static Future<void> removeKeyboard(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool isKeyboardVisible = true;
    // Schedule a callback to be executed after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    });
    // Keep checking for keyboard visibility in a loop
    while (isKeyboardVisible) {
      // Delay for a short duration before checking again
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Check if the keyboard is still visible
      if (!context.mounted) return;
      isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    }
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  static DateTime getAgendaDateTime(TimeOfDay time) {
    final now = DateTime.now();
    final agendaDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (agendaDateTime.isBefore(now)) {
      return agendaDateTime.add(const Duration(days: 1));
    } else {
      return agendaDateTime;
    }
  }
}
