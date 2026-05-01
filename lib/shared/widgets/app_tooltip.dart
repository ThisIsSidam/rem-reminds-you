import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/extensions/context_ext.dart';

class AppTooltip extends StatelessWidget {
  const AppTooltip({
    required this.message,
    this.child,
    this.size = 24,
    super.key,
  });

  final String message;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 7),
      padding: const EdgeInsets.all(16),
      message: message,
      textStyle: TextStyle(color: context.colors.onSurface),
      constraints: BoxConstraints.tightFor(
        width: math.min(300, MediaQuery.sizeOf(context).width),
      ),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 1)],
      ),
      child: child ?? Icon(Icons.info, size: size),
    );
  }
}
