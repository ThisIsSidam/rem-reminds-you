// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../app/constants/const_strings.dart';
import '../../../feature/reminder_sheet/presentation/sheet_helper.dart';
import '../../../main.dart';
import '../../../objectbox.g.dart';
import '../../../shared/utils/id_handler.dart';
import '../../../shared/utils/logger/app_logger.dart';
import '../../data/models/reminder.dart';
import '../../data/models/reminder_base.dart';
import 'notification_action_handler.dart';
import 'notification_channels.dart';

class NotificationController {
  static Future<void> initializeLocalNotifications() async {
    await AndroidAlarmManager.initialize();

    await AwesomeNotifications().initialize(
      null,
      NotificationChannels.channels,
    );

    AppLogger.i('Initialized Notifications');
  }

  static Future<bool> checkNotificationPermissions() async {
    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    return isAllowed;
  }

  static Future<bool> requestNotificationPermission() async {
    return AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<bool> scheduleNotification(ReminderBase reminder) async {
    final int id = reminder.id;

    final DateTime scheduledTime = reminder.dateTime;

    AppLogger.i('Notification Scheduled | ID: $id | DT : $scheduledTime');
    final Map<String, String?> params = reminder.toJson();

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      IdHandler().getAlarmId(reminder),
      showNotificationCallback,
      allowWhileIdle: true,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: params,
    );

    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> showNotificationCallback(
    int id,
    Map<String, dynamic> params,
  ) async {
    await AppLogger.init();
    AppLogger.i('Notification Callback Running | callBackId: $id');

    final Map<String, String> strParams = params.cast<String, String>();
    final ReminderBase reminder = ReminderBase.fromJson(strParams);

    // Should be different each time so that different notifications are shown.
    final int notificationId = IdHandler().getNotificationId(reminder.id);
    final Map<String, String?> payload = reminder.toJson();

    AppLogger.i('Showing notification | notificationID: $notificationId');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: NotificationChannels.reminder.key,
        title: 'Reminder: ${reminder.title}',
        groupKey: IdHandler().getGroupKey(reminder),
        wakeUpScreen: true,
        payload: payload,
      ),
      actionButtons: <NotificationActionButton>[
        NotificationActionButton(
          key: 'done',
          label: 'Done',
          actionType: ActionType.SilentBackgroundAction,
        ),
        NotificationActionButton(
          key: 'postpone',
          label: 'Postpone',
          actionType: ActionType.SilentBackgroundAction,
        ),
      ],
    );

    final DateTime nextScheduledTime = reminder.dateTime.add(
      reminder.autoSnoozeInterval,
    );
    reminder.dateTime = nextScheduledTime;
    await scheduleNotification(reminder);
    AppLogger.i(
      'Scheduled Next Notif | ID : ${reminder.id} | DT : ${reminder.dateTime}',
    );
  }

  /// Used to remove notifications present in user's notification space.
  static Future<void> removeNotifications(String? groupKey) async {
    if (groupKey == null) {
      AppLogger.w('Received null groupKey in removeNotifications');
      return;
    }

    await AwesomeNotifications().cancelNotificationsByGroupKey(groupKey);
    AppLogger.i('Cleared present notifications | gKey : $groupKey');
  }

  /// Cancels the scheduled notification.
  static Future<void> cancelScheduledNotification(String? groupKey) async {
    if (groupKey == null) {
      AppLogger.w('Received null groupKey in cancelScheduleNotification');
      return;
    }

    // Cancelling through ALM coz AwesomeN is used to only send notification.
    // It has no hands in scheduling notifications.
    await AndroidAlarmManager.cancel(int.tryParse(groupKey) ?? -1);
    await removeNotifications(groupKey);
    AppLogger.i('Cancelled scheduled notifications | gKey : $groupKey');
  }

  static Future<void> startListeningNotificationEvents() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );

    AppLogger.i('Started Listening to notification events');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    await AppLogger.init();
    AppLogger.i(
      'Received notification action | Action : ${receivedAction.actionType}',
    );
    if (receivedAction.payload == null) return;
    final ReminderBase reminder = ReminderBase.fromJson(
      receivedAction.payload!,
    );
    await cancelScheduledNotification(
      receivedAction.groupKey ?? notificationNullGroupKey,
    );
    final Store store = await getObjectboxStore();
    final NotificationActionHandler actionHandler = NotificationActionHandler(
      reminder: reminder,
      store: store,
    );

    if (receivedAction.buttonKeyPressed == 'done') {
      actionHandler.donePressed();
    } else if (receivedAction.buttonKeyPressed == 'postpone') {
      await actionHandler.postponePressed();
    }
    store.close();
  }

  static Future<void> handleInitialCallback(WidgetRef ref) async {
    final ReceivedAction? initialAction = await AwesomeNotifications()
        .getInitialNotificationAction();

    if (initialAction == null) return;
    if (initialAction.actionType != ActionType.Default) return;

    final Map<String, String?>? payload = initialAction.payload;
    if (payload == null) {
      AppLogger.e(
        'Received null payload through notification action | gKey : ${initialAction.groupKey}',
      );
      throw 'Received null payload through notification action | gKey : ${initialAction.groupKey}';
    }

    final BuildContext context = navigatorKey.currentContext!;
    final ReminderModel reminder = ReminderModel.fromJson(payload);

    if (context.mounted) {
      AppLogger.i(
        'Notification action : Showing bottom sheet | rId : ${reminder.id} | gKey : ${initialAction.groupKey}',
      );
      SheetHelper().openReminderSheet(context, reminder: reminder);
    }
    await removeNotifications(initialAction.groupKey);
  }

  @pragma('vm:entry-point')
  static Future<Store> getObjectboxStore() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    if (Store.isOpen(path.join(dir.path, 'objectbox-activity-store'))) {
      return Store.attach(
        getObjectBoxModel(),
        path.join(dir.path, 'objectbox-activity-store'),
      );
    } else {
      return Store(
        getObjectBoxModel(),
        directory: path.join(dir.path, 'objectbox-activity-store'),
      );
    }
  }
}
