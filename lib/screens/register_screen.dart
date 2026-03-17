import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importante para las validaciones de números
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
  bool _obscurePassword = true; // Variable para controlar el ojito

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

    // 2. Validar que el teléfono tenga exactamente 10 dígitos y solo sean números
    if (telefono.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El teléfono debe contener exactamente 10 números."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 3. Validar que la contraseña tenga al menos un carácter especial
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

    // 4. Mostrar carga
    setState(() => _isLoading = true);

    // 5. Llamar al servicio
    final resultado = await AuthService.activarCuenta(
      email,
      telefono,
      password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 6. Evaluar resultado
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

                  // Campo de Teléfono Modificado (10 dígitos, solo números)
                  TextFormField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Fuerza a que solo se escriban números
                    ],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.phone_android,
                        color: Colors.grey,
                      ),
                      labelText: "Teléfono (a 10 dígitos)",
                      counterText: "", // Oculta el texto de "0/10"
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Campo de Contraseña Modificado (con ojito)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                      labelText: "Crea una contraseña",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
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
