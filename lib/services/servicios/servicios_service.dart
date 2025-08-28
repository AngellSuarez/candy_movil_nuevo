import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiciosService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/servicio/servicio/';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  //obtener los servicios
  Future<List<Map<String, dynamic>>> obtenerServicios() async {
    final token = await _getToken();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  //crear un servicio
  Future<void> crearServicio(
    Map<String, dynamic> datos,
    String pathImage,
  ) async {
    final token = await _getToken();
    final formData = FormData.fromMap({
      ...datos,
      'imagen': await MultipartFile.fromFile(
        pathImage,
        filename: pathImage.split('/').last,
      ),
    });

    final response = await _dio.post(
      baseUrl,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear el servicio: ${response.data}');
    }
  }

  //editar servicio
  Future<void> editarServicio(
    int id,
    Map<String, dynamic> datos, {
    String? pathImagen,
  }) async {
    final token = await _getToken();
    final formData = FormData.fromMap({
      ...datos,
      if (pathImagen != null)
        'imagen': await MultipartFile.fromFile(
          pathImagen,
          filename: pathImagen.split('/').last,
        ),
    });

    final response = await _dio.put(
      'baseUrl$id/',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar el servicio: ${response.data}');
    }
  }

  //eliminar servicio
  Future<void> eliminarServicio(int id) async {
    final token = await _getToken();
    final response = await _dio.delete(
      '$baseUrl$id/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el servicio: ${response.data}');
    }
  }
}
