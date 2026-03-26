class Doctor {
  final int id;
  final String nombreCompleto;
  final String cedula;
  final String especialidad;
  final String telefono;
  final String sobreMi;
  final String? fotoPerfilUrl;

  Doctor({
    required this.id,
    required this.nombreCompleto,
    required this.cedula,
    required this.especialidad,
    required this.telefono,
    required this.sobreMi,
    this.fotoPerfilUrl,
  });

  // Constructor que convierte el JSON de Laravel a nuestro Objeto Doctor
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id_doctor'] ?? 0,
      nombreCompleto: json['nombre_completo'] ?? 'Doctor',
      cedula: json['cedula'] ?? 'Sin registro',
      // Aquí están los campos preparados para cuando tus compañeros los agreguen a la BD
      especialidad: json['especialidad'] ?? 'Odontología General',
      telefono: json['telefono'] ?? '2382754845',
      sobreMi:
          json['sobre_mi'] ?? 'Hola, estoy aquí para cuidar de tu sonrisa.',
      fotoPerfilUrl: json['foto_perfil'], // Puede ser null
    );
  }
}
