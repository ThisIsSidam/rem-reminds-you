import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../core/extensions/datetime_ext.dart';
import '../../../../../../shared/widgets/hm_duration_picker.dart';
import '../../../../../../shared/widgets/save_close_buttons.dart';
import '../../../../../../shared/widgets/sheet_handle.dart';

Future<Duration?> showDefaultLeadDurationSheet(
  BuildContext context, {
  required Duration initialDuration,
}) {
  return showModalBottomSheet<Duration>(
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 5,
    context: context,
    builder: (BuildContext context) =>
        DefaultLeadDurationSheet(initialDuration: initialDuration),
  );
}

class DefaultLeadDurationSheet extends ConsumerStatefulWidget {
  const DefaultLeadDurationSheet({required this.initialDuration, super.key});

  final Duration initialDuration;

  @override
  ConsumerState<DefaultLeadDurationSheet> createState() =>
      _DefaultLeadDurationSheetState();
}

class _DefaultLeadDurationSheetState
    extends ConsumerState<DefaultLeadDurationSheet> {
  late final _durationNotifier = ValueNotifier(widget.initialDuration);

  @override
  void dispose() {
    _durationNotifier.dispose();
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
          const SizedBox(height: 20),
          Text(
            context.local.settingsDefaultLeadDurationTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<Duration>(
            valueListenable: _durationNotifier,
            builder: (context, duration, child) {
              final DateTime dateTime = DateTime.now().add(duration);
              final String dateTimeString = dateTime.friendly(
                is24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
              );
              final String diffString = dateTime.prettyDuration;
              return _dateTimeWidget(dateTimeString, diffString);
            },
          ),
          HMDurationPicker(
            onDurationChange: (Duration dur) => _durationNotifier.value = dur,
          ),
          SaveCloseButtons(
            onTapSave: () => Navigator.pop(context, _durationNotifier.value),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeWidget(String dateTimeString, String diffString) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(dateTimeString, style: Theme.of(context).textTheme.titleMedium),
          Text(
            diffString,
            style: Theme.of(
              context,
            ).textTheme.titleSmall!.copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
