class ClienteModel {
  final int usuarioId;
  final String nombre;
  final String apellido;
  final String tipoDocumento;
  final String correo;
  final String numeroDocumento;
  final String celular;
  final String estado;
  final String usernameOut;
  final int rolIdOut;

  ClienteModel({
    required this.usuarioId,
    required this.nombre,
    required this.apellido,
    required this.tipoDocumento,
    required this.correo,
    required this.numeroDocumento,
    required this.celular,
    required this.estado,
    required this.usernameOut,
    required this.rolIdOut,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      tipoDocumento: json['tipo_documento'],
      correo: json['correo'],
      numeroDocumento: json['numero_documento'],
      celular: json['celular'],
      estado: json['estado'],
      usernameOut: json['username_out'],
      rolIdOut: json['rol_id_out'],
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}
