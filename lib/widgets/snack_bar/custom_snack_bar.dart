import 'package:flutter/material.dart';

SnackBar buildCustomSnackBar(
    {Key? key,
    required Widget content,
    Duration duration = const Duration(seconds: 5)}) {
  return SnackBar(
    elevation: 2,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    duration: duration,
    key: key,
    content: content,
  );
}
