import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/pages/archive_page/archive_page.dart';
import 'package:Rem/pages/home_page/utils/list_tile.dart';
import 'package:Rem/pages/reminder_page/reminder_page.dart';
import 'package:Rem/pages/settings_page/settings_page.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/other_utils/entry_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  int noOfReminders = 0;
  late Timer _timer; // ignore: unused_field  
  Map<String, List<Reminder>> remindersMap = {};
  final ReceivePort receivePort = ReceivePort();
  SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);

  @override
  void initState() {
    
    refreshPage();
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      refreshPage();
    });

    WidgetsBinding.instance.addObserver(this);

    NotificationController.startListeningNotificationEvents();

    super.initState();
    
    // Listening for reloading orderers
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'main');
    receivePort.listen((dynamic message) {
      if (message is Map<String, dynamic>)
      {
        final id = message['id'];

        if (message["action"] == 'done')
        {
          RemindersDatabaseController.deleteReminder(id);
          refreshPage();
        }
        else 
        {
          debugPrint("Port message is not refreshHomePage");
        }
      }
      else 
      {
        debugPrint("[homepageListener] Unknown message received $message");
      }
    });
  }


  DateTime getDateTimeForNewReminder() {
    final addDuration = UserDB.getSetting(SettingOption.DueDateAddDuration);
    if (addDuration is Duration)
    {
      
      return DateTime.now().add(addDuration);
    }
    throw "[getDateTimeForNewReminder] Duration not received | $addDuration";
  }

  void refreshPage() {
    if (mounted) {
      setState(() {
        remindersMap = RemindersDatabaseController.getReminderLists();
        noOfReminders = RemindersDatabaseController.getNumberOfReminders();
      });
    }
  }

  void deleteAndRefresh(int id) {
    RemindersDatabaseController.deleteReminder(id);
    refreshPage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      dispose();
    }
    if (state == AppLifecycleState.resumed) {
      refreshPage();
    }
  }

  @override
  void dispose() {
    receivePort.close();
    IsolateNameServer.removePortNameMapping('main');

    if (mounted) {
      super.dispose();
    } 
  }

  @override
  Widget build(BuildContext context) {

    if (noOfReminders == 0)
    {
      return Scaffold(
        appBar: getAppBar(),
        body: getEmptyPage()
      );
    }
    return Scaffold(
      appBar: getAppBar(),
      body: getListedReminderPage(),
      floatingActionButton: getFloatingActionButton()
    );
  }

  AppBar getAppBar() {
    return AppBar(
      surfaceTintColor: null,
      backgroundColor: Colors.transparent,
      title: Text(
        "Reminders",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget getEmptyPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            noRemindersPageText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 20,),
          SizedBox(
            height: 75,
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context, 
                  builder: (context) {
                    return ReminderPage(
                      thisReminder: Reminder(dateAndTime: getDateTimeForNewReminder()), 
                      refreshHomePage: refreshPage
                    );
                  }
                ); 
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Set a reminder",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)
              )
            ),
          )
        ],
      ),
    );
  }

  Widget archiveIcon() {
    return IconButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ArchivePage()));
      },
      style: Theme.of(context).iconButtonTheme.style, 
      icon: Icon(Icons.archive)
    );
  }

  Widget settingsIcon() {
    return IconButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
      },
      style: Theme.of(context).iconButtonTheme.style, 
      icon: Icon(Icons.settings)
    );
  }

  Widget getListedReminderPage() {

    Widget getListTile(Reminder rem, VoidCallback refreshHomePage) 
      => HomePageReminderEntryListTile(reminder: rem, refreshHomePage: refreshHomePage);


    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: 4,
      // separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.0),
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return EntryListWidget(
              label: Text(
                "Overdue", 
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.red)
              ),
              remindersList: remindersMap[overdueSectionTitle] ?? [],
              refreshPage: refreshPage,
              listEntryWidget: getListTile,
            );
          case 1:
            return EntryListWidget(
              label: Text(
                "Today", 
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).primaryColor)
              ),
              remindersList: remindersMap[todaySectionTitle] ?? [],
              refreshPage: refreshPage,
              listEntryWidget: getListTile,
            );
          case 2:
            return EntryListWidget(
              label: Text(
                "Tomorrow", 
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.green)
              ),
              remindersList: remindersMap[tomorrowSectionTitle] ?? [],
              refreshPage: refreshPage,
              listEntryWidget: getListTile,
            );
          case 3:
            return EntryListWidget(
              label: Text(
                "Later", 
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.yellow)
              ),
              remindersList: remindersMap[laterSectionTitle] ?? [],
              refreshPage: refreshPage,
              listEntryWidget: getListTile,
            );
          default:
            return SizedBox.shrink();
        }
      },
    );
  }


  Widget getFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {

        showModalBottomSheet(
          isScrollControlled: true,
          context: context, 
          builder: (context) {
            return ReminderPage(
              thisReminder: Reminder(dateAndTime: getDateTimeForNewReminder()), 
              refreshHomePage: refreshPage
            );
          }
        ); 
      },
      child: const Icon(
        Icons.add,
      )
    );
  }
}
