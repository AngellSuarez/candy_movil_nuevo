class ServicioCitaModel {
  final int id;
  final int citaId;
  final int servicioId;
  final String servicioNombre;
  final double subtotal;

  ServicioCitaModel({
    required this.id,
    required this.citaId,
    required this.servicioId,
    required this.servicioNombre,
    required this.subtotal,
  });

  factory ServicioCitaModel.fromJson(Map<String, dynamic> json) {
    return ServicioCitaModel(
      id: json['id'],
      citaId: json['cita_id'],
      servicioId: json['servicio_id'],
      servicioNombre: json['servicio_nombre'],
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
