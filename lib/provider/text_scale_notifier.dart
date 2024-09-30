import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextScaleNotifier extends ChangeNotifier {
  double textScale = UserDB.getSetting(SettingOption.TextScale);

  void changeTextScale(double newScale) {
    textScale = newScale;
    UserDB.setSetting(SettingOption.TextScale, newScale);
    notifyListeners();
  }
}

final textScaleProvider = ChangeNotifierProvider<TextScaleNotifier>((ref) {
  return TextScaleNotifier();
});