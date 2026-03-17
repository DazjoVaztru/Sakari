import '../models/tratamiento_model.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class TratamientosService {
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  static Future<List<TratamientoModel>> obtenerCatalogo() async {
    try {
      /* // === CÓDIGO REAL (Descomentar cuando tu equipo haga el endpoint GET) ===
      final response = await http.get(Uri.parse('$baseUrl/tratamientos'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => TratamientoModel.fromJson(item)).toList();
      }
      return [];
      */

      // === SIMULADOR TEMPORAL (Usando tus datos de dentalconnect.sql) ===
      await Future.delayed(const Duration(seconds: 2));

      return [
        TratamientoModel(
          id: 1,
          nombre: "Consulta general",
          precio: 400.00,
          categoria: "General",
        ),
        TratamientoModel(
          id: 2,
          nombre: "Limpieza de Dientes",
          precio: 80.00,
          categoria: "Limpieza",
        ),
        TratamientoModel(
          id: 3,
          nombre: "Brackets",
          precio: 4000.00,
          categoria: "Estética",
        ),
      ];
    } catch (e) {
      return [];
    }
  }
}
