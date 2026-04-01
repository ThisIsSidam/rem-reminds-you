import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../core/extensions/duration_ext.dart';
import '../../../../../../shared/widgets/hm_duration_picker.dart';
import '../../../../../../shared/widgets/save_close_buttons.dart';
import '../../../../../../shared/widgets/sheet_handle.dart';

Future<Map<int, Duration>?> showSnoozeOptionsSheet(
  BuildContext context, {
  required Map<int, Duration> initialDurations,
}) {
  return showModalBottomSheet<Map<int, Duration>>(
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 5,
    context: context,
    builder: (BuildContext context) =>
        SnoozeOptionsSheet(initialDurations: initialDurations),
  );
}

class SnoozeOptionsSheet extends ConsumerStatefulWidget {
  const SnoozeOptionsSheet({required this.initialDurations, super.key});

  final Map<int, Duration> initialDurations;

  @override
  ConsumerState<SnoozeOptionsSheet> createState() => _SnoozeOptionsSheetState();
}

class _SnoozeOptionsSheetState extends ConsumerState<SnoozeOptionsSheet> {
  late final ValueNotifier<int> _selectedOptionNotifier = ValueNotifier(0);
  late final ValueNotifier<Map<int, Duration>> _durationsNotifier =
      ValueNotifier(Map<int, Duration>.from(widget.initialDurations));

  @override
  void dispose() {
    _selectedOptionNotifier.dispose();
    _durationsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(
            context.local.settingsSnoozeOptionsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _selectedOptionNotifier,
            builder: (context, selectedOption, child) {
              return ValueListenableBuilder<Map<int, Duration>>(
                valueListenable: _durationsNotifier,
                builder: (context, durations, child) {
                  return _buildButtonsGrid(
                    selectedOption,
                    durations,
                    (option) => _selectedOptionNotifier.value = option,
                  );
                },
              );
            },
          ),
          HMDurationPicker(
            onDurationChange: (Duration dur) {
              final newMap = Map<int, Duration>.from(_durationsNotifier.value);
              newMap[_selectedOptionNotifier.value] = dur;
              _durationsNotifier.value = newMap;
            },
          ),
          SaveCloseButtons(
            onTapSave: () => Navigator.pop(context, _durationsNotifier.value),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsGrid(
    int selectedOption,
    Map<int, Duration> durations,
    void Function(int) onSelect,
  ) {
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
              selectedOption,
              onSelect,
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
