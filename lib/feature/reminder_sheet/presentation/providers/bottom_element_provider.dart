import 'package:Rem/shared/utils/logger/global_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReminderSheetBottomElement { none, snoozeOptions, recurrenceOptions }

class BottomElementNotifier with ChangeNotifier {
  BottomElementNotifier() {
    gLogger.i('BottomElementNotifier initialized');
  }

  ReminderSheetBottomElement _element = ReminderSheetBottomElement.none;

  ReminderSheetBottomElement get element => _element;

  set element(ReminderSheetBottomElement element) {
    _element = element;
    notifyListeners();
  }

  void setAsNone() {
    _element = ReminderSheetBottomElement.none;
    notifyListeners();
  }

  @override
  void dispose() {
    gLogger.i('BottomElementNotifier disposed');
    super.dispose();
  }
}

final bottomElementProvider = ChangeNotifierProvider<BottomElementNotifier>(
  (ref) => BottomElementNotifier(),
);
