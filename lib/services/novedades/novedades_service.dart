import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NovedadesService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/manicurista/novedades/';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken() ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  //obtener novedades
  Future<List<Map<String, dynamic>>> obtenerNovedades() async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: headers),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  //crear una novedad
  Future<void> crearNovedad(Map<String, dynamic> datos) async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      baseUrl,
      data: datos,
      options: Options(headers: headers),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear la novedad: ${response.data}');
    }
  }

  //editar novedad
  Future<void> editarNovedad(int id, Map<String, dynamic> datos) async {
    final headers = await _getHeaders();
    final response = await _dio.put(
      '$baseUrl$id/',
      data: datos,
      options: Options(headers: headers),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al editar la novedad: ${response.data}');
    }
  }

  //eliminar novedad
  Future<void> eliminarNovedad(int id) async {
    final headers = await _getHeaders();
    final response = await _dio.delete(
      '$baseUrl$id/',
      options: Options(headers: headers),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la novedad: ${response.data}');
    }
  }
}
