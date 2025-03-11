import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/datetime_ext.dart';
import '../../../../../../core/extensions/duration_ext.dart';
import '../../../../../../shared/widgets/dhm_single_duration_picker.dart';
import '../../../../../../shared/widgets/save_close_buttons.dart';
import '../../../providers/settings_provider.dart';

class QuickTimeTableModal extends ConsumerStatefulWidget {
  const QuickTimeTableModal({super.key});

  @override
  ConsumerState<QuickTimeTableModal> createState() =>
      _QuickTimeTableModalState();
}

class _QuickTimeTableModalState extends ConsumerState<QuickTimeTableModal> {
  int selectedSettingOption = 0; // 0-3 for set options, 4-11 for edit options
  final FixedExtentScrollController isNegativeDurationScrollController =
      FixedExtentScrollController();

  // Helper maps to store temporary values
  late Map<int, DateTime> setDateTimes;
  late Map<int, Duration> editDurations;

  @override
  void initState() {
    super.initState();
    initializeValues();
  }

  void initializeValues() {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);
    setDateTimes = <int, DateTime>{
      0: settings.quickTimeSetOption1,
      1: settings.quickTimeSetOption2,
      2: settings.quickTimeSetOption3,
      3: settings.quickTimeSetOption4,
    };
    editDurations = <int, Duration>{
      4: settings.quickTimeEditOption1,
      5: settings.quickTimeEditOption2,
      6: settings.quickTimeEditOption3,
      7: settings.quickTimeEditOption4,
      8: settings.quickTimeEditOption5,
      9: settings.quickTimeEditOption6,
      10: settings.quickTimeEditOption7,
      11: settings.quickTimeEditOption8,
    };
  }

  void setSelectedOption(int option) {
    setState(() {
      selectedSettingOption = option;
      if (option >= 4) {
        updatePickerPositionsOnButtonChange(editDurations[option]!);
      }
    });
  }

  void updatePickerPositionsOnButtonChange(Duration duration) {
    if (duration.isNegative) {
      isNegativeDurationScrollController.jumpToItem(1);
    } else {
      isNegativeDurationScrollController.jumpToItem(0);
    }
  }

  Future<void> onSave() async {
    final UserSettingsNotifier settings = ref.read(userSettingsProvider);
    // Update set options
    await settings.setQuickTimeSetOption1(setDateTimes[0]!);
    await settings.setQuickTimeSetOption2(setDateTimes[1]!);
    await settings.setQuickTimeSetOption3(setDateTimes[2]!);
    await settings.setQuickTimeSetOption4(setDateTimes[3]!);
    // Update edit options
    await settings.setQuickTimeEditOption1(editDurations[4]!);
    await settings.setQuickTimeEditOption2(editDurations[5]!);
    await settings.setQuickTimeEditOption3(editDurations[6]!);
    await settings.setQuickTimeEditOption4(editDurations[7]!);
    await settings.setQuickTimeEditOption5(editDurations[8]!);
    await settings.setQuickTimeEditOption6(editDurations[9]!);
    await settings.setQuickTimeEditOption7(editDurations[10]!);
    await settings.setQuickTimeEditOption8(editDurations[11]!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Quick Time Table',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          const SizedBox(height: 8),
          _buildButtonsTable(),
          getEditWidget(),
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

  Widget getEditWidget() {
    if (selectedSettingOption <= 3) {
      return dateTimePickerWidget();
    } else {
      return DHMSingleDurationPicker(
        allowNegative: true,
        onDurationChanged: (Duration dur) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                editDurations[selectedSettingOption] = dur;
              });
            }
          });
        },
      );
    }
  }

  Widget dateTimePickerWidget() {
    return Container(
      width: 400,
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoDatePicker(
        use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        mode: CupertinoDatePickerMode.time,
        itemExtent: 70,
        initialDateTime: setDateTimes[selectedSettingOption],
        onDateTimeChanged: (DateTime dt) {
          setState(() {
            setDateTimes[selectedSettingOption] = dt;
          });
        },
      ),
    );
  }

  Widget _buildButtonsTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 4,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: <Widget>[
          ...setDateTimes.entries.map(
            (MapEntry<int, DateTime> entry) => _buildButton(
              entry.value.formattedHM(
                is24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
              ),
              entry.key,
            ),
          ),
          ...editDurations.entries.map(
            (MapEntry<int, Duration> entry) => _buildButton(
              entry.value.friendly(),
              entry.key,
            ),
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
