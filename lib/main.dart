import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:recordatorios_postura/auth/login_sreen.dart';
import 'package:recordatorios_postura/screens/home_scren.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'auth/auth_service.dart';
import 'state/reminder_controller.dart';
import 'main.dart' show navigatorKey;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ReminderController()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: StreamBuilder(
          stream: AuthService().authStateChanges,
          builder: (_, snapshot) {
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
        ),
      ),
    );
  }
}
