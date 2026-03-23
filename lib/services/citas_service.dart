import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cita_model.dart';
import '../models/clinica_model.dart';

class CitasService {
  // URL real de Railway
  static const String baseUrl =
      'https://proyectosakaridentalconnect-production.up.railway.app/api';

  // --- 1. OBTENER PRÓXIMA CITA (REAL) ---
  // Ahora pasamos el token para la seguridad
  static Future<CitaModel?> obtenerProximaCita(String token) async {
    try {
      // 1. Usamos tu endpoint real del SaaS
      final response = await http.get(
        Uri.parse('$baseUrl/citas-proximas'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // 2. Extraemos la lista de citas
        List<dynamic> listaCitas = jsonResponse['data'] ?? jsonResponse;

        // 3. Tomamos la primera cita de la lista (que será la más próxima)
        if (listaCitas.isNotEmpty) {
          return CitaModel.fromJson(listaCitas.first);
        }
      }
      return null;
    } catch (e) {
      print("Error al obtener la cita: $e");
      return null;
    }
  }

  // --- 2. REAGENDAR CITA (REAL) ---
  static Future<Map<String, dynamic>> reagendarCita(
    String token,
    int idCita,
    DateTime fecha,
    String horaSeleccionada,
  ) async {
    try {
      String fechaFormateada =
          "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      String horaMilitar = _convertirHoraMilitar(horaSeleccionada);

      // Usamos POST (o PUT si tu API lo requiere así)
      final response = await http.post(
        Uri.parse('$baseUrl/citas/$idCita/reagendar'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fecha': fechaFormateada, 'hora': horaMilitar}),
      );

      final jsonResponse = jsonDecode(response.body);

      // Leemos los códigos de éxito reales
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Cita reagendada correctamente',
        };
      } else {
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Error desconocido del servidor',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión con el servidor'};
    }
  }

  // Añade esto debajo de tu función reagendarCita
  static Future<Map<String, dynamic>> confirmarCita(
    String token,
    int idCita,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/citas/$idCita/confirmar',
        ), // Asegúrate de que esta ruta exista en tu api.php
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Cita confirmada en el sistema'};
      } else {
        final jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Error al confirmar',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
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
  static Future<Map<String, dynamic>> agendarNuevaCita(
    String token,
    int idServicio,
    DateTime fecha,
    String horaSeleccionada,
  ) async {
    // ... (El código que te pasé en el paso anterior) ...
    try {
      String fechaFormateada =
          "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      String horaMilitar = _convertirHoraMilitar(horaSeleccionada);

      final response = await http.post(
        Uri.parse('$baseUrl/agendar-cita'),
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

      final jsonResponse = jsonDecode(response.body);

      // ✅ MAGIA: Aceptamos 200 y 201 como éxitos válidos
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Cita agendada correctamente',
        };
      } else {
        // 🔥 Si hay error (como el bloqueo de 1 al día), capturamos el mensaje real
        return {
          'success': false,
          'message':
              jsonResponse['message'] ?? 'Error desconocido del servidor',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión con el servidor'};
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

  static Future<ClinicaModel?> obtenerDatosClinica(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clinica'), // Ajusta la ruta exacta de tu API
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClinicaModel.fromJson(
          data['data'] ?? data,
        ); // Ajusta según tu JSON
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
