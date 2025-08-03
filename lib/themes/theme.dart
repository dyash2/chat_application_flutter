import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Colors.green, // Main brand color
    onPrimary: Colors.white, // Text/icon color on primary
    secondary: Colors.grey, // Secondary color for accents
    onSecondary: Colors.white, // Text/icon color on secondary
    tertiary: Colors.black, // Additional UI color
    onTertiary: Colors.white, // Text/icon color on tertiary
    error: Colors.red, // Error state color
    onError: Colors.white, // Text/icon color on error
    surface: Colors.white, // Background of cards, sheets, etc.
    onSurface: Colors.black, // Text/icon color on surface
  ),
);
