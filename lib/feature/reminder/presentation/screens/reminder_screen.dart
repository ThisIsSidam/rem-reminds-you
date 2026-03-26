import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../reminder_sheet/presentation/sheet/reminder_sheet.dart';
import '../providers/no_rush_provider.dart';
import '../providers/reminders_provider.dart';
import '../widgets/home_screen_lists.dart';

enum ReminderSection {
  overdue,
  today,
  tomorrow,
  later,
  noRush;

  bool get isOverdue => this == overdue;

  String localizedTitle(BuildContext context) {
    return switch (this) {
      ReminderSection.overdue => context.local.homeSectionOverdue,
      ReminderSection.today => context.local.homeSectionToday,
      ReminderSection.tomorrow => context.local.homeSectionTomorrow,
      ReminderSection.later => context.local.homeSectionLater,
      ReminderSection.noRush => context.local.homeSectionNoRush,
    };
  }

  Color getColor(BuildContext context) {
    final ColorScheme colors = context.colors;
    return switch (this) {
      overdue => colors.error,
      today => colors.primary,
      tomorrow => colors.secondary,
      later => colors.inversePrimary,
      noRush => colors.inverseSurface,
    };
  }
}

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEmpty =
        ref.watch(remindersProvider.notifier).isEmpty() &&
        ref.watch(noRushRemindersProvider.notifier).isEmpty();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: <Widget>[
          _buildAppBar(context),
          if (isEmpty)
            getEmptyPage(context)
          else
            getListedReminderPage(context),
        ],
      ),
      floatingActionButton: isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => showReminderSheet(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  // The appbar for the home page.
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        context.local.homeTitle,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  // The empty page widget used in empty scaffold body.
  Widget getEmptyPage(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              context.local.emptyReminders,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 75,
              width: 200,
              child: ElevatedButton(
                onPressed: () => showReminderSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  surfaceTintColor: Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    context.local.setReminder,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The list of reminders widget used in scaffold body.
  Widget getListedReminderPage(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(<Widget>[
        const ListedReminderSection(
          key: ValueKey<ReminderSection>(ReminderSection.overdue),
          section: ReminderSection.overdue,
          hideIfEmpty: true,
        ),
        ListedReminderSection(
          section: ReminderSection.today,
          onTapTitle: () => showReminderSheet(context),
        ),
        ListedReminderSection(
          section: ReminderSection.tomorrow,
          onTapTitle: () {
            showReminderSheet(context, customDuration: const Duration(days: 1));
          },
        ),
        ListedReminderSection(
          section: ReminderSection.later,
          onTapTitle: () {
            showReminderSheet(context, customDuration: const Duration(days: 7));
          },
        ),
        const ListedNoRushSection(),
      ]),
    );
  }
}
