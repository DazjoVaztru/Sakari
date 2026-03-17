class DoctorModel {
  final int id;
  final String nombreCompleto;
  final String especialidad;
  final String cedula;
  final String telefono;
  final String sobreMi;
  final String anosExperiencia;
  final String calificacion;
  final String pacientesAtendidos;
  final String imagenUrl;

  DoctorModel({
    required this.id,
    required this.nombreCompleto,
    required this.especialidad,
    required this.cedula,
    required this.telefono,
    required this.sobreMi,
    required this.anosExperiencia,
    required this.calificacion,
    required this.pacientesAtendidos,
    required this.imagenUrl,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id_doctor'] ?? 1,
      nombreCompleto: json['nombre_completo'] ?? 'Doctor',
      especialidad: json['especialidad'] ?? 'Odontología General',
      cedula: json['cedula_profesional'] ?? 'Sin Cédula',
      telefono: json['telefono'] ?? '+520000000000',
      sobreMi: json['sobre_mi'] ?? 'Dentista profesional.',
      anosExperiencia: json['experiencia']?.toString() ?? '1+',
      calificacion: json['calificacion']?.toString() ?? '5.0',
      pacientesAtendidos: json['pacientes_atendidos']?.toString() ?? '100+',
      imagenUrl:
          json['imagen_url'] ??
          'https://img.freepik.com/foto-gratis/doctor-sonriendo-con-estetoscopio_1154-36.jpg',
    );
  }
}
