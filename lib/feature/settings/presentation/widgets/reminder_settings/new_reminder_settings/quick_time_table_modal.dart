import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../core/extensions/datetime_ext.dart';
import '../../../../../../core/extensions/duration_ext.dart';
import '../../../../../../shared/widgets/dhm_single_duration_picker.dart';
import '../../../../../../shared/widgets/save_close_buttons.dart';
import '../../../../../../shared/widgets/sheet_handle.dart';

typedef QuickTimeData = ({
  Map<int, DateTime> setDateTimes,
  Map<int, Duration> editDurations,
});

Future<QuickTimeData?> showQuickTimeTableSheet(
  BuildContext context, {
  required QuickTimeData initialData,
}) {
  return showModalBottomSheet<QuickTimeData>(
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 5,
    context: context,
    builder: (BuildContext context) =>
        QuickTimeTableSheet(initialData: initialData),
  );
}

class QuickTimeTableSheet extends ConsumerStatefulWidget {
  const QuickTimeTableSheet({required this.initialData, super.key});

  final QuickTimeData initialData;

  @override
  ConsumerState<QuickTimeTableSheet> createState() =>
      _QuickTimeTableSheetState();
}

class _QuickTimeTableSheetState extends ConsumerState<QuickTimeTableSheet> {
  late final ValueNotifier<int> _selectedOptionNotifier = ValueNotifier(0);
  late final ValueNotifier<Map<int, DateTime>> _setDateTimesNotifier =
      ValueNotifier(Map<int, DateTime>.from(widget.initialData.setDateTimes));
  late final ValueNotifier<Map<int, Duration>> _editDurationsNotifier =
      ValueNotifier(Map<int, Duration>.from(widget.initialData.editDurations));

  @override
  void dispose() {
    _selectedOptionNotifier.dispose();
    _setDateTimesNotifier.dispose();
    _editDurationsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(
            context.local.settingsQuickTimeTableTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _selectedOptionNotifier,
            builder: (context, selectedOption, child) {
              return Column(
                children: [
                  ValueListenableBuilder<Map<int, DateTime>>(
                    valueListenable: _setDateTimesNotifier,
                    builder: (context, dates, child) {
                      return ValueListenableBuilder<Map<int, Duration>>(
                        valueListenable: _editDurationsNotifier,
                        builder: (context, durations, child) {
                          return _buildButtonsTable(
                            selectedOption,
                            dates,
                            durations,
                            (option) => _selectedOptionNotifier.value = option,
                          );
                        },
                      );
                    },
                  ),
                  _getEditWidget(selectedOption),
                ],
              );
            },
          ),
          SaveCloseButtons(
            onTapSave: () => Navigator.pop(context, (
              setDateTimes: _setDateTimesNotifier.value,
              editDurations: _editDurationsNotifier.value,
            )),
          ),
        ],
      ),
    );
  }

  Widget _getEditWidget(int selectedOption) {
    if (selectedOption <= 3) {
      return _dateTimePickerWidget(context, selectedOption);
    } else {
      return DHMSingleDurationPicker(
        allowNegative: true,
        onDurationChanged: (Duration dur) {
          final newMap = Map<int, Duration>.from(_editDurationsNotifier.value);
          newMap[selectedOption] = dur;
          _editDurationsNotifier.value = newMap;
        },
      );
    }
  }

  Widget _dateTimePickerWidget(BuildContext context, int selectedOption) {
    return Container(
      width: 400,
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoDatePicker(
        key: ValueKey(selectedOption),
        use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        mode: CupertinoDatePickerMode.time,
        itemExtent: 70,
        initialDateTime: _setDateTimesNotifier.value[selectedOption],
        onDateTimeChanged: (DateTime dt) {
          final newMap = Map<int, DateTime>.from(_setDateTimesNotifier.value);
          newMap[selectedOption] = dt;
          _setDateTimesNotifier.value = newMap;
        },
      ),
    );
  }

  Widget _buildButtonsTable(
    int selectedOption,
    Map<int, DateTime> dates,
    Map<int, Duration> durations,
    void Function(int) onSelect,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 4,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: <Widget>[
          ...dates.entries.map(
            (entry) => _buildButton(
              entry.value.formattedHM(
                is24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
              ),
              entry.key,
              selectedOption,
              onSelect,
            ),
          ),
          ...durations.entries.map(
            (entry) => _buildButton(
              entry.value.friendly(),
              entry.key,
              selectedOption,
              onSelect,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    int option,
    int selectedOption,
    void Function(int) onSelect,
  ) {
    return ElevatedButton(
      onPressed: () => onSelect(option),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: option == selectedOption
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        shape: const BeveledRectangleBorder(),
      ),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
