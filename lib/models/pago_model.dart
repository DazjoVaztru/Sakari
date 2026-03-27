class PagoModel {
  final int id;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final String estado; 

  PagoModel({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
    required this.estado,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id_ingreso'] ?? json['id'] ?? 0,
      // Usamos el método de pago o alguna referencia que traiga Laravel
      concepto: json['metodo_pago'] ?? json['concepto'] ?? 'Abono a tratamiento', 
      monto: double.tryParse(json['monto']?.toString() ?? '0') ?? 0.0,
      fecha: DateTime.parse(json['created_at'] ?? json['fecha'] ?? DateTime.now().toIso8601String()),
      estado: 'pagado', // Si viene de la base de datos de ingresos, ya está pagado
    );
  }
}
