import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/duration_ext.dart';
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

  Future<void> onSave() async {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);

    await settings.setAutoSnoozeOption1(durations[0]!);
    await settings.setAutoSnoozeOption2(durations[1]!);
    await settings.setAutoSnoozeOption3(durations[2]!);
    await settings.setAutoSnoozeOption4(durations[3]!);
    await settings.setAutoSnoozeOption5(durations[4]!);
    await settings.setAutoSnoozeOption6(durations[5]!);
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
          SaveCloseButtons(
            onTapSave: () async {
              await onSave();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
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
              entry.value.friendly(),
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
