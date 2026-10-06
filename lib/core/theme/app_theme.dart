import 'package:flutter/material.dart';

/// Paleta institucional (Tabla 66 de TT2).
class AppTheme {
  static const Color guinda = Color(0xFF750946);
  static const Color guindaClaro = Color(0xFF9B3D6E);
  static const Color guindaOscuro = Color(0xFF4A0630);
  static const Color grisClaro = Color(0xFFF2F0F0);
  static const Color grisInactivo = Color(0xFF636569);
  static const Color negro = Color(0xFF231F20);

  // Colores semánticos: solo para calificaciones y estados de entrega (sección 4.8.1)
  static const Color verdeExito = Color(0xFF2E7D32);
  static const Color amarilloParcial = Color(0xFFF9A825);
  static const Color rojoDeficiente = Color(0xFFC62828);

  // Tipografía (sección 4.8.2, Tabla 67): Noto Sans en toda la app y Noto Sans Mono para
  // calificaciones y códigos de acceso
  static const String fuente = 'NotoSans';
  static const String fuenteMono = 'NotoSansMono';
  // En Mono el punto decimal ocupa un ancho completo; en las calificaciones grandes se ve separado
  static const double espaciadoCifras = -2;

  static ThemeData get theme => ThemeData(
        fontFamily: fuente,
        colorScheme: ColorScheme.fromSeed(
          seedColor: guinda,
          primary: guinda,
          error: rojoDeficiente,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
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
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: guinda,
            side: const BorderSide(color: guinda, width: 1.5),
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
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: grisClaro, width: 1.5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: guinda,
          unselectedItemColor: grisInactivo,
          type: BottomNavigationBarType.fixed,
        ),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      );
}
