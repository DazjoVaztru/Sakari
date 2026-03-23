class PublicidadModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String? imagenPath; // Es opcional por si a veces no hay imagen

  PublicidadModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.imagenPath,
  });

  factory PublicidadModel.fromJson(Map<String, dynamic> json) {
    return PublicidadModel(
      id: json['id'] ?? json['id_publicidad'] ?? 0,
      // Le decimos a Flutter que busque el nombre corto o el nombre largo de la base de datos
      titulo: json['titulo'] ?? json['titulo_promocion'] ?? 'Promoción Especial',
      descripcion: json['descripcion'] ?? json['descripcion_promocion'] ?? 'Aprovecha esta oferta',
      // Si tienes imagen, déjala igual
    );
  }
}
