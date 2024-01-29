import 'package:flutter/material.dart';

class TimeEditButton extends StatelessWidget {
  final Duration editDuration;
  final ValueChanged<Duration> editTime;

  const TimeEditButton({
    super.key, 
    this.editDuration= const Duration(minutes: 0),
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
    this.time = "00:00",
    required this.setTime
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setTime(time),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
        )
      ),
      child: Text(time)
    );
  }
}