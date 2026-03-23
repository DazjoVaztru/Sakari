import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clinica_model.dart';

class ClinicaService {
  static const String baseUrl =
      'https://proyectosakaridentalconnect-production.up.railway.app/api';

  static Future<ClinicaModel?> obtenerDatosClinica(String token) async {
    try {
      final response = await http.get(
        // ¡CAMBIO CLAVE AQUÍ! Apuntamos al endpoint correcto
        Uri.parse('$baseUrl/clinicas-doctores'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extraemos los datos de la clínica (ajustado a la estructura de Laravel)
        var clinicaData =
            data['clinica'] ??
            (data['data'] != null && data['data'].isNotEmpty
                ? data['data'][0]
                : data);
        return ClinicaModel.fromJson(clinicaData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
