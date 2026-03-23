class PublicidadModel {
  final int id;
  final String titulo;
  final String descripcion;

  PublicidadModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
  });

  factory PublicidadModel.fromJson(Map<String, dynamic> json) {
    return PublicidadModel(
      id: json['id'] ?? json['id_publicidad'] ?? 0,
      titulo:
          json['titulo'] ?? json['titulo_promocion'] ?? 'Promoción Especial',
      descripcion:
          json['descripcion'] ??
          json['descripcion_promocion'] ??
          '¡Aprovecha esta oferta en nuestra clínica!',
    );
  }
}
