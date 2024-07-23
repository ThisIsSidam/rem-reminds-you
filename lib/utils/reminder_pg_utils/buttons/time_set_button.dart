import 'package:flutter/material.dart';

class TimeSetButton extends StatelessWidget {
  final DateTime time;
  final ValueChanged<DateTime> setTime;
  const TimeSetButton({
    super.key, 
    required this.time,
    required this.setTime
  });

  String getFormattedTime() {
    String suffix = time.hour >= 12 ? "PM" : "AM";
    int hour = time.hour % 12;
    hour = hour == 0 ? 12 : hour;
    String formattedTime = "$hour:${time.minute.toString().padLeft(2, '0')} $suffix";
    return formattedTime;
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setTime(time),
      child: Text(
        getFormattedTime(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      style: Theme.of(context).elevatedButtonTheme.style
    );
  }
}