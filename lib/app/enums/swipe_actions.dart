import 'package:flutter/material.dart';
import '../../core/extensions/context_ext.dart';

typedef SwipeActionPair = ({SwipeAction start, SwipeAction end});

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

  String localizedName(BuildContext context) {
    if (this == none) {
      return context.local.swipeActionNone;
    } else if (this == done) {
      return context.local.swipeActionDone;
    } else if (this == delete) {
      return context.local.swipeActionDelete;
    } else if (this == postpone) {
      return context.local.swipeActionPostpone;
    } else if (this == doneAndDelete) {
      return context.local.swipeActionDoneAndDelete;
    } else {
      return 'Unknown';
    }
  }

  static SwipeAction fromString(String value) {
    try {
      return SwipeAction.values.firstWhere(
        (SwipeAction option) =>
            option.toString().toLowerCase() == value.toLowerCase(),
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
