import 'package:flutter/material.dart';

class MaterialContainer extends StatelessWidget {
  final Widget child;
  final double elevation;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const MaterialContainer({
    super.key,
    required this.child,
    this.elevation = 0,
    this.color,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        elevation: elevation,
        borderRadius: borderRadius,
        child: Container(
          color: color ?? Theme.of(context).colorScheme.primaryContainer,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}