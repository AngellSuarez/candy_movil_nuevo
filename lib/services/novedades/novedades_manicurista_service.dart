// lib/services/api_service.dart
import 'novedades_service.dart';
import '../manicuristas/manicurista_service.dart';

class NovedadesApi {
  final NovedadesService _svc = NovedadesService();

  Future<List<Map<String, dynamic>>> obtenerNovedades() =>
      _svc.obtenerNovedades();
  Future<void> crearNovedad(Map<String, dynamic> datos) =>
      _svc.crearNovedad(datos);
  Future<void> editarNovedad(int id, Map<String, dynamic> datos) =>
      _svc.editarNovedad(id, datos);
  Future<void> eliminarNovedad(int id) => _svc.eliminarNovedad(id);
}

class ManicuristasApi {
  final ManicuristaService _svc = ManicuristaService();

  Future<List<Map<String, dynamic>>> obtenerManicuristasActivos() =>
      _svc.obtenerManicuristasActivos();
}
