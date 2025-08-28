class HorasDisponiblesModel {
  final List<String> horasDisponibles;
  final List<String> noRecomendables;

  HorasDisponiblesModel({
    required this.horasDisponibles,
    required this.noRecomendables,
  });

  factory HorasDisponiblesModel.fromJson(Map<String, dynamic> json) {
    return HorasDisponiblesModel(
      horasDisponibles: List<String>.from(json['horas_disponibles'] ?? []),
      noRecomendables: List<String>.from(json['no_recomendables'] ?? []),
    );
  }
}
