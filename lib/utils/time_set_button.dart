import 'package:flutter/material.dart';
import 'package:nagger/data/app_theme.dart';

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
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textOnPrimary,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
        )
      ),
      child: Text(time)
    );
  }
}