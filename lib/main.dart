import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const DentalConnectApp());
}

class DentalConnectApp extends StatelessWidget {
  const DentalConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dental Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0277BD),
        scaffoldBackgroundColor: const Color(0xFFE1F5FE),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0277BD)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
