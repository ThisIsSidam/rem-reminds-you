import 'package:flutter/material.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/reminder_pg_utils/rs_field.dart';
import 'package:nagger/utils/reminder_pg_utils/title_parser/title_parser.dart';

class InputFields {
  static Widget titleField(
    BuildContext context,
    Reminder thisReminder,
    FieldType currentFieldType,
    FocusNode _titleFocusNode,
    TitleParser titleParser,
    bool titleParsedDateTimeFound,
    Reminder titleParsedReminder,
    void Function(Reminder) saveTitleParsedReminderOptions,
    void Function(FieldType) changeCurrentInputField,
  ) {
    return RS_Field(
      fieldType: FieldType.Title,
      currentFieldType: currentFieldType,
      label: "Title",
      thisReminder: thisReminder,
      fieldWidget: TextFormField(
        autofocus: true,
        focusNode: _titleFocusNode,
        initialValue: thisReminder.id == newReminderID ? null : thisReminder.title,
        textCapitalization: TextCapitalization.sentences,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (String str) {
          thisReminder.title = str;
          bool done = titleParser.parse(str);

          titleParsedDateTimeFound = done;
        },
        onFieldSubmitted: (String str) {
          changeCurrentInputField(FieldType.Title);
        },
      ),
    );
  }

  static Widget titleParsedDateTimeField(
    BuildContext context,
    FieldType currentFieldType,
    Reminder titleParsedReminder,
    void Function(Reminder) saveReminderOptions,
  ) {
    return RS_Field(
      fieldType: FieldType.ParsedTime,
      currentFieldType: currentFieldType,
      label: "Parsed Time",
      thisReminder: titleParsedReminder,
      fieldWidget: ListTile(
        contentPadding: EdgeInsets.only(right: 0),
        title: Text(
          titleParsedReminder.getDateTimeAsStr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          titleParsedReminder.getDiffString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: MaterialButton(
          child: const Icon(Icons.check_box),
          onPressed: () {
            saveReminderOptions(titleParsedReminder);
          },
        ),
      ),
    );
  }

  static Widget dateTimeField(
    BuildContext context,
    Reminder thisReminder,
    FieldType currentFieldType,
    void Function(FieldType) setCurrentInputField,
  ) {
    return RS_Field(
      fieldType: FieldType.Time,
      currentFieldType: currentFieldType,
      label: "Time",
      fieldWidget: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 2
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              thisReminder.getDateTimeAsStr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              thisReminder.getDiffString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      thisReminder: thisReminder,
      getFocus: setCurrentInputField,
    );
  }

  static Widget repetitionCountField(
    BuildContext context,
    Reminder thisReminder,
    FieldType currentFieldType,
    void Function(FieldType) setCurrentInputField,
  ) {
    return RS_Field(
      fieldType: FieldType.R_Count,
      currentFieldType: currentFieldType,
      label: "Repeat",
      fieldWidget: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 2
        ),
        child: Text(
          "${thisReminder.repetitionCount.toString()} times",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      thisReminder: thisReminder,
      getFocus: setCurrentInputField,
    );
  }

  static Widget repetitionIntervalField(
    BuildContext context,
    Reminder thisReminder,
    FieldType currentFieldType,
    void Function(FieldType) setCurrentInputField,
  ) {
    return RS_Field(
      fieldType: FieldType.R_Interval,
      currentFieldType: currentFieldType,
      label: "Interval",
      fieldWidget: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 2
        ),
        child: Text(
          "Every ${thisReminder.getIntervalString()}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      thisReminder: thisReminder,
      getFocus: setCurrentInputField,
    );
  }
}