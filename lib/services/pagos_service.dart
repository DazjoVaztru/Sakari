import 'dart:convert';
import 'package:http/http.dart' as http;

class PagosService {
  static const String baseUrl = 'https://proyectosakaridentalconnect-production.up.railway.app/api';

  static Future<Map<String, dynamic>> obtenerEstadoCuenta(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estado-cuenta'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']; // Retornamos toda la data (totales y el historial)
        }
      }
      return {};
    } catch (e) {
      print("Error en Pagos: $e");
      return {};
    }
  }

  // Función simulada para subir comprobante (la mantenemos igual por ahora)
  static Future<bool> subirComprobante(int idPago) async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      return true;
    } catch (e) {
      return false;
    }
  }
}
