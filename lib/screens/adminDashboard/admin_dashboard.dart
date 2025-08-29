import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../core/app_exports.dart';
import './widgets/tarjeta_citas.dart';
import './widgets/metricas_dashboard.dart';
import './widgets/tarjeta_accion_rapida.dart';
import './widgets/perfomance_manicuristas.dart';
import './widgets/tarjeta_servicios.dart';
import './widgets/ganancias_grafica.dart';
import '../../services/metricas/dashboard_repository.dart';
import '../../services/auth/auth_service.dart'; // Importar el servicio de autenticación
import './widgets/citas_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  late DashboardRepository _repository;
  DashboardData? _dashboardData;
  final AuthService _authService = AuthService(); // Instanciar AuthService

  String adminName = "Cargando...";
  String currentDate = "Cargando...";

  // Computed values using repository data
  double get gananciaActual => _dashboardData?.gananciaActual ?? 0.0;
  double get gananciaAnterior => _dashboardData?.gananciaAnterior ?? 0.0;
  List<Map<String, dynamic>> get serviciosDia =>
      _dashboardData?.serviciosDia ?? [];
  List<Map<String, dynamic>> get serviciosPopulares =>
      _dashboardData?.serviciosPopulares ?? [];
  List<Map<String, dynamic>> get citasSemana =>
      _dashboardData?.citasSemana ?? [];
  List<Map<String, dynamic>> get topClientes =>
      _dashboardData?.topClientes ?? [];
  int get manicuristasActivos => _dashboardData?.manicuristasActivos ?? 0;

  String get porcentajeCambio => _dashboardData?.porcentajeCambio ?? '+0%';
  int get totalCitasHoy => _dashboardData?.totalCitasHoy ?? 0;
  int get citasPendientesHoy => _dashboardData?.citasPendientesHoy ?? 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _repository = DashboardRepository();

    Future.microtask(() async {
      await initializeDateFormatting(
        "es",
        null,
      ); // ✅ Inicializar locale español
      await _loadAdminData();
      await _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _repository.dispose();
    super.dispose();
  }

  // Nuevo método para cargar el nombre y la fecha
  Future<void> _loadAdminData() async {
    final nombre = await _authService.secureStorage.read(key: 'nombre');
    final apellido = await _authService.secureStorage.read(key: 'apellido');

    // Obtener la fecha actual y formatearla
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es_ES');

    setState(() {
      adminName = "${nombre ?? ''} ${apellido ?? ''}".trim();
      currentDate = formatter.format(now);
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _repository.getDashboardData();
      setState(() {
        _dashboardData = data;
      });

      if (!data.hasData) {
        _showNoDataMessage();
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los datos: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _loadDashboardData,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showNoDataMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se encontraron datos recientes'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Actualizar',
            onPressed: () => _refreshDashboard(forceRefresh: true),
          ),
        ),
      );
    }
  }

  Future<void> _refreshDashboard({bool forceRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _repository.getDashboardData(
        forceRefresh: forceRefresh,
      );
      setState(() {
        _dashboardData = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildServicesTab(),
                  _buildAppointmentsTab(),
                  _buildNovedadesTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/appointment-booking-screen');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme
                    .lightTheme
                    .floatingActionButtonTheme
                    .foregroundColor!,
                size: 24,
              ),
              label: Text(
                'Nueva Cita',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme
                      .lightTheme
                      .floatingActionButtonTheme
                      .foregroundColor,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(
              alpha: 0.1,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $adminName',
                      style: AppTheme.lightTheme.textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      currentDate,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _refreshDashboard(forceRefresh: true),
                    tooltip:
                        _dashboardData?.lastUpdateText ?? 'Actualizar datos',
                    icon: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'refresh',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 24,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'Servicios'),
          Tab(text: 'Citas'),
          Tab(text: 'Novedades'),
          Tab(text: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_isLoading && _dashboardData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => _refreshDashboard(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Status Indicator
            if (_dashboardData != null)
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _dashboardData!.hasData
                      ? AppTheme.lightTheme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        )
                      : AppTheme.lightTheme.colorScheme.error.withValues(
                          alpha: 0.1,
                        ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: _dashboardData!.hasData
                          ? 'check_circle'
                          : 'error',
                      color: _dashboardData!.hasData
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.error,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _dashboardData!.hasData
                          ? 'Datos actualizados: ${_dashboardData!.lastUpdateText}'
                          : 'Sin datos disponibles - Toca para actualizar',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _dashboardData!.hasData
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 1.h),

            // Metrics Cards Row
            Row(
              children: [
                Expanded(
                  child: DashboardMetricsCard(
                    title: 'Servicios Populares',
                    value: serviciosPopulares.length.toString(),
                    subtitle: 'Este mes',
                    iconName: 'spa',
                    onTap: () {
                      _tabController.animateTo(1);
                    },
                  ),
                ),
                Expanded(
                  child: DashboardMetricsCard(
                    title: 'Personal Activo',
                    value: manicuristasActivos.toString(),
                    subtitle: 'Manicuristas',
                    iconName: 'people',
                    backgroundColor: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Acciones Rápidas',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 1.h),

            QuickActionCard(
              title: 'Agregar Servicio',
              description: 'Crear un nuevo servicio para el salón',
              iconName: 'add_circle',
              onTap: () {
                Navigator.pushNamed(context, '/servicios_admin');
              },
            ),

            QuickActionCard(
              title: 'Ver Horario de Hoy',
              description: 'Revisar todas las citas programadas',
              iconName: 'schedule',
              onTap: () {
                _tabController.animateTo(2);
              },
            ),

            SizedBox(height: 2.h),

            // Revenue Chart
            _buildRevenueChart(),

            // Weekly Appointments Overview
            _buildWeeklyAppointmentsCard(),

            // Popular Services
            _buildPopularServicesCard(),

            // Staff Performance
            _buildStaffPerformanceCard(),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    // Create revenue data structure for the chart
    final revenueData = {
      "diario": {
        "total": (gananciaActual / 7).toStringAsFixed(0),
        "chartData": _generateWeeklyChartData(),
      },
      "semanal": {
        "total": gananciaActual.toStringAsFixed(0),
        "chartData": _generateWeeklyChartData(),
      },
      "mensual": {
        "total": (gananciaActual * 4.3).toStringAsFixed(0), // Estimate monthly
        "chartData": _generateMonthlyChartData(),
      },
    };

    return RevenueChartCard(revenueData: revenueData);
  }

  List<double> _generateWeeklyChartData() {
    // Generate chart data based on weekly appointments
    final chartData = <double>[];
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (final day in daysOfWeek) {
      final dayData = citasSemana.firstWhere(
        (cita) => cita['name'] == day,
        orElse: () => {'Terminada': 0, 'Pendiente': 0},
      );

      final totalCitas =
          (dayData['Terminada'] as int) + (dayData['Pendiente'] as int);
      // Simulate revenue per appointment (you can adjust this logic)
      chartData.add(
        (totalCitas * 45000).toDouble(),
      ); // Assuming average service price
    }

    return chartData;
  }

  List<double> _generateMonthlyChartData() {
    // Generate monthly chart data (simulate 4 weeks)
    final weeklyRevenue = gananciaActual;
    return [
      weeklyRevenue * 0.8,
      weeklyRevenue * 0.9,
      weeklyRevenue * 1.1,
      weeklyRevenue,
      weeklyRevenue * 1.2,
      weeklyRevenue * 0.95,
      weeklyRevenue * 1.15,
    ];
  }

  Widget _buildWeeklyAppointmentsCard() {
    final appointments = <Map<String, dynamic>>[];

    // Convert citasSemana to appointment format for display
    for (final dia in citasSemana) {
      final dayName = dia['name'] as String;
      final pendiente = dia['Pendiente'] as int;
      final terminada = dia['Terminada'] as int;

      if (pendiente > 0 || terminada > 0) {
        appointments.add({
          'id': dayName,
          'clientName': _getDaySpanish(dayName),
          'services': ['$pendiente Pendientes', '$terminada Terminadas'],
          'time': '${pendiente + terminada} citas',
          'status': pendiente > 0 ? 'Pendiente' : 'Terminada',
          'manicurist': 'Varios',
        });
      }
    }

    return AppointmentOverviewCard(
      appointments: appointments,
      onViewAll: () {
        _tabController.animateTo(2);
      },
    );
  }

  Widget _buildPopularServicesCard() {
    final services = serviciosPopulares.map((servicio) {
      return {
        'id': servicio['name'],
        'name': servicio['name'] as String,
        'price':
            '\$45.00', // You might want to get real price from another endpoint
        'bookings': servicio['ventas'],
        'popularity': ((servicio['ventas'] as int) * 10).clamp(
          0,
          100,
        ), // Convert to percentage
        'image': null,
      };
    }).toList();

    return ServicesOverviewCard(
      popularServices: services,
      onViewAll: () {
        _tabController.animateTo(1);
      },
    );
  }

  Widget _buildStaffPerformanceCard() {
    final staff = topClientes.map((cliente) {
      return {
        'id': cliente['nombre'],
        'name': cliente['nombre'] as String,
        'completedAppointments': cliente['citas'],
        'rating': 4.5, // fijo o ajusta según lógica
        'performance': _getPerformanceLevel(cliente['citas'] as int),
        'avatar': null,
      };
    }).toList();

    return StaffPerformanceCard(
      staffPerformance: staff,
      onViewAll: () {
        // Navegar a detalle clientes
      },
    );
  }

  String _getDaySpanish(String englishDay) {
    const dayMap = {
      'Monday': 'Lunes',
      'Tuesday': 'Martes',
      'Wednesday': 'Miércoles',
      'Thursday': 'Jueves',
      'Friday': 'Viernes',
      'Saturday': 'Sábado',
      'Sunday': 'Domingo',
    };
    return dayMap[englishDay] ?? englishDay;
  }

  String _getPerformanceLevel(int pedidos) {
    if (pedidos >= 3) return 'Excelente';
    if (pedidos >= 2) return 'Bueno';
    if (pedidos >= 1) return 'Regular';
    return 'Bajo';
  }

  Widget _buildServicesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'spa',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Servicios',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gestiona y administra los servicios del salón',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/servicios_admin'),
            icon: const Icon(Icons.list_alt),
            label: const Text('Ver Servicios'),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/crear_servicio'),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Crear Servicio'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return CitasTab(
      totalCitasHoy: totalCitasHoy,
      citasPendientesHoy: citasPendientesHoy,
      onNuevaCita: () => Navigator.pushNamed(context, '/crear_cita'),
    );
  }

  Widget _buildNovedadesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'receipt',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Novedades',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gestiona y revisa las novedades del personal',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/novedades_admin'),
            icon: const Icon(Icons.list_alt),
            label: const Text('Ver Novedades'),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/crear_novedad'),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Crear Novedad'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.4,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                adminName.isNotEmpty
                    ? adminName.substring(0, 1).toUpperCase()
                    : '',
                style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            adminName,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Administrador',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          if (gananciaActual > 0) ...[
            Text(
              'Ingresos del negocio esta semana: \$${gananciaActual.toStringAsFixed(0)}',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
          ],
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () async {
              final authService = AuthService();
              final result = await authService.logout();

              if (result['success']) {
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/', // Asegúrate de que esta sea la ruta de tu pantalla de inicio de sesión
                    (route) => false,
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al cerrar sesión: ${result['message']}',
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
