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
      child: Column(
        children: [
          SizedBox(height: 10,),
          Expanded(child: child),
        ],
      ),
    );
  }
}