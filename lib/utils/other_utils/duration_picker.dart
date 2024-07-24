import 'package:flutter/cupertino.dart';

class DurationPicker extends StatelessWidget {
  final Duration initialDuration;
  final Function(Duration) onChange;
  const DurationPicker({
    super.key,
    required this.initialDuration,
    required this.onChange
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.dark
      ),
      child: CupertinoTimerPicker(
        mode: CupertinoTimerPickerMode.hm,
        initialTimerDuration: initialDuration,
        onTimerDurationChanged: onChange
      ),
    );
  }
}