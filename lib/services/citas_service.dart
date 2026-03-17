import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cita_model.dart';

class CitasService {
  // Cuando tu equipo termine, pondremos aquí la URL real de Railway
  static const String baseUrl = 'http://10.0.2.2:4000/api';

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

      // === SIMULADOR TEMPORAL (Basado en tu dentalconnect.sql) ===
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulamos que va a internet

      return CitaModel(
        // Cambia el 01 por un 20 (o cualquier fecha que sea en el futuro)
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
        // Enviamos la nueva fecha en formato texto a la BD
        body: jsonEncode({'nueva_fecha': nuevaFecha.toIso8601String()}), 
      );
      return response.statusCode == 200; // Retorna true si fue exitoso
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 2)); // Simulamos el guardado
      return true; // Simulamos que la BD respondió con un "OK"
    } catch (e) {
      return false; // Si hay error de conexión, regresa false
    }
  }

  // Función para obtener los horarios disponibles de una fecha
  static Future<List<String>> obtenerHorariosDisponibles(DateTime fecha) async {
    try {
      /* // === CÓDIGO REAL (Descomentar cuando tu equipo haga el endpoint GET) ===
      // Ejemplo: mandaríamos la fecha al backend para que revise la tabla de citas y bloqueos
      final response = await http.get(Uri.parse('$baseUrl/citas/horarios?fecha=${fecha.toIso8601String()}'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((hora) => hora.toString()).toList();
      }
      return [];
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 1)); // Simulamos la carga

      // Simulamos que los fines de semana hay menos horarios disponibles
      if (fecha.weekday == DateTime.saturday ||
          fecha.weekday == DateTime.sunday) {
        return ["09:00 AM", "10:30 AM", "12:00 PM"];
      }

      // Horarios para entre semana
      return [
        "09:00 AM",
        "10:30 AM",
        "01:00 PM",
        "04:15 PM",
        "05:30 PM",
        "06:45 PM",
      ];
    } catch (e) {
      return [];
    }
  }

  // Función para AGENDAR una nueva cita
  static Future<bool> agendarNuevaCita(
    int idPaciente,
    int idServicio,
    DateTime fecha,
  ) async {
    try {
      /* // === CÓDIGO REAL (Cuando el equipo haga el endpoint POST) ===
      final response = await http.post(
        Uri.parse('$baseUrl/citas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_paciente': idPaciente,
          'id_servicio': idServicio,
          'fecha': fecha.toIso8601String()
        }),
      );
      return response.statusCode == 201; 
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }
}
