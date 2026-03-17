class TratamientoModel {
  final int id;
  final String nombre;
  final double precio;
  final String categoria;

  TratamientoModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
  });

  factory TratamientoModel.fromJson(Map<String, dynamic> json) {
    return TratamientoModel(
      id: json['id_servicio'] ?? 0,
      nombre: json['nombre_servicio'] ?? 'Servicio',
      // Convertimos el precio a double de forma segura
      precio: double.parse(json['precio_base']?.toString() ?? '0.0'),
      categoria: json['categoria'] ?? 'General',
    );
  }
}
