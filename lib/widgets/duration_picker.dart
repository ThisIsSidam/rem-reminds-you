import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// [DurationPickerBase] is a widget being used at multiple
/// places in the app. It uses a [CupertinoTimerPicker] widget.
class DurationPickerBase extends StatelessWidget {
  final void Function(Duration) onDurationChange;
  const DurationPickerBase({
    super.key, 
    required this.onDurationChange
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.dark
        ),
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          onTimerDurationChanged: onDurationChange,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}