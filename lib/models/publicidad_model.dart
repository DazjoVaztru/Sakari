class PublicidadModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String imagenUrl; // 👈 NUEVO: Variable para la imagen

  PublicidadModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl, // 👈 NUEVO
  });

  factory PublicidadModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return PublicidadModel(
      id: parseId(json['id'] ?? json['id_publicidad']),
      titulo:
          json['titulo']?.toString() ??
          json['titulo_promocion']?.toString() ??
          'Promoción Especial',
      descripcion:
          json['descripcion']?.toString() ??
          json['descripcion_promocion']?.toString() ??
          '¡Aprovecha esta oferta en nuestra clínica!',
      // 👇 NUEVO: Mapeamos la URL que manda Laravel
      imagenUrl: json['imagen_url']?.toString() ?? '',
    );
  }
}
