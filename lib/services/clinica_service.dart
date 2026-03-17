import '../models/clinica_model.dart';

class ClinicaService {
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  static Future<ClinicaModel?> obtenerDatosClinica() async {
    try {
      /* // === CÓDIGO REAL (Descomentar cuando el equipo haga el endpoint GET) ===
      final response = await http.get(Uri.parse('$baseUrl/clinica/info'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClinicaModel.fromJson(data);
      }
      return null;
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 2));

      // Retornamos los datos quemados para simular la BD
      return ClinicaModel(
        nombre: "SAKARI Dental Connect",
        direccion: "Calle 1 Sur #123, Centro, Tehuacán, Puebla",
        telefono: "+522381234567",
        email: "hola@sakari.mx",
        horarioSemana: "Lunes a Viernes: 09:00 AM - 07:00 PM",
        horarioFinSemana: "Sábados: 09:00 AM - 02:00 PM (Domingos cerrado)",
        imagenUrl:
            "https://img.freepik.com/foto-gratis/silla-dentista-clinica-dental-moderna_155003-11681.jpg",
      );
    } catch (e) {
      return null;
    }
  }
}
