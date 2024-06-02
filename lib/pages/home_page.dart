import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nagger/consts/const_colors.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/database/database.dart';
import 'package:nagger/utils/home_pg_utils/homepage_list_section.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/pages/reminder_page.dart';

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
  final bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);

  @override
  void initState() {
    remindersMap = RemindersDatabaseController.getReminderLists();
    WidgetsBinding.instance.addObserver(this);

    _scheduleRefresh();
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
        else if (message["action"] == "silence")
        {
          debugPrint("[homepageListener] silencing");
          final reminder = RemindersDatabaseController.getReminder(id);
          if (reminder == null)
          {
            throw "Reminder not present";
          }
          reminder.reminderStatus = ReminderStatus.silenced;
          RemindersDatabaseController.saveReminder(reminder);
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
          if (bgIsolate != null) // Initailized on top
          {
            bgIsolate!.send("pong");
          }
          else debugPrint("[homePageListener] bgIsolate is null");
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

    return result;
  }

  void _scheduleRefresh() {
    DateTime now = DateTime.now();
    Duration timeUntilNextRefresh = Duration(
      seconds: 10 - (now.second % 10),
      milliseconds: 1000 - now.millisecond
    );

    _timer = Timer(timeUntilNextRefresh, () {
      refreshPage();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        refreshPage();
      });
    });
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
            "Nagger",
          style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            IconButton(onPressed: refreshPage, icon: const Icon(
              Icons.refresh,
              color: Colors.red,
            ))
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
          "Nagger",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(onPressed: refreshPage, icon: const Icon(
            Icons.refresh,
            color: Colors.red,
            ))
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
                      thisReminder: Reminder(dateAndTime: DateTime.now().add(Duration(minutes: 5))), 
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

  Widget getListedReminderPage() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: 4,
      separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.0),
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return HomePageListSection(
              label: overdueSectionTitle,
              remindersList: remindersMap[overdueSectionTitle] ?? [],
              refreshHomePage: refreshPage,
            );
          case 1:
            return HomePageListSection(
              label: todaySectionTitle,
              remindersList: remindersMap[todaySectionTitle] ?? [],
              refreshHomePage: refreshPage,
            );
          case 2:
            return HomePageListSection(
              label: tomorrowSectionTitle,
              remindersList: remindersMap[tomorrowSectionTitle] ?? [],
              refreshHomePage: refreshPage,
            );
          case 3:
            return HomePageListSection(
              label: laterSectionTitle,
              remindersList: remindersMap[laterSectionTitle] ?? [],
              refreshHomePage: refreshPage,
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
              thisReminder: Reminder(dateAndTime: DateTime.now().add(Duration(minutes: 5))), 
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
