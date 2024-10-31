import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// [HMDurationPicker] is a widget being used at multiple
/// places in the app. It uses a [CupertinoTimerPicker] widget.
class HMDurationPicker extends StatelessWidget {
  final void Function(Duration) onDurationChange;
  const HMDurationPicker({super.key, required this.onDurationChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.dark,
          barBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          primaryColor: Theme.of(context).colorScheme.primary,
          primaryContrastingColor: Theme.of(context).colorScheme.secondary,
        ),
        child: CupertinoTimerPicker(
          itemExtent: 70,
          mode: CupertinoTimerPickerMode.hm,
          onTimerDurationChanged: onDurationChange,
        ),
      ),
    );
  }
}
