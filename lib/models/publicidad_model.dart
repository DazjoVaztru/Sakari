class PublicidadModel {
  final String titulo;
  final String descripcion;
  final String? imagenPath; // Es opcional por si a veces no hay imagen

  PublicidadModel({
    required this.titulo,
    required this.descripcion,
    this.imagenPath,
  });

  factory PublicidadModel.fromJson(Map<String, dynamic> json) {
    return PublicidadModel(
      titulo: json['titulo'] ?? '¡Aprovecha nuestras ofertas!',
      descripcion:
          json['descripcion'] ??
          'Pregunta en clínica por los descuentos del mes.',
      imagenPath: json['imagen_path'],
    );
  }
}
