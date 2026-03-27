import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor_model.dart';
import 'auth_service.dart'; // Para usar la baseUrl

class DoctorService {
  // --- OBTENER LISTA DE DOCTORES ---
  // Ahora devolvemos una List<Doctor> muy limpia y tipada
  static Future<List<Doctor>> getDoctores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/paciente/doctores'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          // Convertimos la lista JSON a una lista de objetos Doctor
          List<dynamic> doctoresJson = decoded['doctores'];
          return doctoresJson.map((json) => Doctor.fromJson(json)).toList();
        }
      }
      return []; // Si no hay éxito, regresamos una lista vacía
    } catch (e) {
      print('Error al obtener doctores: $e');
      return [];
    }
  }
}
