import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    primarySwatch: Colors.amber,
    primaryColor: Colors.amber,
    scaffoldBackgroundColor: Colors.white, // Light amber background
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black, // Ensures contrast
      elevation: 0,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.amber[700], // Darker amber for buttons
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // Light amber fill for text fields
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.amber),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.amber[700]!, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.black),
      labelStyle: const TextStyle(color: Colors.black),
    ),
  );
}
