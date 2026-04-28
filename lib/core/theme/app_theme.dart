import 'package:flutter/material.dart';

class AppTheme {
  static const Color guinda = Color(0xFF750946);
  static const Color grisInactivo = Color(0xFF636569);

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: guinda,
          primary: guinda,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: guinda,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: guinda,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: guinda, width: 2),
          ),
        ),
      );
}
