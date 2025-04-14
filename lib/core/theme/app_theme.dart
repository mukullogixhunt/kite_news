import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFE53935);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
        primary: primaryRed,
        onPrimary: Colors.white,
        secondary: Colors.blueGrey[600],
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        background: Colors.white,
        onBackground: Colors.black87,
        error: Colors.redAccent[700],
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: Colors.grey[900],
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardTheme(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(color: Colors.grey[200]!, width: 0.8),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        disabledColor: Colors.grey[300]!,
        selectedColor: primaryRed.withOpacity(0.1),
        secondarySelectedColor: Colors.blueGrey[100],
        labelStyle: TextStyle(
          color: Colors.grey[800],
          fontFamily: 'Inter',
          fontSize: 13,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.blueGrey[900],
          fontFamily: 'Inter',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        side: BorderSide.none,

        brightness: Brightness.light,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
        prefixIconColor: Colors.grey[600],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: primaryRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: Colors.redAccent[700]!, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(color: Colors.redAccent[700]!, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: Colors.grey[900],
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: Colors.grey[850],
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15.0,
          height: 1.5,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.0,
          height: 1.4,
          color: Colors.grey[800],
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          color: Colors.grey[600],
          fontSize: 12.0,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      dividerTheme: DividerThemeData(color: Colors.grey[200], thickness: 0.8),

      iconTheme: IconThemeData(color: Colors.grey[700], size: 22.0),

      visualDensity: VisualDensity.standard,
    );
  }
}
