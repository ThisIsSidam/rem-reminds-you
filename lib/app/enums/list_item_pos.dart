import 'package:flutter/material.dart';

/// Shows the position of a list item in a list
/// so we can round the top and bottom one's borders while
/// leaving the middle ones..
enum ListItemPos {
  top,
  bottom,
  middle;

  BorderRadius getBorderRadius({double radius = 12}) => switch (this) {
    top => .vertical(top: .circular(radius)),
    bottom => .vertical(bottom: .circular(radius)),
    _ => .zero,
  };
}
