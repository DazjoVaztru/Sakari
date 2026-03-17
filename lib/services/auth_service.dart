import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // La URL base que ya comprobamos que funciona
  static const String baseUrl =
      'https://proyectosakaridentalconnect-production.up.railway.app/api';

  // --- 1. LOGIN REAL ---
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print('Intentando conectar a: $baseUrl/login');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // <-- Obliga a Laravel a responder JSON
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Código de estado HTTP (Login): ${response.statusCode}');
      print('Respuesta del servidor (Login): ${response.body}');

      if (response.body.startsWith('<')) {
        return {
          'success': false,
          'message': 'El servidor devolvió HTML. Revisa la ruta de la API.',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Bienvenido',
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? data['error'] ?? 'Credenciales incorrectas',
        };
      }
    } catch (e) {
      print('Error real en Login: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- 2. ACTIVAR CUENTA REAL ---
  static Future<Map<String, dynamic>> activarCuenta(
    String email,
    String telefono,
    String password,
  ) async {
    try {
      print('Intentando conectar a: $baseUrl/activar');
      final response = await http.post(
        Uri.parse('$baseUrl/activar'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // <-- Aplicado aquí también
        },
        body: jsonEncode({
          'email': email,
          'telefono': telefono,
          'password': password,
        }),
      );

      print('Código de estado HTTP (Activar): ${response.statusCode}');
      print('Respuesta del servidor (Activar): ${response.body}');

      if (response.body.startsWith('<')) {
        return {
          'success': false,
          'message': 'El servidor devolvió HTML. Revisa la ruta de la API.',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cuenta activada exitosamente.',
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? data['error'] ?? 'Error al activar cuenta.',
        };
      }
    } catch (e) {
      print('Error real en Activar Cuenta: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- 3. RECUPERAR CONTRASEÑA REAL ---
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('Intentando conectar a: $baseUrl/forgot-password');
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // <-- Aplicado aquí también
        },
        body: jsonEncode({'email': email}),
      );

      print('Código de estado HTTP (Forgot Pass): ${response.statusCode}');
      print('Respuesta del servidor (Forgot Pass): ${response.body}');

      if (response.body.startsWith('<')) {
        return {
          'success': false,
          'message': 'El servidor devolvió HTML. Revisa la ruta de la API.',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Correo enviado con éxito.',
        };
      } else {
        return {
          'success': false,
          'message':
              data['error'] ?? data['message'] ?? 'No se encontró el correo.',
        };
      }
    } catch (e) {
      print('Error real en Forgot Password: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
