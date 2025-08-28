class CitaModel {
  final int id;
  final int clienteId;
  final String clienteNombre;
  final int manicuristaId;
  final String manicuristaNombre;
  final int estadoId;
  final String estadoNombre;
  final String fecha; // Formato: 'YYYY-MM-DD'
  final String hora; //formato HH:MM
  final String descripcion;
  final double total;

  CitaModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.manicuristaId,
    required this.manicuristaNombre,
    required this.estadoId,
    required this.estadoNombre,
    required this.fecha,
    required this.hora,
    required this.descripcion,
    required this.total,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      id: json['id'],
      clienteId: json['cliente_id'],
      clienteNombre: json['cliente_nombre'],
      manicuristaId: json['manicurista_id'],
      manicuristaNombre: json['manicurista_nombre'],
      fecha: json['fecha'],
      hora: json['hora'],
      estadoId: json['estado_id'],
      estadoNombre: json['estado_nombre'],
      total: (json['total'] as num).toDouble(),
      descripcion: json['descripcion'],
    );
  }
}
