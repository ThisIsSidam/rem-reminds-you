import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Rem/reminder_class/reminder.dart';

class EntryListWidget extends StatelessWidget {
  final Widget? label;
  final List<Reminder> remindersList;
  final VoidCallback refreshPage;
  final Widget Function(Reminder, VoidCallback) listEntryWidget;

  const EntryListWidget({
    super.key, 
    this.label,
    required this.remindersList,
    required this.refreshPage,
    required this.listEntryWidget
  });

  @override
  Widget build(BuildContext context) {
    if (remindersList.isEmpty)
    {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
          SizedBox(
            height: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: label,
            )
          ),
          SizedBox(
            height: remindersList.length * (60+5), // Tile height + separators
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: remindersList.length,
              separatorBuilder: (context, index) => SizedBox(height: 4.0),
              itemBuilder: (context, index) {
                final reminder = remindersList[index];
      
                return listEntryWidget(reminder, refreshPage);   
              }
            ),
          ),
        ],
      ),
    );
  }

  
}