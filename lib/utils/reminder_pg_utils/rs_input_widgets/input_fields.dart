import 'package:flutter/material.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/reminder_pg_utils/rs_field.dart';
import 'package:nagger/utils/reminder_pg_utils/title_parser/title_parser.dart';

class InputFields {
  final BuildContext context;
  final Reminder thisReminder;
  final FieldType currentFieldType;
  final FocusNode titleFocusNode;
  final TitleParser titleParser;
  bool titleParsedDateTimeFound;
  final Reminder titleParsedReminder;
  final void Function(Reminder) saveTitleParsedReminderOptions;
  final void Function(FieldType) changeCurrentInputWidget;
  final void Function(Reminder) saveReminderOptions;
  final void Function(FieldType) setCurrentInputWidget;

  InputFields({
    required this.context,
    required this.thisReminder,
    required this.currentFieldType,
    required this.titleFocusNode,
    required this.titleParser,
    required this.titleParsedDateTimeFound,
    required this.titleParsedReminder,
    required this.saveTitleParsedReminderOptions,
    required this.changeCurrentInputWidget,
    required this.saveReminderOptions,
    required this.setCurrentInputWidget,
  });

  Widget titleField() {
    return RS_Field(
      fieldType: FieldType.Title,
      currentFieldType: currentFieldType,
      label: "Title",
      thisReminder: thisReminder,
      fieldWidget: TextFormField(
        autofocus: thisReminder.id == newReminderID,
        focusNode: titleFocusNode,
        initialValue: thisReminder.id == newReminderID ? null : thisReminder.title,
        textCapitalization: TextCapitalization.sentences,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (String str) {
          thisReminder.title = str;
          bool done = titleParser.parse(str);
          titleParsedDateTimeFound = done;
        },
        onFieldSubmitted: (String str) {
          changeCurrentInputWidget(FieldType.Title);
        },
      ),
    );
  }

  Widget titleParsedDateTimeField() {
    
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

  Widget dateTimeField() {
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
      getFocus: setCurrentInputWidget,
    );
  }

  Widget repetitionCountField() {
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
      getFocus: setCurrentInputWidget,
    );
  }

  Widget repetitionIntervalField() {
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
      getFocus: setCurrentInputWidget,
    );
  }
}