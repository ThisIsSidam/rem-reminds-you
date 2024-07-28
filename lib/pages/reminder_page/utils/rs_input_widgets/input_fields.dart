import 'package:Rem/utils/functions/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/pages/reminder_page/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/pages/reminder_page/utils/rs_input_widgets/rs_field.dart';
import 'package:Rem/pages/reminder_page/utils/title_parser/title_parser.dart';

class InputFields {
  final BuildContext context;
  final Reminder thisReminder;
  final FieldType currentFieldType;
  final FocusNode titleFocusNode;
  final TitleParser titleParser;
  bool titleParsedDateTimeFound;
  final Reminder titleParsedReminder;
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
          titleParser.parse(str);
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
      padding: EdgeInsets.only(
        left:10, right: 10, top: 0, bottom: 0
      ),
      fieldWidget: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          getFormattedDateTime(titleParsedReminder.dateAndTime),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          getFormattedDiffString(dateTime: titleParsedReminder.dateAndTime),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: MaterialButton(
          child: const Icon(Icons.done),
          color: Theme.of(context).primaryColor,
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
              getFormattedDateTime(thisReminder.dateAndTime),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              getFormattedDiffString(dateTime: thisReminder.dateAndTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      thisReminder: thisReminder,
      getFocus: setCurrentInputWidget,
    );
  }

  Widget repeatNotifInterval() {
    return RS_Field(
      fieldType: FieldType.Rec_Interval,
      currentFieldType: currentFieldType,
      label: "Repeat Notification",
      fieldWidget: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 2
        ),
        child: Text(
          "Every ${formatDuration(thisReminder.notifRepeatInterval)}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      thisReminder: thisReminder,
      getFocus: setCurrentInputWidget,
    );
  }

  Widget recurringReminderField() {
    return RS_Field(
      fieldType: FieldType.Repeat, 
      currentFieldType: currentFieldType, 
      label: "Recurring Reminder", 
      fieldWidget: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 2
        ),
        child: Text(
          thisReminder.getRecurringIntervalAsString(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ), 
      thisReminder: thisReminder,
      getFocus: setCurrentInputWidget,
    );
  }
}