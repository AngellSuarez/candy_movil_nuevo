class EstadoCitaModel {
  final int id;
  final String estado;

  EstadoCitaModel({required this.id, required this.estado});

  factory EstadoCitaModel.fromJson(Map<String, dynamic> json) {
    return EstadoCitaModel(id: json['id'], estado: json['Estado']);
  }
}
