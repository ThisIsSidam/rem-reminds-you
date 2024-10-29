import 'package:Rem/screens/reminder_sheet/widgets/time_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/settings_provider.dart';

class QuickAccessTimeTable extends ConsumerWidget {
  const QuickAccessTimeTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);

    // Get the preset times
    final setDateTimes = [
      settings.quickTimeSetOption1,
      settings.quickTimeSetOption2,
      settings.quickTimeSetOption3,
      settings.quickTimeSetOption4,
    ];

    // Get the duration options
    final editDurations = [
      settings.quickTimeEditOption1,
      settings.quickTimeEditOption2,
      settings.quickTimeEditOption3,
      settings.quickTimeEditOption4,
      settings.quickTimeEditOption5,
      settings.quickTimeEditOption6,
      settings.quickTimeEditOption7,
      settings.quickTimeEditOption8,
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        crossAxisCount: 4,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          ...setDateTimes.map((dateTime) => TimeButton(dateTime: dateTime)),
          ...editDurations.map((duration) => TimeButton(duration: duration)),
        ],
      ),
    );
  }
}
