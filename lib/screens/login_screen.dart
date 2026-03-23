import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';
import 'main_dashboard.dart';
import 'recovery_screen.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _iniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor llena todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Llamada real al servicio
    final resultado = await AuthService.login(email, password);

    if (resultado['success'] == true) {
      String tokenDefinitivo =
          resultado['access_token'] ?? resultado['token'] ?? "";

      // Instanciamos SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // 1. Guardamos el Token para mantener la sesión
      await prefs.setString('token', tokenDefinitivo);

      // 🔴 2. GUARDAMOS EL NOMBRE Y CORREO REALES DEL PACIENTE 🔴
      // Accedemos al objeto 'user' que devuelve tu backend de Laravel
      var usuarioData = resultado['user'];

      if (usuarioData != null) {
        // Tu API en Laravel devuelve 'nombre_completo'
        await prefs.setString(
          'nombre',
          usuarioData['nombre_completo'] ?? 'Paciente',
        );
        await prefs.setString(
          'email',
          usuarioData['email'] ?? 'correo@sakary.com',
        );
      } else {
        // Valores por defecto por si falla la estructura del JSON
        await prefs.setString('nombre', 'Paciente');
        await prefs.setString('email', 'correo@sakary.com');
      }

      if (mounted) {
        // Redirigimos al Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message'] ?? "Error de inicio de sesión"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ... (El resto de tu código de UI en el método build se queda exactamente igual) ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1F5FE), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: Color(0xFF0277BD),
                ),
                const SizedBox(height: 10),
                const Text(
                  "DentalConnect",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF014F7E),
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "Tu sonrisa, nuestra prioridad",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                buildFormCard(
                  context,
                  title: "Iniciar Sesión",
                  children: [
                    buildInput(
                      Icons.email_outlined,
                      "Correo electrónico",
                      controller: _emailController,
                    ),
                    const SizedBox(height: 15),

                    // Contraseña usando tu buildInput con el ojito
                    buildInput(
                      Icons.lock_outline,
                      "Contraseña",
                      isPassword: _obscurePassword, // Vinculado al estado
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

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecoveryScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "¿Olvidaste tu contraseña?",
                          style: TextStyle(color: Color(0xFF0277BD)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF0277BD),
                          )
                        : buildPrimaryButton(
                            context,
                            "Ingresar",
                            _iniciarSesion,
                          ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿No tienes cuenta?",
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Regístrate aquí",
                        style: TextStyle(
                          color: Color(0xFF0277BD),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
