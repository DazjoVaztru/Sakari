import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clinica_model.dart';

class ClinicaService {
  static const String baseUrl =
      'https://proyectosakaridentalconnect-production.up.railway.app/api';

  static Future<ClinicaModel?> obtenerDatosClinica(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clinicas-doctores'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Laravel a veces envía "clinicas", "clinica", "data" o el arreglo directamente
        var infoClinica =
            jsonResponse['clinicas'] ??
            jsonResponse['clinica'] ??
            jsonResponse['data'] ??
            jsonResponse;

        if (infoClinica is List && infoClinica.isNotEmpty) {
          return ClinicaModel.fromJson(infoClinica[0]);
        } else if (infoClinica is Map<String, dynamic>) {
          return ClinicaModel.fromJson(infoClinica);
        }
      }
      return null;
    } catch (e) {
      print("Error Clinica: $e");
      return null;
    }
  }
}
