import 'package:flutter/material.dart';

class MiscMethods {
  static Future<void> removeKeyboard(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool isKeyboardVisible = true;
    // Schedule a callback to be executed after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    });
    // Keep checking for keyboard visibility in a loop
    while (isKeyboardVisible) {
      // Delay for a short duration before checking again
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Check if the keyboard is still visible
      if (!context.mounted) return;
      isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    }
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  static int compareVersions(String newV, String oldV) {
    final RegExp versionRegex = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');

    List<int> parseVersion(String version) {
      final RegExpMatch? match = versionRegex.firstMatch(version);
      if (match == null) {
        throw FormatException('Invalid version format: $version');
      }

      return <int>[
        int.parse(match.group(1) ?? '0'), // Major
        int.parse(match.group(2) ?? '0'), // Minor
        int.parse(match.group(3) ?? '0'), // Patch
        int.parse(match.group(4) ?? '0'), // Build metadata
      ];
    }

    final List<int> v1Parts = parseVersion(newV);
    final List<int> v2Parts = parseVersion(oldV);

    // Compare major, minor, patch, and build metadata
    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }

    return 0;
  }
}
