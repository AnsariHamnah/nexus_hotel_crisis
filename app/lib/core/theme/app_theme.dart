import 'package:flutter/material.dart';

class AppTheme {
  // Dark mode ready
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.red,
      // Stitch UI references to go here
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.red,
      // Stitch UI references to go here
    );
  }
}
