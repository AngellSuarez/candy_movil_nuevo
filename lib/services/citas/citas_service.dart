import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CitasService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/cita-venta/citas-venta/';

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

  //obtener citas general
  Future<List<Map<String, dynamic>>> obtenerCitas() async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: headers),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  //obtener citas por manicurista
  Future<List<Map<String, dynamic>>> obtenerCitasManicurista(
    int manicuristaId,
  ) async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl/?manicurista_id=$manicuristaId/',
      options: Options(headers: headers),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  //citas por cliente
  Future<List<Map<String, dynamic>>> obtenerCitasCliente(int clienteId) async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl/?cliente_id=$clienteId/',
      options: Options(headers: headers),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  //detalles de cita
  Future<Map<String, dynamic>> obtenerDetallesCita(int id) async {
    final headers = await _getHeaders();
    final urlCita = '$baseUrl$id/';
    final urlServicios =
        'https://angelsuarez.pythonanywhere.com/api/cita-venta/servicios-cita/?cita_id=$id';

    try {
      // Petición para obtener los detalles de la cita
      final responseCita = await _dio.get(
        urlCita,
        options: Options(headers: headers),
      );
      Map<String, dynamic> citaData = Map<String, dynamic>.from(
        responseCita.data,
      );

      // Petición para obtener los servicios de la cita
      final responseServicios = await _dio.get(
        urlServicios,
        options: Options(headers: headers),
      );
      List<Map<String, dynamic>> serviciosData =
          List<Map<String, dynamic>>.from(responseServicios.data);

      // Combinar los datos en un solo mapa
      citaData['servicios'] = serviciosData;

      return citaData;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Error al obtener los detalles de la cita: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Error de red: ${e.message}');
      }
    }
  }

  //crear citas - agregar servicios en batch
  Future<Map<String, dynamic>> crearCita(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      baseUrl,
      data: data,
      options: Options(headers: headers),
    );

    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Error al crear la cita: ${response.data}');
    }
  }

  Future<void> agregarServicioCitaBatch(
    List<Map<String, dynamic>> serviciosData,
  ) async {
    final headers = await _getHeaders();
    final urlServicios =
        'https://angelsuarez.pythonanywhere.com/api/cita-venta/servicios-cita/batch/';

    final response = await _dio.post(
      urlServicios,
      data: serviciosData,
      options: Options(headers: headers),
    );

    if (response.statusCode != 201 || response.statusCode != 200) {
      throw Exception('Error al agregar servicios en batch: ${response.data}');
    }
  }

  Future<void> eliminarCita(int id) async {
    final token = await _getToken();
    await _dio.delete(
      'https://angelsuarez.pythonanywhere.com/api/cita-venta/citas-venta/$id/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  //horas - horarios disponibles

  Future<List<String>> getHorariosNovedades({
    required int manicuristaId,
    required String fecha,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      'https://angelsuarez.pythonanywhere.com/api/manicurista/novedades/horarios-disponibles/',
      data: {"manicurista_id": manicuristaId, "fecha": fecha},
      options: Options(headers: headers),
    );

    if (response.statusCode == 200) {
      // Este endpoint devuelve solo horas_disponibles
      return List<String>.from(response.data['horas_disponibles'] ?? []);
    } else {
      throw Exception("Error al obtener horarios de novedades");
    }
  }
}
