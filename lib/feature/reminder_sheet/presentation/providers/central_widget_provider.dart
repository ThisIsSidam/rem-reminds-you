import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/utils/logger/app_logger.dart';

part 'generated/central_widget_provider.g.dart';

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
    AppLogger.i('CentralWidgetNotifier initialized');
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
    AppLogger.i('BottomElementNotifier disposed');
    super.dispose();
  }
}
