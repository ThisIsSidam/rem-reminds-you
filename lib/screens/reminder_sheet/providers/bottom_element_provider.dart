import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReminderSheetBottomElement { none, snoozeOptions, recurrenceOptions }

class BottomElementNotifier with ChangeNotifier {
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
}

final bottomElementProvider =
    ChangeNotifierProvider<BottomElementNotifier>((ref) {
  return BottomElementNotifier();
});
