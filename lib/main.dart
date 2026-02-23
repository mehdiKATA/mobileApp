import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Load saved session
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userId = prefs.getInt('userId');
  final fullName = prefs.getString('fullName');
  final email = prefs.getString('email');
  final creditScore = prefs.getInt('creditScore') ?? 0;

  runApp(
    MyApp(
      isLoggedIn: isLoggedIn,
      userId: userId,
      fullName: fullName,
      email: email,
      creditScore: creditScore,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final int? userId;
  final String? fullName;
  final String? email;
  final int creditScore;

  const MyApp({
    super.key,
    this.isLoggedIn = false,
    this.userId,
    this.fullName,
    this.email,
    this.creditScore = 0,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: null),
      home: DashboardPage(
        isLoggedIn: isLoggedIn,
        userId: userId,
        fullName: fullName,
        email: email,
        creditScore: creditScore,
      ),
    );
  }
}
