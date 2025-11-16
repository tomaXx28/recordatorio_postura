import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recordatorios_postura/auth/login_sreen.dart';
import 'package:recordatorios_postura/state/reminder_controller.dart';
import 'package:recordatorios_postura/auth/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recordatorios_postura/firebase_options.dart';
import 'package:recordatorios_postura/screens/home_scren.dart';

class PostureRemindersApp extends StatelessWidget {
  const PostureRemindersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recordatorios de postura',
        theme: _accessibleTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

final ThemeData _accessibleTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF9F6FF),
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6C63FF),
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 20),
    bodyMedium: TextStyle(fontSize: 18),
    labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    labelStyle: const TextStyle(fontSize: 18),
    hintStyle: TextStyle(fontSize: 18, color: Colors.grey[700]),
  ),
);



class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
