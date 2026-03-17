import '../models/publicidad_model.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class PublicidadService {
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  static Future<PublicidadModel?> obtenerPromocionActiva() async {
    try {
      /* // === CÓDIGO REAL (Descomentar cuando tu equipo haga el endpoint) ===
      final response = await http.get(Uri.parse('$baseUrl/publicidad/activa'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PublicidadModel.fromJson(data);
      }
      return null;
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 2));

      return PublicidadModel(
        titulo: "Mes de la Ortodoncia",
        descripcion:
            "Inicia tu tratamiento con 30% de descuento en el pago inicial.",
      );
    } catch (e) {
      return null;
    }
  }
}
