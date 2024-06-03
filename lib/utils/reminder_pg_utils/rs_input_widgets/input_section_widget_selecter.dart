import 'package:flutter/material.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/reminder_pg_utils/rs_input_widgets/datetime_input.dart';
import 'package:nagger/utils/reminder_pg_utils/rs_input_widgets/input_section.dart';
import 'package:nagger/utils/reminder_pg_utils/rs_input_widgets/recurring_frequency.dart';
import 'package:nagger/utils/reminder_pg_utils/rs_input_widgets/rep_interval_input.dart';

class InputSectionWidgetSelector {
  static Widget showInputSection(
    FieldType currentFieldType,
    Reminder thisReminder,
    void Function(Reminder) saveReminderOptions,
    void Function(FieldType) changeCurrentInputField,
  ) {
    if (currentFieldType == FieldType.Time) 
    {
      return RS_InputSection(
        child: RS_DatetimeInput(
          thisReminder: thisReminder,
          save: saveReminderOptions,
          moveFocus: changeCurrentInputField,
        ),
      );
    } 
    else if (currentFieldType == FieldType.R_Interval) 
    {
      return RS_InputSection(
        child: RS_RepIntervalInput(
          thisReminder: thisReminder,
          save: saveReminderOptions,
          moveFocus: changeCurrentInputField,
        ),
      );
    }
    else
    {
      return RS_InputSection(
        child: RS_RecurringFrequencyInput(
          thisReminder: thisReminder, 
          save: saveReminderOptions, 
          moveFocus: changeCurrentInputField
        )
      );
    } 
  }
}