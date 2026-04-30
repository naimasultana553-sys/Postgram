import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const mobileBackgroundColor = Color.fromRGBO(0, 0, 0, 1);
const webBackgroundColor = Color.fromRGBO(18, 18, 18, 1);
const mobileSearchColor = Color.fromRGBO(38, 38, 38, 1);
const blueColor = Color.fromRGBO(0, 149, 246, 1);
const primaryColor = Colors.white;
const secondaryColor = Colors.grey;
const accentColor = Color(0xFF6C63FF); // A nice purple for productivity features

class AppTheme {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: mobileBackgroundColor,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: blueColor,
      secondary: accentColor,
      surface: mobileSearchColor,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: const TextStyle(color: primaryColor),
      bodyMedium: const TextStyle(color: primaryColor),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: mobileBackgroundColor,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
