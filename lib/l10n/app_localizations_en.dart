// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'retry';

  @override
  String get somethingWentWrong => 'Something went wrong!';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersSectionOverdue => 'Overdue';

  @override
  String get remindersSectionToday => 'Today';

  @override
  String get remindersSectionTomorrow => 'Tomorrow';

  @override
  String get remindersSectionLater => 'Later';

  @override
  String get remindersSectionNoRush => 'No Rush';

  @override
  String get emptyReminders => 'You don\'t have any reminders!';

  @override
  String get setReminder => 'Set a reminder';

  @override
  String get actionResume => 'Resume';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionTapToUndo => 'Tap to undo';

  @override
  String get actionDeleted => 'deleted';

  @override
  String get actionPostponed => 'postponed.';

  @override
  String get actionMovedNextOccurrence => 'moved to next occurrence.';

  @override
  String get dragZoneOverdue => 'Something Went Wrong!';

  @override
  String get dragZoneToday => 'Set for Today';

  @override
  String get dragZoneTomorrow => 'Set for Tomorrow';

  @override
  String get dragZoneLater => 'Schedule for Later';

  @override
  String get dragZoneNoRush => 'Save to No rush';

  @override
  String get permissionNotificationTitle => 'Notification Permission';

  @override
  String get permissionRequired => ' (Required)';

  @override
  String get permissionNotificationDescription =>
      'We\'d love to remind you about your tasks, but we can\'t do that without notifications.';

  @override
  String get permissionAlarmTitle => 'Alarm Permission';

  @override
  String get permissionAlarmDescription =>
      'To make sure reminders ring on time, we need access to your device\'s alarm system.';

  @override
  String get permissionBatteryTitle => 'Battery Permission';

  @override
  String get permissionRecommended => ' (Recommended)';

  @override
  String get permissionBatteryDescription =>
      'Your device may restrict notifications to save battery. Allow unrestricted battery use to receive reminders on time.';

  @override
  String get permissionAllow => 'Allow Permission';

  @override
  String get permissionSetUnrestricted => 'Set as Unrestricted';

  @override
  String get permissionContinue => 'Continue';

  @override
  String get permissionContinueToApp => 'Continue to app';

  @override
  String get sheetTitle => 'Title';

  @override
  String get sheetEnterTitleError => 'Enter a title!';

  @override
  String get sheetPastTimeError => 'Can\'t remind you in the past!';

  @override
  String get sheetSave => 'Save';

  @override
  String get sheetForAll => 'For All';

  @override
  String get sheetPostpone => 'Postpone';

  @override
  String get sheetRecurringDialogTitle => 'Recurring Reminder';

  @override
  String get sheetRecurringDialogContent =>
      'This is a recurring reminder. Do you really want to delete it?';

  @override
  String get sheetCancel => 'Cancel';

  @override
  String get sheetConfirm => 'Yes';

  @override
  String sheetAgo(String duration) {
    return '$duration ago';
  }

  @override
  String sheetIn(String duration) {
    return 'in $duration';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsResetDialogTitle => 'Reset settings to default?';

  @override
  String get settingsNo => 'No';

  @override
  String get settingsYes => 'Yes';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsTextScale => 'Text Scale';

  @override
  String get settingsPostponeDuration => 'Postpone Duration';

  @override
  String get settings15Min => '15 min';

  @override
  String get settings30Min => '30 min';

  @override
  String get settings45Min => '45 min';

  @override
  String get settings1Hour => '1 hour';

  @override
  String get settings2Hours => '2 hours';

  @override
  String get settingsNoRushHours => 'No rush hours';

  @override
  String get settingsNoRushDescription =>
      'No rush reminders are shown only within this time range, so that you only get notified when you want to.';

  @override
  String get settingsFrom => 'From';

  @override
  String get settingsTo => 'To';

  @override
  String get settingsSwipeToLeftActions => 'Swipe to Left Actions';

  @override
  String get settingsSwipeLeft => 'Swipe Left';

  @override
  String get settingsSwipeToRightActions => 'Swipe to Right Actions';

  @override
  String get settingsSwipeRight => 'Swipe Right';

  @override
  String get settingsGestures => 'Gestures';

  @override
  String get settingsNewReminder => 'New Reminder';

  @override
  String get settingsDefaultLeadDuration => 'Default lead duration';

  @override
  String settingsEvery(String duration) {
    return 'Every $duration';
  }

  @override
  String get settingsDefaultAutoSnoozeDuration =>
      'Default auto snooze duration';

  @override
  String get settingsQuickTimeTable => 'Quick time table';

  @override
  String get settingsSnoozeOptions => 'Snooze options';

  @override
  String get settingsDefaultLeadDurationTitle => 'Default Lead Duration';

  @override
  String get settingsDefaultAutoSnoozeDurationTitle =>
      'Default Auto Snooze Duration';

  @override
  String get settingsQuickTimeTableTitle => 'Quick Time Table';

  @override
  String get settingsSnoozeOptionsTitle => 'Snooze Options';

  @override
  String get settingsBackupRestore => 'Backup & Restore (Experimental)';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsNoDirectorySelected => 'No directory selected';

  @override
  String get settingsBackupCreated => 'Backup created successfully';

  @override
  String get settingsBackupFailed => 'Backup failed!';

  @override
  String get settingsRestore => 'Restore';

  @override
  String get settingsNoFileSelected => 'No file selected';

  @override
  String get settingsBackupRestored => 'Backup restored successfully';

  @override
  String get settingsRestoreFailed => 'Backup restore failed!';

  @override
  String get settingsLogs => 'Logs';

  @override
  String get settingsGetLogFile => 'Get log file';

  @override
  String get settingsLogsSaved => 'Logs saved successfully';

  @override
  String get settingsExportLogsFailed => 'Couldn\'t export logs!';

  @override
  String get settingsClearAllLogs => 'Clear all logs';

  @override
  String get settingsLogsDeleted => 'Successfully deleted all logs';

  @override
  String get settingsOther => 'Other';

  @override
  String get settingsWhatsNew => 'What\'s New?';

  @override
  String get agendaTitle => 'Agenda';

  @override
  String get agendaNoTasks => 'No tasks for this day.';

  @override
  String get agendaToday => 'Today';

  @override
  String get agendaTomorrow => 'Tomorrow';

  @override
  String get agendaDayAfter => 'Day After';

  @override
  String get agendaTaskTitle => 'Task Title';

  @override
  String get agendaEnterTaskHint => 'Enter task...';

  @override
  String get agendaTapToCreateTask => 'Tap card to create new task';

  @override
  String get settingsAgendaTimeTitle => 'When to show Agenda?';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsUseSystemFont => 'Use system font';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsAgenda => 'Agenda Settings';

  @override
  String get settingsPersonalization => 'Personalization';

  @override
  String get settingsReminders => 'Reminder Settings';

  @override
  String get swipeActionNone => 'None';

  @override
  String get swipeActionDone => 'Done';

  @override
  String get swipeActionDelete => 'Delete';

  @override
  String get swipeActionPostpone => 'Postpone';

  @override
  String get swipeActionDoneAndDelete => 'Done/Delete';

  @override
  String get settingsRestoreNoRush => 'No Rush Reminders';

  @override
  String get settingsRestoreAgenda => 'Agenda Tasks';

  @override
  String get settingsRestoreNotFound => 'Backup not found';

  @override
  String get settingsRestoreError => 'Failed to restore';

  @override
  String get settingsLabelOk => 'OK';

  @override
  String get recurrenceSelectInterval => 'Select Recurrence Interval';
}
