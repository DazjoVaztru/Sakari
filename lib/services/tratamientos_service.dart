import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tratamiento_model.dart';

class TratamientosService {
  // Misma baseUrl que usamos en Auth
  static const String baseUrl =
      'https://proyectosakaridentalconnect-production.up.railway.app/api';

  // OJO: Le agregamos el token como parámetro, porque esta ruta es protegida
  static Future<List<TratamientoModel>> obtenerCatalogo(String token) async {
    try {
      print('Consultando tratamientos...');
      final response = await http.get(
        Uri.parse('$baseUrl/tratamientos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // ¡Clave para entrar a Sanctum!
        },
      );

      print('Código HTTP Tratamientos: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Convertimos el JSON de Laravel a la lista de TratamientoModel de Flutter
        return data.map((item) => TratamientoModel.fromJson(item)).toList();
      } else {
        print('Error del servidor: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error de conexión en Tratamientos: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerTratamientosActivos(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tratamientos-activos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(jsonResponse['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
