import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _activarCuenta() async {
    final email = _emailController.text.trim();
    final telefono = _telefonoController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validar campos vacíos
    if (email.isEmpty || telefono.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor llena todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Mostrar carga
    setState(() => _isLoading = true);

    // 3. Llamar al servicio
    final resultado = await AuthService.activarCuenta(
      email,
      telefono,
      password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 4. Evaluar resultado
    if (resultado['success']) {
      // Si existe en la BD, se activa y regresa al Login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      // Si NO existe, lanza la alerta roja
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.red,
          duration: const Duration(
            seconds: 4,
          ), // Le damos más tiempo para que lo lea
        ),
      );
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.how_to_reg, size: 60, color: Color(0xFF0277BD)),
              const SizedBox(height: 10),
              const Text(
                "Activar mi Cuenta",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF014F7E),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Para usar la app, debes estar registrado previamente en la clínica por tu dentista.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),

              buildFormCard(
                context,
                title: "Verifica tus datos",
                children: [
                  buildInput(
                    Icons.email_outlined,
                    "Correo electrónico",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 15),
                  buildInput(
                    Icons.phone_android,
                    "Teléfono (a 10 dígitos)",
                    controller: _telefonoController,
                  ),
                  const SizedBox(height: 15),
                  buildInput(
                    Icons.lock_outline,
                    "Crea una contraseña",
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 25),

                  _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF0277BD),
                        )
                      : buildPrimaryButton(
                          context,
                          "Activar Cuenta",
                          _activarCuenta,
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
