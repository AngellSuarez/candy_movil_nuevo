class ServicioModel {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String estado;
  final String tipo;
  final String urlImagen;

  ServicioModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.estado,
    required this.tipo,
    required this.urlImagen,
  });

  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      estado: json['estado'],
      tipo: json['tipo'],
      urlImagen: json['url_imagen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'estado': estado,
      'tipo': tipo,
      'url_imagen': urlImagen,
    };
  }
}
