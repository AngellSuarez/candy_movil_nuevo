class ManicuristaModel {
  final String nombre;
  final String apellido;
  final String tipoDocumento;
  final String numeroDocumento;
  final String correo;
  final String celular;
  final String estado;
  final String fechaNacimiento;
  final String fechaContratacion;
  final String usernameOut;
  final int rolIdOut;
  final int usuarioId;

  ManicuristaModel({
    required this.nombre,
    required this.apellido,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.correo,
    required this.celular,
    required this.estado,
    required this.fechaNacimiento,
    required this.fechaContratacion,
    required this.usernameOut,
    required this.rolIdOut,
    required this.usuarioId,
  });

  factory ManicuristaModel.fromJson(Map<String, dynamic> json) {
    return ManicuristaModel(
      nombre: json['nombre'],
      apellido: json['apellido'],
      tipoDocumento: json['tipo_documento'],
      numeroDocumento: json['numero_documento'],
      correo: json['correo'],
      celular: json['celular'],
      estado: json['estado'],
      fechaNacimiento: json['fecha_nacimiento'],
      fechaContratacion: json['fecha_contratacion'],
      usernameOut: json['username_out'],
      rolIdOut: json['rol_id_out'],
      usuarioId: json['usuario_id'],
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}
