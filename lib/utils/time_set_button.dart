import 'package:flutter/material.dart';

class TimeSetButton extends StatelessWidget {
  final String time;
  final ValueChanged<String> setTime;
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
        time,
        style: Theme.of(context).textTheme.bodyMedium,
      )
    );
  }
}