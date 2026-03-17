import '../models/pago_model.dart';

class PagosService {
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  // Función para obtener los pagos del paciente
  static Future<List<PagoModel>> obtenerHistorialPagos(int idPaciente) async {
    try {
      /* // === CÓDIGO REAL (Cuando el equipo haga el endpoint GET) ===
      final response = await http.get(Uri.parse('$baseUrl/pagos/$idPaciente'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => PagoModel.fromJson(item)).toList();
      }
      return [];
      */

      // === SIMULADOR TEMPORAL ===
      await Future.delayed(const Duration(seconds: 1));

      return [
        PagoModel(
          id: 1,
          concepto: "Mensualidad Ortodoncia",
          monto: 800.0,
          fecha: DateTime.now().add(const Duration(days: 5)), // Vence en 5 días
          estado: "pendiente",
        ),
        PagoModel(
          id: 2,
          concepto: "Estudio Radiográfico",
          monto: 350.0,
          fecha: DateTime.now().subtract(
            const Duration(days: 30),
          ), // Se pagó hace 1 mes
          estado: "pagado",
        ),
        PagoModel(
          id: 3,
          concepto: "Pago Inicial Brackets",
          monto: 2500.0,
          fecha: DateTime.now().subtract(
            const Duration(days: 60),
          ), // Se pagó hace 2 meses
          estado: "pagado",
        ),
      ];
    } catch (e) {
      return [];
    }
  }

  // Función para simular la subida del comprobante
  static Future<bool> subirComprobante(int idPago) async {
    try {
      // === SIMULADOR TEMPORAL ===
      // Simulamos que la app está subiendo una imagen al servidor
      await Future.delayed(const Duration(seconds: 3));
      return true; // Retorna true si se subió con éxito
    } catch (e) {
      return false;
    }
  }
}
