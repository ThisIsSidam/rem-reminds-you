import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/utils/datetime_methods.dart';
import '../../../../../../shared/widgets/hm_duration_picker.dart';
import '../../../../../../shared/widgets/save_close_buttons.dart';
import '../../../providers/settings_provider.dart';

class SnoozeOptionsModal extends ConsumerStatefulWidget {
  const SnoozeOptionsModal({super.key});

  @override
  ConsumerState<SnoozeOptionsModal> createState() => _SnoozeOptionsModalState();
}

class _SnoozeOptionsModalState extends ConsumerState<SnoozeOptionsModal> {
  int selectedSettingOption = 0; // 0-5 for autoSnoozeOption1 to 6
  late Map<int, Duration> durations;

  @override
  void initState() {
    super.initState();
    initializeDurations();
  }

  void initializeDurations() {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);
    durations = <int, Duration>{
      0: settings.autoSnoozeOption1,
      1: settings.autoSnoozeOption2,
      2: settings.autoSnoozeOption3,
      3: settings.autoSnoozeOption4,
      4: settings.autoSnoozeOption5,
      5: settings.autoSnoozeOption6,
    };
  }

  void setSelectedOption(int option) {
    setState(() {
      selectedSettingOption = option;
    });
  }

  void onSave() {
    ref.read(userSettingsProvider)
      // Using direct setter assignment
      ..autoSnoozeOption1 = durations[0]!
      ..autoSnoozeOption2 = durations[1]!
      ..autoSnoozeOption3 = durations[2]!
      ..autoSnoozeOption4 = durations[3]!
      ..autoSnoozeOption5 = durations[4]!
      ..autoSnoozeOption6 = durations[5]!;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Snooze Options',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          const SizedBox(height: 10),
          _buildButtonsGrid(),
          HMDurationPicker(
            onDurationChange: (Duration dur) {
              setState(() {
                durations[selectedSettingOption] = dur;
              });
            },
          ),
          SaveCloseButtons(onTapSave: onSave),
        ],
      ),
    );
  }

  Widget _buildButtonsGrid() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: <Widget>[
          for (final MapEntry<int, Duration> entry in durations.entries)
            _buildButton(
              getFormattedDurationForTimeEditButton(
                entry.value,
              ),
              entry.key,
            ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, int option) {
    return ElevatedButton(
      onPressed: () => setSelectedOption(option),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: option == selectedSettingOption
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        shape: const BeveledRectangleBorder(),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
