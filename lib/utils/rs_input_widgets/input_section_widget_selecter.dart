import 'package:flutter/material.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/rs_input_widgets/rs_datetime_input.dart';
import 'package:nagger/utils/rs_input_widgets/rs_input_section.dart';
import 'package:nagger/utils/rs_input_widgets/rs_rep_count_input.dart';
import 'package:nagger/utils/rs_input_widgets/rs_rep_interval_input.dart';

class InputSections {
  static Widget showInputSection(
    FieldType currentFieldType,
    Reminder thisReminder,
    void Function(Reminder) saveReminderOptions,
    void Function(FieldType) changeCurrentInputField,
  ) {
    if (currentFieldType == FieldType.Time) {
      return RS_InputSection(
        child: RS_DatetimeInput(
          thisReminder: thisReminder,
          save: saveReminderOptions,
          moveFocus: changeCurrentInputField,
        ),
      );
    } else if (currentFieldType == FieldType.R_Count) {
      return RS_InputSection(
        child: RS_RepCountInput(
          thisReminder: thisReminder,
          save: saveReminderOptions,
          moveFocus: changeCurrentInputField,
        ),
      );
    } else {
      return RS_InputSection(
        child: RS_RepIntervalInput(
          thisReminder: thisReminder,
          save: saveReminderOptions,
          moveFocus: changeCurrentInputField,
        ),
      );
    }
  }
}