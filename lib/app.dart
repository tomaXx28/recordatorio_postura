import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recordatorios_postura/main.dart';
import 'package:recordatorios_postura/screens/home_scren.dart';
import 'state/reminder_controller.dart';

class PostureRemindersApp extends StatelessWidget {
  const PostureRemindersApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReminderController(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Recordatorios de postura',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
