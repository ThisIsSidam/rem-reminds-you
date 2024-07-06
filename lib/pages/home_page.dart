import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:Rem/pages/archive_page.dart';
import 'package:Rem/utils/home_pg_utils/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/utils/entry_list_widget.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/pages/reminder_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late Timer _timer;
  int noOfReminders = 0;
  Map<String, List<Reminder>> remindersMap = {};
  final ReceivePort receivePort = ReceivePort();
  SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);

  @override
  void initState() {
    remindersMap = RemindersDatabaseController.getReminderLists();
    WidgetsBinding.instance.addObserver(this);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {refreshPage();}); // Refreshes page every second

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
          debugPrint("REFRESHING PAGE-------");
          RemindersDatabaseController.deleteReminder(id);
          refreshPage();
        }
        else 
        {
          debugPrint("Port message is not refreshHomePage");
        }
      }
      else if (message is String)
      {
        debugPrint("[homepageListener] received a string");
        if (message == "ping")
        {
          debugPrint("[homepageListener] sending back pong");
          final notifPingPort = IsolateNameServer.lookupPortByName('NotificationIsolate');
          if (notifPingPort != null) notifPingPort.send("pong");
          else debugPrint("[homePageListener] notifPingPort is null");
          debugPrint("[homepageListener] sent back pong");
        }
        else if (message == 'ping_from_bgIsolate')
        {
          debugPrint("[homepageListener] received ping_from_bgIsolate");
          if (bgIsolate != null) // Initialized on top
          {
            bgIsolate!.send("pong");
          }
          else // Reloading the isolate
          {
            bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);
            if (bgIsolate != null) bgIsolate!.send("pong");
            else debugPrint("[homePageListener] bgIsolate is null");
          }
          debugPrint("[homepageListener] sent back pong to bgIsolate");
        }
        else 
        {
          debugPrint("[homepageListener] Unknown string received");
        }
      }
      else 
      {
        debugPrint("[homepageListener] Unknown message received $message");
      }
    });


  }

  // Returns DateTime with 0 seconds while 5 min in the future.
  DateTime getDateTimeForNewReminder() {
    final now = DateTime.now();
    final result = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 5,
      0,
      0
    );

    debugPrint("[HomePage] Given Time: $result");
    return result;
  }

  void refreshPage() {
    setState(() {
      remindersMap = RemindersDatabaseController.getReminderLists();
      noOfReminders = RemindersDatabaseController.getNumberOfReminders();
    });
  }

  void deleteAndRefresh(int id) {
    debugPrint("REFRESHING PAGE-------");
    RemindersDatabaseController.deleteReminder(id);
    refreshPage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("[HomePage] didChangeAppLifecycleState called with state: $state");
    super.didChangeAppLifecycleState(state);
    debugPrint("[HomePage] AppLifecycleState: $state");
    if (state == AppLifecycleState.detached) {
      debugPrint("[HomePage] Disposing");
      dispose();
    }
    else {
      debugPrint("[HomePage] Not disposing");
    }
  }

  @override
  void dispose() {
    debugPrint("[HomePage] Disposing");
    _timer.cancel();
    receivePort.close();
    IsolateNameServer.removePortNameMapping('main');
    debugPrint("[HomePage] Disposed---------");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (noOfReminders == 0)
    {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: null,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "Rem",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            archiveIcon()
          ],
        ),
        body: getEmptyPage()
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        shadowColor: ConstColors.darkGrey,
        title: Text(
          "Rem",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          archiveIcon()
        ],
      ),
      body: getListedReminderPage(),
      floatingActionButton: getFloatingActionButton()
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
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => ReminderPage(
                      thisReminder: Reminder(dateAndTime: getDateTimeForNewReminder()), 
                      refreshHomePage: refreshPage
                    )
                  )
                ); 
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Set a reminder",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Theme.of(context).primaryColor
              ),
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

  Widget getListedReminderPage() {

    Widget getListTile(Reminder rem, VoidCallback refreshHomePage) 
      => HomePageReminderEntryListTile(reminder: rem, refreshHomePage: refreshHomePage);


    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: 4,
      separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.0),
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return EntryListWidget(
              label: overdueSectionTitle,
              remindersList: remindersMap[overdueSectionTitle] ?? [],
              refreshPage: refreshPage,
              listEntryWidget: getListTile,
            );
          case 1:
            return EntryListWidget(
              label: todaySectionTitle,
              remindersList: remindersMap[todaySectionTitle] ?? [],
              refreshPage: refreshPage,
              listEntryWidget: getListTile,
            );
          case 2:
            return EntryListWidget(
              label: tomorrowSectionTitle,
              remindersList: remindersMap[tomorrowSectionTitle] ?? [],
              refreshPage: refreshPage,
              listEntryWidget: getListTile,
            );
          case 3:
            return EntryListWidget(
              label: laterSectionTitle,
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
        Navigator.push(context, 
          MaterialPageRoute(
            builder: (context) => ReminderPage(
              thisReminder: Reminder(dateAndTime: getDateTimeForNewReminder()), 
              refreshHomePage: refreshPage
            )
          )
        ); 
      },
      child: const Icon(
        Icons.add,
      )
    );
  }
}
