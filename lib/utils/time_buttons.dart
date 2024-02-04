import 'package:flutter/material.dart';
import 'package:nagger/data/app_theme.dart';

class TimeEditButton extends StatelessWidget {
  final Duration editDuration;
  final ValueChanged<Duration> editTime;

  const TimeEditButton({
    super.key, 
    required this.editDuration,
    required this.editTime
  });
    
  String getEditDuration() {
    final minutes = editDuration.inMinutes;
    String strDuration = "";

    if (minutes > 0)
    {
      strDuration += "+";
    }

    if ((minutes < 59) && (minutes > -59))
    {
      strDuration += "${minutes.toString()} min";
    }
    else if ( (minutes < 1439) && (minutes > -1439))
    {
      strDuration += "${(minutes~/60).toString()} hr";
    }
    else 
    {
      strDuration += "${((minutes~/60)~/24).toString()} day";
    }

    return strDuration;
  }
    
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => editTime(editDuration),
      style: ElevatedButton.styleFrom(
        maximumSize: const Size(100, 75),
        minimumSize: const Size(100, 50),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textOnPrimary,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
        )
      ),
      child: Text(getEditDuration()),
    );
  }

} 

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
        maximumSize: const Size(100, 75),
        minimumSize: const Size(100, 50),
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