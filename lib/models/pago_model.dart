class PagoModel {
  final int id;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final String estado; // Puede ser 'pendiente' o 'pagado'

  PagoModel({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
    required this.estado,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id_pago'] ?? 0,
      concepto: json['concepto'] ?? 'Tratamiento Dental',
      monto: double.parse(json['monto']?.toString() ?? '0.0'),
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      estado: json['estado'] ?? 'pendiente',
    );
  }
}
