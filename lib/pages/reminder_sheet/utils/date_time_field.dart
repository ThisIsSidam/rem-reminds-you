import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateTimeField extends ConsumerStatefulWidget {
  const DateTimeField({super.key});

  @override
  ConsumerState<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends ConsumerState<DateTimeField> {

  final titleController = TextEditingController();

  @override
  void initState() {
    final reminderNotifier = ref.read(reminderNotifierProvider);
    titleController.text = reminderNotifier.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final reminderNotifier = ref.watch(reminderNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: Theme.of(context).elevatedButtonTheme.style,
        onPressed: () {}, // to be implemented
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getFormattedDateTime(reminderNotifier.dateAndTime),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              getFormattedDiffString(dateTime: reminderNotifier.dateAndTime),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        )
      ),
    );
  }
}