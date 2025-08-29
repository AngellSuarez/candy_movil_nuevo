import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = 'https://angelsuarez.pythonanywhere.com';

  AdminService() : _dio = Dio() {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    // Add interceptor for logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }

    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: 'access_token');
    } catch (e) {
      debugPrint('Error reading token: $e');
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken() ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<T> _handleApiCall<T>(Future<Response> Function() apiCall) async {
    try {
      final response = await apiCall();
      if (response.statusCode == 200) {
        return response.data as T;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Tiempo de conexión agotado';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Tiempo de respuesta agotado';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Error de conexión a internet';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = 'Sesión expirada, inicia sesión nuevamente';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'No tienes permisos para esta acción';
          } else if (e.response?.statusCode == 404) {
            errorMessage = 'Recurso no encontrado';
          } else if (e.response?.statusCode == 500) {
            errorMessage = 'Error interno del servidor';
          } else {
            errorMessage = 'Error del servidor: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Error de conexión: ${e.message}';
      }

      throw AdminServiceException(errorMessage, originalError: e);
    } catch (e) {
      throw AdminServiceException('Error inesperado: ${e.toString()}');
    }
  }

  // Ganancia semanal
  Future<Map<String, dynamic>> obtenerGananciaSemanal() async {
    return await _handleApiCall<Map<String, dynamic>>(() async {
      final headers = await _getHeaders();
      return await _dio.get(
        '/api/cita-venta/citas-venta/ganancia-semanal/',
        options: Options(headers: headers),
      );
    });
  }

  // Ganancia semana anterior
  Future<Map<String, dynamic>> obtenerGananciaSemanaAnterior() async {
    return await _handleApiCall<Map<String, dynamic>>(() async {
      final headers = await _getHeaders();
      return await _dio.get(
        '/api/cita-venta/citas-venta/ganancia-semanal-anterior/',
        options: Options(headers: headers),
      );
    });
  }

  // Servicios del día
  Future<List<Map<String, dynamic>>> obtenerServiciosDia() async {
    final response = await _handleApiCall<dynamic>(() async {
      final headers = await _getHeaders();
      return await _dio.get(
        '/api/cita-venta/citas-venta/servicios-dia/',
        options: Options(headers: headers),
      );
    });

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else if (response is Map) {
      return [Map<String, dynamic>.from(response)];
    } else {
      return [];
    }
  }

  // Servicios más vendidos del mes
  Future<List<Map<String, dynamic>>> obtenerServiciosMasVendidosMes() async {
    final response = await _handleApiCall<dynamic>(() async {
      final headers = await _getHeaders();
      return await _dio.get(
        '/api/cita-venta/servicios-cita/servicios-mas-vendidos-mes/',
        options: Options(headers: headers),
      );
    });

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else if (response is Map) {
      return [Map<String, dynamic>.from(response)];
    } else {
      return [];
    }
  }

  // Citas de la semana
  Future<List<Map<String, dynamic>>> obtenerCitasSemana() async {
    final response = await _handleApiCall<dynamic>(() async {
      final headers = await _getHeaders();
      return await _dio.get(
        '/api/cita-venta/citas-venta/citas-semana/',
        options: Options(headers: headers),
      );
    });

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      return [];
    }
  }

  // Top abastecimientos (manicuristas)
  Future<List<Map<String, dynamic>>> obtenerTopClientes() async {
    final response = await _handleApiCall<dynamic>(() async {
      final headers = await _getHeaders();
      return await _dio.get(
        'https://angelsuarez.pythonanywhere.com/api/cita-venta/citas-venta/clientes-top/',
        options: Options(headers: headers),
      );
    });

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      return [];
    }
  }

  // Método para verificar conectividad
  Future<bool> verificarConectividad() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/api/cita-venta/citas-venta/ganancia-semanal/',
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _dio.close();
  }
}

// Excepción personalizada para el servicio
class AdminServiceException implements Exception {
  final String message;
  final dynamic originalError;

  const AdminServiceException(this.message, {this.originalError});

  @override
  String toString() => 'AdminServiceException: $message';
}
