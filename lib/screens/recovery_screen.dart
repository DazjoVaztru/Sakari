import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';
import '../services/auth_service.dart'; // Importamos nuestro nuevo servicio

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  // Controlador para leer el correo
  final TextEditingController _emailController = TextEditingController();

  // Variable para mostrar el circulo de carga
  bool _isLoading = false;

  // Función que se ejecuta al presionar el botón
  void _recuperarPassword() async {
    final email = _emailController.text.trim();

    // 1. Validar que no esté vacío
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa tu correo."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Mostrar estado de carga
    setState(() {
      _isLoading = true;
    });

    // 3. Llamar a la API de Node.js
    final result = await AuthService.forgotPassword(email);

    // 4. Ocultar estado de carga
    setState(() {
      _isLoading = false;
    });

    // 5. Mostrar el resultado (Verde si funcionó, Rojo si falló)
    if (!mounted)
      return; // Evita errores si el usuario cerró la pantalla antes de que respondiera la API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );

    // 6. Si fue exitoso, regresamos al Login
    if (result['success']) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF014F7E),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              buildFormCard(
                context,
                title: "Recuperar Contraseña",
                children: [
                  const Text(
                    "Ingresa tu correo para restablecer tu acceso.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Le pasamos el controlador al input
                  buildInput(
                    Icons.email_outlined,
                    "Correo",
                    controller: _emailController,
                  ),

                  const SizedBox(height: 25),

                  // Si está cargando mostramos el círculo, si no, el botón normal
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF0277BD),
                        )
                      : buildPrimaryButton(
                          context,
                          "Enviar Instrucciones",
                          _recuperarPassword,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
