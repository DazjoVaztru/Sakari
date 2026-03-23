import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clinica_model.dart';

class ClinicaService {
  static const String baseUrl =
      'https://proyectosakaridentalconnect-production.up.railway.app/api';

  static Future<ClinicaModel?> obtenerDatosClinica(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/clinicas-doctores',
        ), // Mantenemos la ruta que confirmaste
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --- EL TRADUCTOR DEFINITIVO ---
        // Buscamos la información en todas las llaves comunes que usa Laravel
        var infoClinica =
            data['clinica'] ??
            data['clinicas'] ??
            data['data'] ??
            data['configuracion'] ??
            data;

        // Si es una lista (varias sucursales), tomamos la primera
        if (infoClinica is List && infoClinica.isNotEmpty) {
          return ClinicaModel.fromJson(infoClinica[0]);
        }
        // Si es un objeto directo (un solo SaaS)
        else if (infoClinica is Map<String, dynamic>) {
          return ClinicaModel.fromJson(infoClinica);
        }
      }
      return null;
    } catch (e) {
      print("Error al obtener clínica: $e");
      return null;
    }
  }
}
