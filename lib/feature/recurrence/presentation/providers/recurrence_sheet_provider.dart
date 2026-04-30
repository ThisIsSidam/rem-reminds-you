import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/utils/logger/app_logger.dart';
import '../../data/models/no_recurrence_rule.dart';
import '../../data/models/recurrence_rule.dart';

part 'generated/recurrence_sheet_provider.g.dart';

@riverpod
class RecurrenceSheetNotifier extends _$RecurrenceSheetNotifier
    with ChangeNotifier {
  @override
  RecurrenceRule build() {
    AppLogger.i('RecurrenceSheetNotifier initialized');
    return const NoRecurrenceRule();
  }

  /// Switches current widget to passed section, if this is already the section,
  /// switches to default
  void switchTo(RecurrenceRule rule) {
    state = rule;
    notifyListeners();
  }

  void reset() {
    state = const NoRecurrenceRule();
    notifyListeners();
  }

  @override
  void dispose() {
    AppLogger.i('RecurrenceSheetNotifier disposed');
    super.dispose();
  }
}
