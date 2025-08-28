import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ManicuristaService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/usuario/manicuristas/activos/';

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

  //obtener manicuristas activos
  Future<List<Map<String, dynamic>>> obtenerManicuristasActivos() async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: headers),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}
