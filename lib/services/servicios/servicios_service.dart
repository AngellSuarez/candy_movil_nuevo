import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiciosService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Ajusta si tu base cambia; termina SIEMPRE con "/"
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/servicio/servicio/';

  Future<String?> _getToken() async => _storage.read(key: 'access_token');

  // Obtener servicios (lista)
  Future<List<Map<String, dynamic>>> obtenerServicios() async {
    final token = await _getToken();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Crear servicio (multipart con imagen obligatoria)
  Future<void> crearServicio(
    Map<String, dynamic> data,
    String? pathImagen,
  ) async {
    final formData = FormData.fromMap(data);
    final token = await _getToken();

    if (pathImagen != null) {
      formData.files.add(
        MapEntry("imagen", await MultipartFile.fromFile(pathImagen)),
      );
    }

    await _dio.post(
      "$baseUrl",
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  // Editar servicio (multipart; imagen opcional)
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
      '$baseUrl$id/', // <- FIX: interpolación correcta
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

  // Eliminar servicio
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
