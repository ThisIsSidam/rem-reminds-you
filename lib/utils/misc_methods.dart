import 'package:flutter/material.dart';

class MiscMethods {
  static void removeKeyboard(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool isKeyboardVisible = true;
    // Schedule a callback to be executed after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    });
    // Keep checking for keyboard visibility in a loop
    while (isKeyboardVisible) {
      // Delay for a short duration before checking again
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if the keyboard is still visible
      isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    }
    Future.delayed(Duration(seconds: 1));
  }
}
