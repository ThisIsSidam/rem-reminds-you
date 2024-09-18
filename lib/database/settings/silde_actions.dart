import 'dart:core';

enum SlideAction {
  delete,
  postpone
}

class SlideActionHelper {

  // Using .toString for converting to String.

  static SlideAction fromString(String value) {
    try {
      return SlideAction.values.firstWhere(
        (option) => option.toString().toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      throw ArgumentError('Invalid setting option: $value');
    }
  }

  static SlideAction fromInt(int value) {
    return SlideAction.values[value];
  }

  static int toInt(SlideAction option) {
    return option.index;
  }
}