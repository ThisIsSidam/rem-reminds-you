import 'package:nagger/reminder_class/reminder.dart';

const appName = "Nagger";

final Reminder nullReminder = Reminder(dateAndTime: DateTime.now());
final Reminder newReminder = Reminder(dateAndTime: DateTime.now().add(Duration(seconds: 5)));

const remindersBoxName = "reminders";
const remindersBoxKey = "REMINDERS";

const pendingRemovalsBoxName = "pending_removals";
const pendingRemovalsBoxKey = "PENDING_REMOVAL";


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

const newReminderID = 101;
const reminderNullTitle = "No Title";
const reminderNullID = 7;
const reminderDefaultRepetitionCount = 5;
const notificationNullGroupKey = "Null";

const reminderSectionFieldsLeftMargin = 75.0;

const String repetitionIntervalHourly = 'Hourly';