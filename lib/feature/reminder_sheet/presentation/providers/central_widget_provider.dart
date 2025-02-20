import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/utils/logger/global_logger.dart';

part 'central_widget_provider.g.dart';

enum CentralElement {
  dateTimeGrid,
  timePicker,
  snoozeOptions,
  recurrenceOptions
}

@riverpod
class CentralWidgetNotifier extends _$CentralWidgetNotifier
    with ChangeNotifier {
  static const CentralElement _default = CentralElement.dateTimeGrid;

  @override
  CentralElement build() {
    gLogger.i('CentralWidgetNotifier initialized');
    return _default;
  }

  /// Switches current widget to passed section, if this is already the section,
  /// switches to default
  void switchTo(CentralElement element) {
    if (state == element) {
      state = _default;
    } else {
      state = element;
    }
    notifyListeners();
  }

  void reset() {
    state = _default;
    notifyListeners();
  }

  @override
  void dispose() {
    gLogger.i('BottomElementNotifier disposed');
    super.dispose();
  }
}
