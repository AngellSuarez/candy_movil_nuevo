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

  // obtener citas por manicurista
  Future<List<Map<String, dynamic>>> obtenerCitasManicurista(
    int manicuristaId,
  ) async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl?manicurista_id=$manicuristaId',
      options: Options(headers: headers),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // citas por cliente
  Future<List<Map<String, dynamic>>> obtenerCitasPorCliente(
    int clienteId,
  ) async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl?cliente_id=$clienteId',
      options: Options(headers: headers),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  // obtener detalles de una cita
  Future<Map<String, dynamic>> obtenerDetallesCita(int id) async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl$id/',
      options: Options(headers: headers),
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> obtenerServiciosDeCita(int citaId) async {
    final headers = await _getHeaders();
    final url =
        'https://angelsuarez.pythonanywhere.com/api/cita-venta/servicios-cita/';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {'cita_id': citaId},
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al obtener servicios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o servidor: $e');
    }
  }

  // crear nueva cita
  Future<Map<String, dynamic>> crearCita(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      baseUrl,
      data: data,
      options: Options(headers: headers),
    );
    return Map<String, dynamic>.from(response.data);
  }

  // crear servicios a una cita (batch)
  Future<void> agregarServicioCitaBatch(
    List<Map<String, dynamic>> serviciosData,
  ) async {
    final headers = await _getHeaders();
    final urlServicios =
        'https://angelsuarez.pythonanywhere.com/api/cita-venta/servicios-cita/batch/';

    print('Payload a enviar en batch: $serviciosData');

    final response = await _dio.post(
      urlServicios,
      data: serviciosData,
      options: Options(headers: headers),
    );

    print(
      'Respuesta de la API de batch: ${response.statusCode} - ${response.data}',
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
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
  Future<List<String>> getHorasDisponibles({
    required int manicuristaId,
    required String fecha,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      'https://angelsuarez.pythonanywhere.com/api/cita-venta/citas-venta/horas-disponibles/',
      queryParameters: {"manicurista_id": manicuristaId, "fecha": fecha},
      options: Options(headers: headers),
    );

    if (response.statusCode == 200) {
      final List<dynamic> horas = response.data['horas_disponibles'] ?? [];
      return List<String>.from(horas);
    } else {
      throw Exception('Error al obtener horarios: ${response.data}');
    }
  }
}
