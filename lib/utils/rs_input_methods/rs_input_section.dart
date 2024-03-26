import 'package:flutter/material.dart';

class RS_InputSection extends StatelessWidget {

  final Widget child;

  const RS_InputSection({
    super.key,
    required this.child
  });

  
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10, 
          vertical: 10
        ),
        child: child
      ),
    );
  }
}