import 'package:flutter/material.dart';

/// To be updated to a lottie animation or something else
class SplashLoader extends StatelessWidget {
  const SplashLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
