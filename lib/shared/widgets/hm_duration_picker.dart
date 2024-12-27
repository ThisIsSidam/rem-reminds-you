import 'package:flutter/cupertino.dart';

/// [HMDurationPicker] is a widget being used at multiple
/// places in the app. It uses a [CupertinoTimerPicker] widget.
class HMDurationPicker extends StatelessWidget {
  final void Function(Duration) onDurationChange;

  const HMDurationPicker({super.key, required this.onDurationChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTimerPicker(
        itemExtent: 70,
        mode: CupertinoTimerPickerMode.hm,
        onTimerDurationChanged: onDurationChange,
      ),
    );
  }
}
