class ClinicaModel {
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final String horarioSemana;
  final String horarioFinSemana;
  final String imagenUrl;

  ClinicaModel({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.horarioSemana,
    required this.horarioFinSemana,
    required this.imagenUrl,
  });

  factory ClinicaModel.fromJson(Map<String, dynamic> json) {
    return ClinicaModel(
      nombre: json['nombre'] ?? 'SAKARI Dental',
      direccion:
          json['direccion'] ?? json['domicilio'] ?? 'Centro, Tehuacán, Puebla',
      telefono: json['telefono'] ?? '+522381234567',
      email: json['email'] ?? 'contacto@sakari.com',
      horarioSemana:
          json['horario_semana'] ?? 'Lunes a Viernes: 09:00 AM - 07:00 PM',
      horarioFinSemana:
          json['horario_fin_semana'] ?? 'Sábados: 09:00 AM - 02:00 PM',
      imagenUrl:
          json['imagen_url'] ??
          'https://img.freepik.com/foto-gratis/silla-dentista-clinica-dental-moderna_155003-11681.jpg',
    );
  }
}
