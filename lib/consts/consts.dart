import 'package:Rem/reminder_class/reminder.dart';

const appName = "Rem";

final Reminder nullReminder = Reminder(dateAndTime: DateTime.now());
final Reminder newReminder = Reminder(dateAndTime: DateTime.now());

const remindersBoxName = "reminders";
const remindersBoxKey = "REMINDERS";

const archivesBoxName = "archives";
const archivesKey = "ARCHIVES";

const pendingRemovalsBoxName = "pending_removals";
const pendingRemovalsBoxKey = "PENDING_REMOVAL";

const indiValuesBoxName = "indi_values";
const reminderIDGeneratorCurrentCountKey = "reminder_id_generator_current_count";


// Isolate names
String bg_isolate_name = "background_service_isolate";

const materialButtonCloseText = "Close";
const materialButtonSaveText = "Save";
const noRemindersPageText = "You currently don't have any reminders!";

const overdueSectionTitle = "Overdue";
const todaySectionTitle = "Today";
const tomorrowSectionTitle = "Tomorrow";
const laterSectionTitle = "Later";

const timeSetButton0930AM = "9:30 AM";
const timeSetButton12PM = "12:00 PM";
const timeSetButton0630PM = "6:30 AM";
const timeSetButton10PM = "10:00 PM";

const newReminderID = -100;
const reminderNullTitle = "No Title";
const reminderNullID = -1;
const reminderDefaultRepetitionCount = 5;
const notificationNullGroupKey = "Null";

const reminderSectionFieldsLeftMarginSmall = 50.0;
const reminderSectionFieldsLeftMarginLarge = 150.0;

const String repetitionIntervalHourly = 'Hourly';