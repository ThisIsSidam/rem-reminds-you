import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        duration: Duration(seconds: 2),
      ),
    );
  }