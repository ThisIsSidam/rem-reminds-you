import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/reminder_model/reminder_model.dart';
import '../providers/central_widget_provider.dart';
import '../providers/sheet_reminder_notifier.dart';
import '../widgets/bottom_buttons.dart';
import '../widgets/central_section.dart';
import '../widgets/title_field.dart';
import '../widgets/top_buttons.dart';

class ReminderSheet extends ConsumerStatefulWidget {
  const ReminderSheet({
    this.reminder,
    this.customDuration,
    this.isNoRush = false,
    super.key,
  });

  final ReminderModel? reminder;
  final Duration? customDuration;
  final bool isNoRush;

  @override
  ConsumerState<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<ReminderSheet> {
  ValueNotifier<bool> isLoaded = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () {
      if (widget.reminder != null) {
        ref.read(sheetReminderNotifier).loadValues(widget.reminder!);
      } else {
        ref.read(sheetReminderNotifier).resetValuesWith(
              customDuration: widget.customDuration,
              isNoRush: widget.isNoRush,
            );
      }

      ref.read(centralWidgetNotifierProvider.notifier).reset();
      isLoaded.value = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    isLoaded.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double keyboardInsets = MediaQuery.of(context).viewInsets.bottom;
    final DateTime dateTime = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.dateTime),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 500 + keyboardInsets,
      ),
      child: SingleChildScrollView(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: 0 + keyboardInsets),
          child: ValueListenableBuilder<bool>(
            valueListenable: isLoaded,
            builder: (BuildContext context, bool loaded, Widget? child) {
              return loaded ? _buildBody(dateTime, theme) : _buildLoading();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DateTime dateTime, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const TopButtons(),
        AnimatedContainer(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            color: dateTime.isBefore(DateTime.now())
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.surfaceContainer,
          ),
          duration: const Duration(milliseconds: 500),
          child: const Column(
            children: <Widget>[
              TitleField(),
              CentralSection(),
              BottomButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
