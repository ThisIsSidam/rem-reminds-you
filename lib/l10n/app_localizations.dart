import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Text for 'retry' buttons
  ///
  /// In en, this message translates to:
  /// **'retry'**
  String get retry;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get somethingWentWrong;

  /// Title of homescreen
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get homeTitle;

  /// Section title for overdue reminders
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get homeSectionOverdue;

  /// Section title for today reminders
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeSectionToday;

  /// Section title for tomorrow reminders
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get homeSectionTomorrow;

  /// Section title for later reminders
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get homeSectionLater;

  /// Section title for no-rush reminders
  ///
  /// In en, this message translates to:
  /// **'No Rush'**
  String get homeSectionNoRush;

  /// Message shown when no reminders exist
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any reminders!'**
  String get emptyReminders;

  /// Button text for creating a new reminder
  ///
  /// In en, this message translates to:
  /// **'Set a reminder'**
  String get setReminder;

  /// Button text for resuming a recurring reminder
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get actionResume;

  /// Button text for pausing a recurring reminder
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get actionPause;

  /// Text describing undo action in snackbars
  ///
  /// In en, this message translates to:
  /// **'Tap to undo'**
  String get actionTapToUndo;

  /// Verb used for deleted reminder snackbar message
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get actionDeleted;

  /// Verb used for postponed reminder snackbar message
  ///
  /// In en, this message translates to:
  /// **'postponed.'**
  String get actionPostponed;

  /// Text used for moved-to-next-occurrence snackbar message
  ///
  /// In en, this message translates to:
  /// **'moved to next occurrence.'**
  String get actionMovedNextOccurrence;

  /// Drag zone text for overdue section
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong!'**
  String get dragZoneOverdue;

  /// Drag zone text for today section
  ///
  /// In en, this message translates to:
  /// **'Set for Today'**
  String get dragZoneToday;

  /// Drag zone text for tomorrow section
  ///
  /// In en, this message translates to:
  /// **'Set for Tomorrow'**
  String get dragZoneTomorrow;

  /// Drag zone text for later section
  ///
  /// In en, this message translates to:
  /// **'Schedule for Later'**
  String get dragZoneLater;

  /// Drag zone text for no rush section
  ///
  /// In en, this message translates to:
  /// **'Save to No rush'**
  String get dragZoneNoRush;

  /// Title for notification permission section
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get permissionNotificationTitle;

  /// Text indicating permission is required
  ///
  /// In en, this message translates to:
  /// **' (Required)'**
  String get permissionRequired;

  /// Description for notification permission
  ///
  /// In en, this message translates to:
  /// **'We\'d love to remind you about your tasks, but we can\'t do that without notifications.'**
  String get permissionNotificationDescription;

  /// Title for alarm permission section
  ///
  /// In en, this message translates to:
  /// **'Alarm Permission'**
  String get permissionAlarmTitle;

  /// Description for alarm permission
  ///
  /// In en, this message translates to:
  /// **'To make sure reminders ring on time, we need access to your device\'s alarm system.'**
  String get permissionAlarmDescription;

  /// Title for battery permission section
  ///
  /// In en, this message translates to:
  /// **'Battery Permission'**
  String get permissionBatteryTitle;

  /// Text indicating permission is recommended
  ///
  /// In en, this message translates to:
  /// **' (Recommended)'**
  String get permissionRecommended;

  /// Description for battery permission
  ///
  /// In en, this message translates to:
  /// **'Your device may restrict notifications to save battery. Allow unrestricted battery use to receive reminders on time.'**
  String get permissionBatteryDescription;

  /// Button text to allow permission
  ///
  /// In en, this message translates to:
  /// **'Allow Permission'**
  String get permissionAllow;

  /// Button text to set battery as unrestricted
  ///
  /// In en, this message translates to:
  /// **'Set as Unrestricted'**
  String get permissionSetUnrestricted;

  /// Button text to continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get permissionContinue;

  /// Button text to continue to the app
  ///
  /// In en, this message translates to:
  /// **'Continue to app'**
  String get permissionContinueToApp;

  /// Label for title input field in reminder sheet
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sheetTitle;

  /// Error message when title is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a title!'**
  String get sheetEnterTitleError;

  /// Error message when reminder time is in the past
  ///
  /// In en, this message translates to:
  /// **'Can\'t remind you in the past!'**
  String get sheetPastTimeError;

  /// Button text to save the reminder
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get sheetSave;

  /// Button text to apply changes to all recurring instances
  ///
  /// In en, this message translates to:
  /// **'For All'**
  String get sheetForAll;

  /// Button text to postpone the reminder
  ///
  /// In en, this message translates to:
  /// **'Postpone'**
  String get sheetPostpone;

  /// Title of dialog for deleting recurring reminders
  ///
  /// In en, this message translates to:
  /// **'Recurring Reminder'**
  String get sheetRecurringDialogTitle;

  /// Content of dialog for deleting recurring reminders
  ///
  /// In en, this message translates to:
  /// **'This is a recurring reminder. Do you really want to delete it? You can also archive it.'**
  String get sheetRecurringDialogContent;

  /// Button text to cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sheetCancel;

  /// Button text to delete reminder
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sheetDelete;

  /// Text indicating time in the past
  ///
  /// In en, this message translates to:
  /// **'{duration} ago'**
  String sheetAgo(String duration);

  /// Text indicating time in the future
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String sheetIn(String duration);

  /// Title of settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title of dialog for resetting settings
  ///
  /// In en, this message translates to:
  /// **'Reset settings to default?'**
  String get settingsResetDialogTitle;

  /// Negative response button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get settingsNo;

  /// Positive response button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get settingsYes;

  /// Label for theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Label for text scale setting
  ///
  /// In en, this message translates to:
  /// **'Text Scale'**
  String get settingsTextScale;

  /// Label for postpone duration setting
  ///
  /// In en, this message translates to:
  /// **'Postpone Duration'**
  String get settingsPostponeDuration;

  /// Duration option for 15 minutes
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get settings15Min;

  /// Duration option for 30 minutes
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get settings30Min;

  /// Duration option for 45 minutes
  ///
  /// In en, this message translates to:
  /// **'45 min'**
  String get settings45Min;

  /// Duration option for 1 hour
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get settings1Hour;

  /// Duration option for 2 hours
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get settings2Hours;

  /// Label for no rush hours setting
  ///
  /// In en, this message translates to:
  /// **'No rush hours'**
  String get settingsNoRushHours;

  /// Description for no rush hours setting
  ///
  /// In en, this message translates to:
  /// **'No rush reminders are shown only within this time range, so that you only get notified when you want to.'**
  String get settingsNoRushDescription;

  /// Title for swipe to left actions setting
  ///
  /// In en, this message translates to:
  /// **'Swipe to Left Actions'**
  String get settingsSwipeToLeftActions;

  /// Label for swipe left demonstration
  ///
  /// In en, this message translates to:
  /// **'Swipe Left'**
  String get settingsSwipeLeft;

  /// Title for swipe to right actions setting
  ///
  /// In en, this message translates to:
  /// **'Swipe to Right Actions'**
  String get settingsSwipeToRightActions;

  /// Label for swipe right demonstration
  ///
  /// In en, this message translates to:
  /// **'Swipe Right'**
  String get settingsSwipeRight;

  /// Section title for gestures settings
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get settingsGestures;

  /// Section title for new reminder settings
  ///
  /// In en, this message translates to:
  /// **'New Reminder'**
  String get settingsNewReminder;

  /// Label for default lead duration setting
  ///
  /// In en, this message translates to:
  /// **'Default lead duration'**
  String get settingsDefaultLeadDuration;

  /// Prefix for recurring duration display
  ///
  /// In en, this message translates to:
  /// **'Every {duration}'**
  String settingsEvery(String duration);

  /// Label for default auto snooze duration setting
  ///
  /// In en, this message translates to:
  /// **'Default auto snooze duration'**
  String get settingsDefaultAutoSnoozeDuration;

  /// Label for quick time table setting
  ///
  /// In en, this message translates to:
  /// **'Quick time table'**
  String get settingsQuickTimeTable;

  /// Label for snooze options setting
  ///
  /// In en, this message translates to:
  /// **'Snooze options'**
  String get settingsSnoozeOptions;

  /// Title for default lead duration modal
  ///
  /// In en, this message translates to:
  /// **'Default Lead Duration'**
  String get settingsDefaultLeadDurationTitle;

  /// Title for default auto snooze duration modal
  ///
  /// In en, this message translates to:
  /// **'Default Auto Snooze Duration'**
  String get settingsDefaultAutoSnoozeDurationTitle;

  /// Title for quick time table modal
  ///
  /// In en, this message translates to:
  /// **'Quick Time Table'**
  String get settingsQuickTimeTableTitle;

  /// Title for snooze options modal
  ///
  /// In en, this message translates to:
  /// **'Snooze Options'**
  String get settingsSnoozeOptionsTitle;

  /// Section title for backup and restore settings
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore (Experimental)'**
  String get settingsBackupRestore;

  /// Label for backup action
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// Message when no directory is selected for backup
  ///
  /// In en, this message translates to:
  /// **'No directory selected'**
  String get settingsNoDirectorySelected;

  /// Success message for backup creation
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get settingsBackupCreated;

  /// Error message for backup failure
  ///
  /// In en, this message translates to:
  /// **'Backup failed!'**
  String get settingsBackupFailed;

  /// Label for restore action
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingsRestore;

  /// Message when no file is selected for restore
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get settingsNoFileSelected;

  /// Success message for backup restore
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get settingsBackupRestored;

  /// Error message for backup restore failure
  ///
  /// In en, this message translates to:
  /// **'Backup restore failed!'**
  String get settingsRestoreFailed;

  /// Section title for logs settings
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get settingsLogs;

  /// Label for getting log file action
  ///
  /// In en, this message translates to:
  /// **'Get log file'**
  String get settingsGetLogFile;

  /// Success message for logs export
  ///
  /// In en, this message translates to:
  /// **'Logs saved successfully'**
  String get settingsLogsSaved;

  /// Error message for logs export failure
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export logs!'**
  String get settingsExportLogsFailed;

  /// Label for clearing all logs action
  ///
  /// In en, this message translates to:
  /// **'Clear all logs'**
  String get settingsClearAllLogs;

  /// Success message for logs deletion
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted all logs'**
  String get settingsLogsDeleted;

  /// Section title for other settings
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get settingsOther;

  /// Label for what's new dialog
  ///
  /// In en, this message translates to:
  /// **'What\'s New?'**
  String get settingsWhatsNew;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
