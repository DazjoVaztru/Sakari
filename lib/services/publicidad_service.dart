import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/publicidad_model.dart';

class PublicidadService {
  static const String baseUrl =
      'https://proyectosakaridentalconnect-production.up.railway.app/api';

  static Future<List<PublicidadModel>> obtenerPromocionesActivas(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/publicidad'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Extraemos los datos, vengan como vengan
        var data =
            jsonResponse['data'] ?? jsonResponse['publicidad'] ?? jsonResponse;

        if (data is List) {
          return data.map((e) => PublicidadModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [PublicidadModel.fromJson(data)];
        }
      }
      return [];
    } catch (e) {
      print("Error Publicidad: $e");
      return [];
    }
  }
}
