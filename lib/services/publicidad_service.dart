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
        final jsonData = jsonDecode(response.body);
        final data = jsonData['data'] ?? jsonData; // Sacamos el jugo

        // Si Laravel envía una lista, mostramos todas.
        if (data is List) {
          return data.map((e) => PublicidadModel.fromJson(e)).toList();
        }
        // Si Laravel envía solo 1 promoción (como actualmente), la metemos en una lista de 1 elemento para que el Carrusel no estalle.
        else if (data is Map<String, dynamic>) {
          return [PublicidadModel.fromJson(data)];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
