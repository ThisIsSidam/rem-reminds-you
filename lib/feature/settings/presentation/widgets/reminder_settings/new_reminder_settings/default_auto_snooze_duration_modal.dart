import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../shared/widgets/hm_duration_picker.dart';
import '../../../../../../shared/widgets/save_close_buttons.dart';
import '../../../../../../shared/widgets/sheet_handle.dart';

Future<Duration?> showDefaultAutoSnoozeDurationSheet(
  BuildContext context, {
  required Duration initialDuration,
}) {
  return showModalBottomSheet<Duration>(
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 5,
    context: context,
    builder: (BuildContext context) =>
        DefaultAutoSnoozeDurationSheet(initialDuration: initialDuration),
  );
}

class DefaultAutoSnoozeDurationSheet extends ConsumerStatefulWidget {
  const DefaultAutoSnoozeDurationSheet({
    required this.initialDuration,
    super.key,
  });

  final Duration initialDuration;

  @override
  ConsumerState<DefaultAutoSnoozeDurationSheet> createState() =>
      _DefaultAutoSnoozeDurationSheetState();
}

class _DefaultAutoSnoozeDurationSheetState
    extends ConsumerState<DefaultAutoSnoozeDurationSheet> {
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
            context.local.settingsDefaultAutoSnoozeDurationTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<Duration>(
            valueListenable: _durationNotifier,
            builder: (context, duration, child) {
              return _dateTimeWidget(duration);
            },
          ),
          HMDurationPicker(
            onDurationChange: (Duration dur) => _durationNotifier.value = dur,
          ),
          SaveCloseButtons(
            onTapSave: () => context.pop(_durationNotifier.value),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeWidget(Duration dur) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Text(
            context.local.settingsEvery(
              dur.pretty(tersity: DurationTersity.minute),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
