class CitaModel {
  final int id;
  final DateTime fechaHoraInicio;
  final String estadoCita;
  final String motivo;
  final String nombreDoctor;
  final String nombreServicio;
  final bool haSidoReagendada;

  CitaModel({
    required this.id,
    required this.fechaHoraInicio,
    required this.estadoCita,
    required this.motivo,
    required this.nombreDoctor,
    required this.nombreServicio,
    this.haSidoReagendada = false,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      id: json['id'] ?? 0,
      fechaHoraInicio: DateTime.parse(json['fecha_hora_inicio']),
      estadoCita: json['estado_cita'] ?? 'pendiente',
      motivo: json['motivo'] ?? 'Consulta',
      nombreDoctor: json['nombre_doctor'] ?? 'Dr. Asignado',
      nombreServicio: json['nombre_servicio'] ?? 'Servicio Dental',
      // Dependiendo de cómo lo mande Laravel (1/0 o true/false)
      haSidoReagendada:
          json['ha_sido_reagendada'] == 1 || json['ha_sido_reagendada'] == true,
    );
  }
}
