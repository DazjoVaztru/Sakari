import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // NUEVO IMPORT PARA ACCESIBILIDAD
import 'screens/login_screen.dart';

void main() {
  runApp(const DentalConnectApp());
}

class DentalConnectApp extends StatelessWidget {
  const DentalConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ACCESIBILIDAD: Título que lee el lector de pantalla al cambiar entre aplicaciones
      title: 'Dental Connect',
      debugShowCheckedModeBanner: false,

      // ACCESIBILIDAD: Forzar el idioma a español para que TalkBack/VoiceOver
      // pronuncie todo correctamente y traduzca etiquetas nativas (ej. "Atrás", "Cerrar")
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'MX'), // Español de México
        Locale('es', 'ES'), // Español genérico
      ],

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
