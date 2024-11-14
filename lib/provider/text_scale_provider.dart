import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/settings_db.dart';
import '../utils/logger/global_logger.dart';

class TextScaleNotifier extends ChangeNotifier {
  TextScaleNotifier() {
    gLogger.i('TextScaleNotifier initialized');
  }

  @override
  void dispose() {
    gLogger.i('TextScaleNotifier disposed');
    super.dispose();
  }

  double get textScale {
    final dynamic value = SettingsDB.getUserSetting('textScale');
    if (value == null || value is! double) {
      return 1.0;
    }
    return value;
  }

  set textScale(double value) {
    SettingsDB.setUserSetting('textScale', value);
    notifyListeners();
  }
}

final textScaleProvider = ChangeNotifierProvider((ref) => TextScaleNotifier());
