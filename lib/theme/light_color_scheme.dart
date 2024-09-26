import 'package:flutter/material.dart';

final ColorScheme defLightColorScheme = ColorScheme(
  // Primary colors
  primary: Color(0xFF3D7EFF), // Light blue color used for buttons and toggles
  onPrimary: Colors.white,
  primaryContainer: Color(0xFF1E3F7F), // Darker shade of primary
  onPrimaryContainer: Colors.white,

  // Secondary colors
  secondary: Color(0xFF3D7EFF), // Light blue, same as primary
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFF1E3F7F), // Darker shade of secondary
  onSecondaryContainer: Colors.white,

  // Tertiary colors (not visible in images, using variations of primary)
  tertiary: Color(0xFF5B8FFF), // Lighter shade of primary
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFF0A1F3F), // Very dark shade of primary
  onTertiaryContainer: Colors.white,

  // Error colors (not visible in images, using standard material colors)
  error: Colors.red,
  onError: Colors.white,
  errorContainer: Color(0xFF410E0B),
  onErrorContainer: Color(0xFFFFDAD6),

  // Neutral colors
  surface: Color(0xFF121212), // Slightly lighter than black for card backgrounds
  onSurface: Colors.white,
  surfaceContainerHighest: Color(0xFF2C2C2C), // Slightly lighter than surface
  onSurfaceVariant: Color(0xFFCACACA), // Light grey

  outline: Color(0xFF3D3D3D), // Dark grey for outlines
  outlineVariant: Color(0xFF2A2A2A), // Slightly darker than outline

  shadow: Colors.black,

  scrim: Colors.black54,

  inverseSurface: Colors.white,
  onInverseSurface: Colors.black,
  inversePrimary: Color(0xFF1A3366), // Dark blue

  // Brightness
  brightness: Brightness.dark, // The app uses a dark theme
);