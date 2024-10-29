import 'dart:core';

enum SwipeAction {
  none,
  done,
  delete,
  postpone,
  doneAndDelete;

  @override
  String toString() {
    if (this == none) {
      return 'None';
    } else if (this == done) {
      return 'Done';
    } else if (this == delete) {
      return 'Delete';
    } else if (this == postpone) {
      return 'Postpone';
    } else if (this == doneAndDelete) {
      return 'Done/Delete';
    } else {
      return 'Unknown';
    }
  }

  static SwipeAction fromString(String value) {
    try {
      return SwipeAction.values.firstWhere(
        (option) => option.toString().toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      throw ArgumentError('Invalid setting option: $value');
    }
  }

  static SwipeAction fromIndex(int value) {
    return SwipeAction.values[value];
  }

  // .index to convert to int
}
