import 'package:expenz/services/theme_service.dart';
import 'package:expenz/services/user_details_service.dart';
import 'package:expenz/widgets/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await ThemeService.initTheme();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase not yet configured on this device: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, currentMode, child) {
        return FutureBuilder(
          future: UserService.checkUsername(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            } else {
              bool hasUsername = snapshot.data ?? false;
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                themeMode: currentMode,
                home: Wrapper(showMainScreen: hasUsername),
              );
            }
          },
        );
      },
    );
  }
}
