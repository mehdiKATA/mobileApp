import 'package:flutter/material.dart';
import 'welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Prevent Flutter Web from trying to download Roboto fonts
      theme: ThemeData(
        fontFamily: null, // Use system fonts to avoid Web font errors
      ),

      home: const WelcomePage(),
    );
  }
}
