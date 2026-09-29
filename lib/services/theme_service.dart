import 'package:expenz/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = "isDarkMode";

  // ValueNotifier for reactive theme mode updates throughout the app
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;

  // Initialize theme from SharedPreferences on app startup
  static Future<void> initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Toggle or set theme mode explicitly and persist to SharedPreferences
  static Future<void> toggleTheme([bool? setDarkMode]) async {
    final newDark = setDarkMode ?? (themeNotifier.value != ThemeMode.dark);
    themeNotifier.value = newDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newDark);
  }
}

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: kMainColor,
      scaffoldBackgroundColor: const Color(0xFFF9F9FB),
      cardColor: kWhite,
      fontFamily: "Inter",
      colorScheme: const ColorScheme.light(
        primary: kMainColor,
        secondary: kMainColor,
        surface: kWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: kBlack),
        titleTextStyle: TextStyle(
          color: kBlack,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kWhite,
        selectedItemColor: kMainColor,
        unselectedItemColor: kGrey,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: kMainColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      fontFamily: "Inter",
      colorScheme: const ColorScheme.dark(
        primary: kMainColor,
        secondary: kMainColor,
        surface: Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: kWhite),
        titleTextStyle: TextStyle(
          color: kWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: kMainColor,
        unselectedItemColor: kGrey,
      ),
    );
  }
}
