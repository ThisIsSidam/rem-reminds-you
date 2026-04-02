import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../shared/widgets/save_close_buttons.dart';
import '../../../../../../shared/widgets/sheet_handle.dart';

typedef TimeRange = ({TimeOfDay? from, TimeOfDay? to});

enum TimeButtonType {
  from,
  to;

  String getLocalizedLabel(BuildContext context) => switch (this) {
    from => context.local.settingsFrom,
    to => context.local.settingsTo,
  };
}

Future<TimeRange?> showNoRushHoursSheet(
  BuildContext context, {
  TimeRange? initialRange,
}) {
  return showModalBottomSheet<TimeRange>(
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 5,
    context: context,
    builder: (BuildContext context) =>
        NoRushHoursSheet(initialRange: initialRange),
  );
}

class NoRushHoursSheet extends ConsumerStatefulWidget {
  const NoRushHoursSheet({this.initialRange, super.key});

  final TimeRange? initialRange;

  @override
  ConsumerState<NoRushHoursSheet> createState() => _NoRushHoursSheetState();
}

class _NoRushHoursSheetState extends ConsumerState<NoRushHoursSheet> {
  late final ValueNotifier<TimeOfDay> _fromTimeNotifier = ValueNotifier(
    widget.initialRange?.from ?? TimeOfDay.now(),
  );

  late final ValueNotifier<TimeOfDay> _toTimeNotifier = ValueNotifier(
    widget.initialRange?.to ?? TimeOfDay.now(),
  );

  final ValueNotifier<TimeButtonType> _selectedTypeNotifier = ValueNotifier(
    TimeButtonType.from,
  );

  @override
  void dispose() {
    _selectedTypeNotifier.dispose();
    _fromTimeNotifier.dispose();
    _toTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10 + context.bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(
            context.local.settingsNoRushHours,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
            child: Text(
              // ignore: lines_longer_than_80_chars
              context.local.settingsNoRushDescription,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
          _buildTimeButtonsRow(),
          const SizedBox(height: 40),
          _buildTimePicker(),
          const SizedBox(height: 10),
          SaveCloseButtons(
            onTapSave: () => context.pop((
              from: _fromTimeNotifier.value,
              to: _toTimeNotifier.value,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButtonsRow() {
    return ValueListenableBuilder(
      valueListenable: _selectedTypeNotifier,
      builder: (context, value, child) {
        return Row(
          children: <Widget>[
            Expanded(
              child: _buildTimeButton(
                type: .from,
                isSelected: TimeButtonType.from == value,
                timeNotifier: _fromTimeNotifier,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.secondaryContainer,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(':', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            Expanded(
              child: _buildTimeButton(
                type: .to,
                isSelected: TimeButtonType.to == value,
                timeNotifier: _toTimeNotifier,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeButton({
    required TimeButtonType type,
    required bool isSelected,
    required ValueNotifier<TimeOfDay> timeNotifier,
  }) {
    return SizedBox(
      height: 75,
      child: ElevatedButton(
        onPressed: () => _selectedTypeNotifier.value = type,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? context.colors.primaryContainer
              : context.colors.secondaryContainer,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: context.colors.primary)
                : .none,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.getLocalizedLabel(context),
              style: context.texts.titleSmall?.copyWith(
                fontWeight: isSelected ? .bold : .normal,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: timeNotifier,
              builder: (context, time, child) {
                return Text(
                  // ignore: lines_longer_than_80_chars
                  time.format(context),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return SizedBox(
      height: 125,
      child: ValueListenableBuilder(
        valueListenable: _selectedTypeNotifier,
        builder: (context, selectedType, child) {
          final initialTime = switch (selectedType) {
            .from => _fromTimeNotifier.value,
            .to => _toTimeNotifier.value,
          };
          return CupertinoDatePicker(
            key: ValueKey(selectedType),
            mode: CupertinoDatePickerMode.time,
            use24hFormat: true,
            initialDateTime: DateTime(
              2024,
              1,
              1,
              initialTime.hour,
              initialTime.minute,
            ),
            onDateTimeChanged: (DateTime dt) {
              final TimeOfDay newTime = TimeOfDay(
                hour: dt.hour,
                minute: dt.minute,
              );
              switch (selectedType) {
                case .from:
                  _fromTimeNotifier.value = newTime;
                case .to:
                  _toTimeNotifier.value = newTime;
              }
            },
          );
        },
      ),
    );
  }
}
