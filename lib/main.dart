import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications (Android + iOS)
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: null),
      home: const DashboardPage(), // Start with dashboard (not logged in)
    );
  }
}
