import 'package:flutter/foundation.dart';
import 'metricas_service.dart';
import '../novedades/novedades_manicurista_service.dart'; // para ManicuristasApi

class DashboardRepository {
  final AdminService _adminService;

  DashboardRepository() : _adminService = AdminService();

  // Cache for dashboard data
  Map<String, dynamic>? _cachedData;
  DateTime? _lastFetchTime;

  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  bool get _isCacheValid {
    if (_cachedData == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<DashboardData> getDashboardData({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) {
      return DashboardData.fromJson(_cachedData!);
    }

    try {
      // Fetch all data concurrently
      final results =
          await Future.wait([
            _adminService.obtenerGananciaSemanal(),
            _adminService.obtenerGananciaSemanaAnterior(),
            _adminService.obtenerServiciosDia(),
            _adminService.obtenerServiciosMasVendidosMes(),
            _adminService.obtenerCitasSemana(),
            _adminService.obtenerTopClientes(),
            ManicuristasApi().obtenerManicuristasActivos(),
          ]).timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw AdminServiceException('Tiempo de espera agotado'),
          );

      final dashboardData = {
        'gananciaActual': results[0],
        'gananciaAnterior': results[1],
        'serviciosDia': results[2],
        'serviciosPopulares': results[3],
        'citasSemana': results[4],
        'topClientes': results[5],
        'manicuristasActivos': (results[6] is List)
            ? (results[6] as List).length
            : 0,
        'fetchTime': DateTime.now().toIso8601String(),
      };

      // Update cache
      _cachedData = dashboardData;
      _lastFetchTime = DateTime.now();

      return DashboardData.fromJson(dashboardData);
    } catch (e) {
      if (_cachedData != null) {
        debugPrint('Using cached data due to error: $e');
        return DashboardData.fromJson(_cachedData!);
      }
      debugPrint('Returning empty data due to error: $e');
      return DashboardData.empty();
    }
  }

  Future<bool> checkConnectivity() async {
    return await _adminService.verificarConectividad();
  }

  void clearCache() {
    _cachedData = null;
    _lastFetchTime = null;
  }

  void dispose() {
    _adminService.dispose();
  }
}

class DashboardData {
  final double gananciaActual;
  final double gananciaAnterior;
  final List<Map<String, dynamic>> serviciosDia;
  final List<Map<String, dynamic>> serviciosPopulares;
  final List<Map<String, dynamic>> citasSemana;
  final List<Map<String, dynamic>> topClientes;
  final int manicuristasActivos;
  final DateTime? fetchTime;

  DashboardData({
    required this.gananciaActual,
    required this.gananciaAnterior,
    required this.serviciosDia,
    required this.serviciosPopulares,
    required this.citasSemana,
    required this.topClientes,
    required this.manicuristasActivos,
    this.fetchTime,
  });

  static int _extractInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      gananciaActual: _extractDouble(json['gananciaActual'], 'ganancia_total'),
      gananciaAnterior: _extractDouble(
        json['gananciaAnterior'],
        'ganancia_total',
      ),
      serviciosDia: _extractList(json['serviciosDia']),
      serviciosPopulares: _extractList(json['serviciosPopulares']),
      citasSemana: _extractList(json['citasSemana']),
      topClientes: _extractList(json['topClientes']),
      manicuristasActivos: _extractInt(json['manicuristasActivos']),
      fetchTime: json['fetchTime'] != null
          ? DateTime.tryParse(json['fetchTime'])
          : null,
    );
  }

  factory DashboardData.empty() {
    return DashboardData(
      gananciaActual: 0.0,
      gananciaAnterior: 0.0,
      serviciosDia: [],
      serviciosPopulares: [],
      citasSemana: _getDefaultWeekData(),
      topClientes: [],
      manicuristasActivos: 0,
    );
  }

  static double _extractDouble(dynamic source, String key) {
    if (source is Map<String, dynamic>) {
      final value = source[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static List<Map<String, dynamic>> _extractList(dynamic source) {
    if (source is List) {
      return source.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (source is Map) {
      return [Map<String, dynamic>.from(source)];
    }
    return [];
  }

  static List<Map<String, dynamic>> _getDefaultWeekData() {
    return [
      {'name': 'Monday', 'Pendiente': 0, 'Terminada': 0},
      {'name': 'Tuesday', 'Pendiente': 0, 'Terminada': 0},
      {'name': 'Wednesday', 'Pendiente': 0, 'Terminada': 0},
      {'name': 'Thursday', 'Pendiente': 0, 'Terminada': 0},
      {'name': 'Friday', 'Pendiente': 0, 'Terminada': 0},
      {'name': 'Saturday', 'Pendiente': 0, 'Terminada': 0},
      {'name': 'Sunday', 'Pendiente': 0, 'Terminada': 0},
    ];
  }

  // Computed properties
  String get porcentajeCambio {
    if (gananciaAnterior == 0) return '+0%';
    final cambio =
        ((gananciaActual - gananciaAnterior) / gananciaAnterior) * 100;
    return '${cambio >= 0 ? '+' : ''}${cambio.toStringAsFixed(1)}%';
  }

  int get totalCitasHoy {
    return citasSemana
        .where((dia) => dia['name'] == 'Thursday')
        .fold(
          0,
          (sum, dia) =>
              sum + (dia['Pendiente'] as int) + (dia['Terminada'] as int),
        );
  }

  int get citasPendientesHoy {
    return citasSemana
        .where((dia) => dia['name'] == 'Thursday')
        .fold(0, (sum, dia) => sum + (dia['Pendiente'] as int));
  }

  bool get hasData {
    return gananciaActual > 0 ||
        serviciosDia.isNotEmpty ||
        serviciosPopulares.isNotEmpty ||
        topClientes.isNotEmpty ||
        manicuristasActivos > 0;
  }

  String get lastUpdateText {
    if (fetchTime == null) return 'Sin actualizar';
    final now = DateTime.now();
    final difference = now.difference(fetchTime!);

    if (difference.inMinutes < 1) {
      return 'Recién actualizado';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
