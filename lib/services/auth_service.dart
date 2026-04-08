import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Bienvenido',
          'access_token': jsonResponse['access_token'],
          'data': jsonResponse['data'],
          'user': jsonResponse['user'],
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
      // 🚀 Ahora apuntamos directamente a Laravel usando la baseUrl
      final String laravelApiUrl = '$baseUrl/recuperar-password';

      print('Intentando conectar a Laravel: $laravelApiUrl');

      final response = await http.post(
        Uri.parse(laravelApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
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

      // Si Node.js devuelve un 200, fue exitoso
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Correo enviado con éxito.',
        };
      } else {
        return {
          'success': false,
          'message':
              data['error'] ??
              data['message'] ??
              'No se pudo enviar el correo.',
        };
      }
    } catch (e) {
      print('Error en forgotPassword: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Recuperamos el token de Sanctum

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/paciente/perfil/actualizar'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Función para cambiar contraseña
  static Future<Map<String, dynamic>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/paciente/perfil/password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- OBTENER DATOS DEL PERFIL ---
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/paciente/perfil'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- SUBIR FOTO DE PERFIL ---
  static Future<Map<String, dynamic>> uploadProfileImage(File imagen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/paciente/perfil/foto'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('foto_perfil', imagen.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Foto actualizada exitosamente',
          'data': jsonDecode(responseBody),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al subir la foto',
          'data': jsonDecode(responseBody),
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
