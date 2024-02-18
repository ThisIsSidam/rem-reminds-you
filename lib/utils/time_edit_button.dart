import 'package:flutter/material.dart';

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
      child: Text(
        getEditDuration(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

} 

