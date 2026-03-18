import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cita_model.dart';

class CitasService {
  // URL real de Railway
  static const String baseUrl =
      'https://proyectosakaridentalconnect-production.up.railway.app/api';

  static Future<CitaModel?> obtenerProximaCita(int idPaciente) async {
    try {
      /* // === CÓDIGO REAL (Descomentar cuando tu equipo termine el endpoint) ===
      final response = await http.get(Uri.parse('$baseUrl/citas/proxima/$idPaciente'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CitaModel.fromJson(data);
      }
      return null;
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 2));

      return CitaModel(
        fechaHoraInicio: DateTime.parse("2026-03-20T13:50:00"),
        estadoCita: "pendiente",
        motivo: "Brackets",
        nombreDoctor: "Dr. Marco Osorio",
        nombreServicio: "Ortodoncia",
      );
    } catch (e) {
      return null;
    }
  }

  // Función para reagendar la cita
  static Future<bool> reagendarCita(int idCita, DateTime nuevaFecha) async {
    try {
      /* // === CÓDIGO REAL (Descomentar cuando tu equipo haga el endpoint PUT) ===
      final response = await http.put(
        Uri.parse('$baseUrl/citas/$idCita/reagendar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nueva_fecha': nuevaFecha.toIso8601String()}), 
      );
      return response.statusCode == 200;
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Función para obtener los horarios disponibles de una fecha
  // Función para obtener los horarios REALES disponibles de una fecha
  static Future<List<String>> obtenerHorariosDisponibles(
    String token,
    DateTime fecha,
  ) async {
    try {
      String fechaFormateada =
          "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse('$baseUrl/horas-disponibles?fecha=$fechaFormateada'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((hora) => hora.toString()).toList();
      }
      return [];
    } catch (e) {
      print("Error al obtener horarios: $e");
      return [];
    }
  }

  // ========================================================
  // NUEVA FUNCIÓN PARA AGENDAR CONECTADA A LA API REAL
  // ========================================================
  static Future<bool> agendarNuevaCita(
    String token,
    int idServicio,
    DateTime fecha,
    String horaSeleccionada, // Ej: "10:30 AM"
  ) async {
    try {
      // Formatear la fecha a YYYY-MM-DD
      String fechaFormateada =
          "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";

      // Convertir "10:30 AM" a formato militar "10:30" o "14:30"
      String horaMilitar = _convertirHoraMilitar(horaSeleccionada);

      final response = await http.post(
        Uri.parse('$baseUrl/agendar-cita'), // Apunta a tu ruta real
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_servicio': idServicio,
          'fecha': fechaFormateada,
          'hora': horaMilitar,
        }),
      );

      print("Respuesta al agendar: ${response.statusCode} - ${response.body}");
      return response.statusCode == 201;
    } catch (e) {
      print("Error al agendar cita: $e");
      return false;
    }
  }

  // Helper interno para transformar "10:30 PM" a "22:30"
  static String _convertirHoraMilitar(String horaAmPm) {
    int horas = int.parse(horaAmPm.split(":")[0]);
    String minutos = horaAmPm.split(":")[1].substring(0, 2);
    String amPm = horaAmPm.split(" ")[1];

    if (amPm == "PM" && horas != 12) {
      horas += 12;
    } else if (amPm == "AM" && horas == 12) {
      horas = 0;
    }
    return "${horas.toString().padLeft(2, '0')}:$minutos";
  }

  static Future<Map<String, dynamic>> obtenerDiasBloqueados(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dias-bloqueados'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success']) {
          // Extraemos ambas listas
          return {
            'fechas': List<String>.from(
              jsonResponse['data']['fechas_bloqueadas'] ?? [],
            ),
            'dias_semana': List<int>.from(
              jsonResponse['data']['dias_semana_cerrados'] ?? [],
            ),
          };
        }
      }
      return {'fechas': [], 'dias_semana': []};
    } catch (e) {
      return {'fechas': [], 'dias_semana': []};
    }
  }
}
