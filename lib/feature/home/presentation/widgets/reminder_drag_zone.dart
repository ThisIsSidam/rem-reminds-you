import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/reminder_base/reminder_base.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../domain/model/dragged_reminder.dart';
import '../providers/reminder_dragging_provider.dart';
import '../screens/home_screen.dart';

class ReminderDragZone extends ConsumerWidget {
  const ReminderDragZone({
    required this.child,
    required this.homescreenSection,
    required this.onDroppedAccepted,
    super.key,
  });

  /// The section of the reminder this drag zone is for..
  /// The postpone action would be handled according to this.
  final HomeScreenSection homescreenSection;

  /// Widget to show when drag zone isn't activated.
  final Widget child;

  /// Handle when a reminder has been dropped to this drop zone.
  final void Function(ReminderBase reminder) onDroppedAccepted;

  String getDragZoneText(BuildContext context) {
    return switch (homescreenSection) {
      HomeScreenSection.overdue => context.local.dragZoneOverdue,
      HomeScreenSection.today => context.local.dragZoneToday,
      HomeScreenSection.tomorrow => context.local.dragZoneTomorrow,
      HomeScreenSection.later => context.local.dragZoneLater,
      HomeScreenSection.noRush => context.local.dragZoneNoRush,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Don't create dragzone for Overdue Section
    if (homescreenSection.isOverdue) return child;

    final DraggedReminder? draggedRem = ref.watch(reminderDraggingProvider);
    return DragTarget<ReminderBase>(
      onAcceptWithDetails: (DragTargetDetails<ReminderBase> details) {
        if (draggedRem == null) return;
        onDroppedAccepted(details.data);
      },
      builder: (BuildContext context, List<ReminderBase?> candidateData, _) {
        if (draggedRem == null || draggedRem.section == homescreenSection) {
          return child;
        }
        return _buildDragZone(
          context,
          isHovering: candidateData.isNotEmpty,
        );
      },
    );
  }

  Widget _buildDragZone(
    BuildContext context, {
    bool isHovering = false,
  }) {
    final Color sectionColor = homescreenSection.getColor(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 80,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHovering
            ? sectionColor.withAlpha(100)
            : sectionColor.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(getDragZoneText(context)),
    );
  }
}
