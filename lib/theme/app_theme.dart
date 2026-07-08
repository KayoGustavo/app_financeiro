import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── Paleta escura ─────────────────────────────────
  static const Color bg          = Color(0xFF111111);
  static const Color card        = Color(0xFF1E1E1E);
  static const Color card2       = Color(0xFF252525);
  static const Color border      = Color(0x12FFFFFF);

  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x73FFFFFF);

  static const Color green       = Color(0xFF4CAF50);
  static const Color greenBg     = Color(0x264CAF50);
  static const Color greenDark   = Color(0xFF2E7D32);

  static const Color red         = Color(0xFFF44336);
  static const Color redBg       = Color(0x1FF44336);

  static const Color receita     = Color(0xFF4CAF50);
  static const Color despesa     = Color(0xFFF44336);

  // ── Cores das categorias (mesma ordem das categoriasPadrao) ──
  static const List<Color> categoryCores = [
    Color(0xFF4CAF50), // Salário
    Color(0xFFFF9800), // Alimentação
    Color(0xFF2196F3), // Transporte
    Color(0xFF9C27B0), // Moradia
    Color(0xFFE91E63), // Lazer
    Color(0xFFF44336), // Saúde
    Color(0xFF00BCD4), // Investimentos
    Color(0xFF607D8B), // Outros
  ];

  // ── Tema escuro ───────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,

    colorScheme: const ColorScheme.dark(
      primary:     green,
      secondary:   greenDark,
      surface:     card,
      onPrimary:   Colors.white,
      onSecondary: Colors.white,
      onSurface:   textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: textPrimary,
      unselectedItemColor: Color(0x73FFFFFF),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 10),
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: green,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0x73FFFFFF)),
      hintStyle: const TextStyle(color: Color(0x40FFFFFF)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border, width: 0.5),
      ),
    ),

    dividerColor: border,
    fontFamily: 'Roboto',
  );
}