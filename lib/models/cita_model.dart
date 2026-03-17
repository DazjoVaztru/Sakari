class CitaModel {
  final DateTime fechaHoraInicio;
  final String estadoCita;
  final String motivo;
  final String nombreDoctor;
  final String nombreServicio;

  CitaModel({
    required this.fechaHoraInicio,
    required this.estadoCita,
    required this.motivo,
    required this.nombreDoctor,
    required this.nombreServicio,
  });

  // Esta función transforma el JSON de la base de datos a un objeto de Flutter
  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      fechaHoraInicio: DateTime.parse(json['fecha_hora_inicio']),
      estadoCita: json['estado_cita'] ?? 'pendiente',
      motivo: json['motivo'] ?? 'Consulta',
      nombreDoctor: json['nombre_doctor'] ?? 'Dr. Asignado',
      nombreServicio: json['nombre_servicio'] ?? 'Servicio Dental',
    );
  }
}
