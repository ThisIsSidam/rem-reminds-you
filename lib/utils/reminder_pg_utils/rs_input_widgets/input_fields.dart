import 'package:flutter/material.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/pages/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/reminder_pg_utils/rs_input_widgets/rs_field.dart';
import 'package:Rem/utils/reminder_pg_utils/title_parser/title_parser.dart';

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
          titleParsedReminder.getDateTimeAsStr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          titleParsedReminder.getDiffString(),
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

  Widget recurringIntervalField() {
    return RS_Field(
      fieldType: FieldType.Rec_Interval,
      currentFieldType: currentFieldType,
      label: "Recurrening Interval",
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

  Widget repeatReminderField() {
    return RS_Field(
      fieldType: FieldType.Repeat, 
      currentFieldType: currentFieldType, 
      label: "Repeat Notification", 
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