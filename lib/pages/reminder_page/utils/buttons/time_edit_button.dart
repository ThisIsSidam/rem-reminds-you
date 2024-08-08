import 'package:Rem/utils/functions/datetime_methods.dart';
import 'package:flutter/material.dart';

class TimeEditButton extends StatelessWidget {
  final Duration editDuration;
  final ValueChanged<Duration> editTime;

  const TimeEditButton({
    super.key, 
    required this.editDuration,
    required this.editTime
  });
    

    
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => editTime(editDuration),
      child: Text(
        getFormattedDurationForTimeEditButton(editDuration),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      style: Theme.of(context).elevatedButtonTheme.style, 
    );
  }

} 

