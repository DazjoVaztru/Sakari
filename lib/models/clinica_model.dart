class ClinicaModel {
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final String imagenUrl;
  final List<Map<String, dynamic>> horariosLista;

  ClinicaModel({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.horariosLista,
    required this.imagenUrl,
  });

  factory ClinicaModel.fromJson(Map<String, dynamic> json) {
    // Convertimos los días de tu BD (0=Domingo, 1=Lunes, etc.) a texto legible
    const nombresDias = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    List<Map<String, dynamic>> horariosProcesados = [];

    if (json['horarios'] != null) {
      for (var h in json['horarios']) {
        int numDia = h['dia_semana'] ?? 0;
        bool estaActivo = h['activo'] == 1 || h['activo'] == true;

        // Cortamos los segundos de la hora (ej: de "09:00:00" a "09:00")
        String hrInicio = h['hora_inicio'] != null
            ? h['hora_inicio'].toString().substring(0, 5)
            : '';
        String hrFin = h['hora_fin'] != null
            ? h['hora_fin'].toString().substring(0, 5)
            : '';

        horariosProcesados.add({
          'dia': nombresDias[numDia],
          'horas': estaActivo ? '$hrInicio - $hrFin' : 'Cerrado',
          'esCerrado': !estaActivo,
        });
      }
    }

    return ClinicaModel(
      nombre:
          json['nombre_comercial'] ?? json['nombre'] ?? 'SAKARI Dental Connect',
      direccion:
          json['direccion_completa'] ?? json['direccion'] ?? 'Tehuacán, Puebla',
      telefono: json['numero_telefono'] ?? json['telefono'] ?? '2381234567',
      email: json['email'] ?? 'contacto@sakaridental.com',
      // Busca la foto de tu DB, si está vacío, pone una clínica hermosa por defecto
      imagenUrl:
          json['imagen_url'] ??
          json['foto_clinica'] ??
          'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?q=80&w=800&auto=format&fit=crop',
      horariosLista: horariosProcesados,
    );
  }
}
