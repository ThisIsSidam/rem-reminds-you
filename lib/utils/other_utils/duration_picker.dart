import 'package:flutter/cupertino.dart';

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
          onTimerDurationChanged: onDurationChange
        ),
      ),
    );
  }
}