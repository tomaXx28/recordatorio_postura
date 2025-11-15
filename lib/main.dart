import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'firebase_options.dart';
import 'services/notificaciones_services.dart'; // o el nombre real del archivo

 final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Inicializar zonas horarias
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Santiago'));

  // 2) Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3) Notificaciones
  await NotificationService().init();


  // 4) Correr app
  runApp(const PostureRemindersApp());
}
