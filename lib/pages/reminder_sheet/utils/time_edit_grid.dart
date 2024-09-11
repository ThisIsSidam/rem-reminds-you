import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/pages/reminder_sheet/utils/time_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickAccessTimeTable extends ConsumerWidget {
  QuickAccessTimeTable({super.key});

  final List<DateTime> setDateTimes = List.generate(4, (index) {
    final dt = UserDB.getSetting(SettingsOptionMethods.fromInt(index+3));
    if (!(dt is DateTime))
    {
      throw "[setDateTimes] DateTime not received | $dt";
    } 
    return dt;
  }, growable: false);

  final List<Duration>  editDurations = List.generate(8, (index) {
    final dur = UserDB.getSetting(SettingsOptionMethods.fromInt(index+7));
    if  (!(dur is Duration)) 
    {
      throw "[editDurations] Duration not received | $dur";
    }
    return dur; 
  }, growable: false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        crossAxisCount: 4,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          TimeButton(dateTime: setDateTimes[0]),
          TimeButton(dateTime: setDateTimes[1]),
          TimeButton(dateTime: setDateTimes[2]),
          TimeButton(dateTime: setDateTimes[3]),
          TimeButton(duration: editDurations[0]),
          TimeButton(duration: editDurations[1]),
          TimeButton(duration: editDurations[2]),
          TimeButton(duration: editDurations[3]),
          TimeButton(duration: editDurations[4]),
          TimeButton(duration: editDurations[5]),
          TimeButton(duration: editDurations[6]),
          TimeButton(duration: editDurations[7]),
        ],
      ),
    );
  }


}