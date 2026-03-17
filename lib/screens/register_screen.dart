import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _obscurePassword = true;

  void _activarCuenta() async {
    final email = _emailController.text.trim();
    final telefono = _telefonoController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || telefono.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor llena todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (telefono.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El teléfono debe contener exactamente 10 números."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La contraseña debe incluir al menos un carácter especial (ej. #, !).",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final resultado = await AuthService.activarCuenta(
      email,
      telefono,
      password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resultado['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
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

                  // Usamos buildInput con las nuevas opciones para el teléfono
                  buildInput(
                    Icons.phone_android,
                    "Teléfono (a 10 dígitos)",
                    controller: _telefonoController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 15),

                  // Usamos buildInput con el ojito para la contraseña
                  buildInput(
                    Icons.lock_outline,
                    "Crea una contraseña",
                    isPassword: _obscurePassword, // Vinculado a la variable
                    controller: _passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
