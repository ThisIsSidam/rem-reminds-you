import 'package:flutter/material.dart';

final ColorScheme appColorScheme = const ColorScheme(
  brightness: Brightness.light, // Change to Brightness.dark for dark theme
  primary: Color(0xFF0D47A1), // Dark Blue
  onPrimary: Color(0xFFFFFFFF), // White text/icons on primary
  primaryContainer: Color(0xFF1976D2), // Lighter shade of dark blue
  onPrimaryContainer: Color(0xFFFFFFFF), // White text/icons on primary container

  secondary: Color(0xFF1565C0), // Slightly lighter blue
  onSecondary: Color(0xFFFFFFFF), // White text/icons on secondary
  secondaryContainer: Color(0xFF64B5F6), // Light blue
  onSecondaryContainer: Color(0xFF000000), // Black text/icons on secondary container

  tertiary: Color(0xFF1E88E5), // Tertiary blue
  onTertiary: Color(0xFFFFFFFF), // White text/icons on tertiary
  tertiaryContainer: Color(0xFFBBDEFB), // Very light blue
  onTertiaryContainer: Color(0xFF000000), // Black text/icons on tertiary container

  error: Color(0xFFB00020), // Standard error red
  onError: Color(0xFFFFFFFF), // White text/icons on error
  errorContainer: Color(0xFFFDE7E9), // Light error background
  onErrorContainer: Color(0xFF000000), // Black text/icons on error container

  background: Color(0xFFFFFFFF), // White background
  onBackground: Color(0xFF000000), // Black text/icons on background

  surface: Color(0xFFE3F2FD), // Light surface color (light blue hint)
  onSurface: Color(0xFF000000), // Black text/icons on surface
  surfaceVariant: Color(0xFF90CAF9), // Muted blue for surface variants
  onSurfaceVariant: Color(0xFF000000), // Black text/icons on surface variant

  outline: Color(0xFFB0BEC5), // Subtle outline color (greyish blue)
  outlineVariant: Color(0xFFCFD8DC), // Lighter outline

  shadow: Color(0xFF000000), // Default shadow color (black)
  scrim: Color(0xFF000000), // Default scrim color (black)
  inverseSurface: Color(0xFF121212), // Darker background for inverse elements
  onInverseSurface: Color(0xFFFFFFFF), // White text/icons on inverse surface
  inversePrimary: Color(0xFF82B1FF), // Inverse primary (light blue)
  surfaceTint: Color(0xFF0D47A1), // Primary color for surface tint
);

final ColorScheme appDarkColorScheme = const ColorScheme(
  brightness: Brightness.dark,

  // Primary Colors
  primary: Color(0xFF0D47A1), // Dark Blue
  onPrimary: Color(0xFFFFFFFF), // White text/icons on primary
  primaryContainer: Color(0xFF1565C0), // Slightly lighter blue
  onPrimaryContainer: Color(0xFFFFFFFF), // White text/icons on primary container

  // Secondary Colors
  secondary: Color(0xFF1E88E5), // Bright blue
  onSecondary: Color(0xFF000000), // Black text/icons on secondary
  secondaryContainer: Color(0xFF1976D2), // Light blue variant
  onSecondaryContainer: Color(0xFFFFFFFF), // White text/icons on secondary container

  // Tertiary Colors
  tertiary: Color(0xFF64B5F6), // Soft blue
  onTertiary: Color(0xFF000000), // Black text/icons on tertiary
  tertiaryContainer: Color(0xFF42A5F5), // Light blue
  onTertiaryContainer: Color(0xFFFFFFFF), // White text/icons on tertiary container

  // Error Colors
  error: Color(0xFFCF6679), // Material Dark Error Red
  onError: Color(0xFF000000), // Black text/icons on error
  errorContainer: Color(0xFFB00020), // Deeper error red
  onErrorContainer: Color(0xFFFFFFFF), // White text/icons on error container

  // Background and Surface
  background: Color(0xFF121212), // Standard dark background
  onBackground: Color(0xFFFFFFFF), // White text/icons on background
  surface: Color(0xFF1E1E1E), // Slightly lighter dark surface
  onSurface: Color(0xFFFFFFFF), // White text/icons on surface
  surfaceVariant: Color(0xFF2C2C2C), // Muted dark surface variant
  onSurfaceVariant: Color(0xFFB0BEC5), // Greyish text/icons on surface variant

  // Miscellaneous
  outline: Color(0xFF5C6BC0), // Blue-tinted outline
  outlineVariant: Color(0xFF3949AB), // Deeper outline variant
  shadow: Color(0xFF000000), // Standard shadow color
  scrim: Color(0xFF000000), // Overlay background for modal dialogs
  inverseSurface: Color(0xFFE3F2FD), // Light surface in dark theme
  onInverseSurface: Color(0xFF000000), // Black text/icons on inverse surface
  inversePrimary: Color(0xFF82B1FF), // Inverse primary (light blue)
  surfaceTint: Color(0xFF0D47A1), // Primary color for tint effects
);

