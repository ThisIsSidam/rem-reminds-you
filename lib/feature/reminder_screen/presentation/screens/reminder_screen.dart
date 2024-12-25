import 'package:Rem/feature/reminder_screen/presentation/providers/central_widget_provider.dart';
import 'package:Rem/feature/reminder_screen/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_screen/presentation/widgets/central_section.dart';
import 'package:Rem/feature/reminder_screen/presentation/widgets/key_buttons_row.dart';
import 'package:Rem/feature/reminder_screen/presentation/widgets/title_field.dart';
import 'package:Rem/shared/utils/logger/global_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/reminder_model/reminder_model.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({
    this.reminder,
    super.key,
  });

  final ReminderModel? reminder;

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<ReminderScreen> {
  @override
  void initState() {
    gLogger.i('Build Reminder Sheet');

    Future(() {
      if (widget.reminder != null) {
        ref.read(sheetReminderNotifier).loadValues(widget.reminder!);
      } else {
        ref.read(sheetReminderNotifier).resetValuesWith();
      }

      ref.read(centralWidgetNotifierProvider.notifier).reset();
      gLogger.i("Reminder initialized and bottom element set to none");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final noRush = ref.watch(sheetReminderNotifier.select((p) => p.noRush));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isKeyboardVisible =
              MediaQuery.of(context).viewInsets.bottom > 0;

          return Stack(
            children: [
              // Empty background body
              Container(
                color: Colors.black.withAlpha(100),
              ),

              // Floating Container
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: isKeyboardVisible
                    ? constraints.maxHeight *
                        0.2 // Move up when keyboard appears
                    : constraints.maxHeight * 0.4, // Centered when no keyboard
                left: 16,
                right: 16,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: noRush
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.tertiaryContainer,
                    ),
                    padding: EdgeInsets.only(bottom: keyboardHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TitleField(),
                            CentralSection(),
                            KeyButtonsRow(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
