class CitaModel {
  final int id;
  final DateTime fechaHoraInicio;
  final String estadoCita;
  final String motivo;
  final String nombreDoctor;
  final String nombreServicio;
  final bool haSidoReagendada;
  final String tipsHigiene;
  final String cuidados;

  CitaModel({
    required this.id,
    required this.fechaHoraInicio,
    required this.estadoCita,
    required this.motivo,
    required this.nombreDoctor,
    required this.nombreServicio,
    this.haSidoReagendada = false,
    this.tipsHigiene = "",
    this.cuidados = "",
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    // Extracción segura del nombre del Doctor
    String doctorName = 'Dr. Asignado';
    if (json['doctor'] != null && json['doctor']['usuario'] != null) {
      doctorName =
          "Dr. ${json['doctor']['usuario']['nombre'] ?? ''} ${json['doctor']['usuario']['apellido_paterno'] ?? ''}"
              .trim();
    } else if (json['nombre_doctor'] != null) {
      doctorName = json['nombre_doctor'];
    }

    // Extracción segura del Servicio/Tratamiento
    String servicioName = json['motivo'] ?? 'Consulta';
    if (json['detalles'] != null && json['detalles'].isNotEmpty) {
      var primerDetalle = json['detalles'][0];
      if (primerDetalle['servicio'] != null) {
        servicioName =
            primerDetalle['servicio']['nombre_servicio'] ?? servicioName;
      }
    } else if (json['nombre_servicio'] != null) {
      servicioName = json['nombre_servicio'];
    }

    return CitaModel(
      id: json['id'] ?? json['id_cita'] ?? 0,
      fechaHoraInicio: DateTime.parse(json['fecha_hora_inicio']),
      estadoCita: json['estado_cita'] ?? 'pendiente',
      motivo: json['motivo'] ?? 'Consulta',
      nombreDoctor: doctorName,
      nombreServicio: servicioName,
      haSidoReagendada:
          json['notas'] != null &&
          json['notas'].toString().contains('⚠️ REAGENDADA POR PACIENTE'),
      tipsHigiene: json['tips_pdf_url']?.toString() ?? '',
      cuidados: json['cuidados_pdf_url']?.toString() ?? '',
    );
  }
}
