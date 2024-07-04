import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/other_utils/material_container.dart';

class EntryListWidget extends StatelessWidget {
  final String? label;
  final List<Reminder> remindersList;
  final VoidCallback refreshHomePage;
  final Widget Function(Reminder, VoidCallback) listEntryWidget;

  const EntryListWidget({
    super.key, 
    this.label,
    required this.remindersList,
    required this.refreshHomePage,
    required this.listEntryWidget
  });

  @override
  Widget build(BuildContext context) {
    if (remindersList.isEmpty)
    {
      return const SizedBox.shrink();
    }
    return MaterialContainer(
      elevation: 5,
      child: Column(
        children: [
          if (label != null)
          MaterialContainer(
            padding: const EdgeInsets.only(
              left: 15, top: 15, bottom: 5
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label ?? "No Label")
            ),
          ),
          SizedBox(
            height: remindersList.length * 75,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: remindersList.length,
              itemBuilder: (context, index) {
                final reminder = remindersList[index];

                return listEntryWidget(reminder, refreshHomePage);   
              }
            ),
          ),
        ],
      ),
    );
  }

  
}