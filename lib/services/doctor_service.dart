import '../models/doctor_model.dart';

class DoctorService {
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  static Future<DoctorModel?> obtenerPerfilDoctor(int idDoctor) async {
    try {
      /* // === CÓDIGO REAL (Descomentar cuando el equipo haga el endpoint GET) ===
      final response = await http.get(Uri.parse('$baseUrl/doctores/$idDoctor'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DoctorModel.fromJson(data);
      }
      return null;
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 2));

      // Retornamos los datos desde aquí para que tu pantalla los pinte dinámicamente
      return DoctorModel(
        id: idDoctor,
        nombreCompleto: "Dr. Marco Osorio",
        especialidad: "Cirujano Dentista - Ortodoncia",
        cedula: "12345678",
        telefono: "+522381234567", // Aquí ponemos el número de la clínica
        sobreMi:
            "Apasionado por crear sonrisas perfectas. Me especializo en tratamientos indoloros y estética dental avanzada. Mi objetivo es que pierdas el miedo al dentista.",
        anosExperiencia: "15+",
        calificacion: "4.9",
        pacientesAtendidos: "1k+",
        imagenUrl:
            "https://img.freepik.com/foto-gratis/doctor-sonriendo-con-estetoscopio_1154-36.jpg",
      );
    } catch (e) {
      return null;
    }
  }
}
