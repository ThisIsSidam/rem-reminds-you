import 'package:Rem/utils/misc_methods/datetime_methods.dart';
import 'package:flutter/material.dart';

class TimeSetButton extends StatelessWidget {
  final DateTime time;
  final ValueChanged<DateTime> setTime;
  const TimeSetButton({
    super.key, 
    required this.time,
    required this.setTime
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setTime(time),
      child: Text(
        getFormattedTimeForTimeSetButton(time),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      style: Theme.of(context).elevatedButtonTheme.style
    );
  }
}