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
        Uri.parse('$baseUrl/publicidad'), // Ajusta la ruta de tu API
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body)['data']
                as List; // Ajusta si tu JSON es diferente
        return data.map((e) => PublicidadModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
