import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 3: initialize notifications (Android + iOS)
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Keep system fonts (safe)
      theme: ThemeData(fontFamily: null),

      home: const WelcomePage(),
    );
  }
}
