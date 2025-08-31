import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_exports.dart';
import '../../services/auth/auth_service.dart';
import './widgets/citas_manicurista_screen.dart';
import './widgets/novedades_manicurista_screen.dart';

class ManicuristaDashboard extends StatefulWidget {
  const ManicuristaDashboard({super.key});

  @override
  State<ManicuristaDashboard> createState() => _ManicuristaDashboardState();
}

class _ManicuristaDashboardState extends State<ManicuristaDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  String nombre = "Cargando...";
  String apellido = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final n = await _authService.secureStorage.read(key: "nombre");
    final a = await _authService.secureStorage.read(key: "apellido");
    if (mounted) {
      setState(() {
        nombre = n ?? "Manicurista";
        apellido = a ?? "";
      });
    }
  }

  Future<void> _cerrarSesion() async {
    final result = await _authService.logout();
    if (!mounted) return;
    if (result['success']) {
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cerrar sesión: ${result['message']}")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Container(
              color: theme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.event), text: "Citas"),
                  Tab(icon: Icon(Icons.note_alt), text: "Novedades"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CitasManicuristaScreen(),
                  NovedadesManicuristaScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Hola, $nombre $apellido",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: "Cerrar Sesión",
            onPressed: _cerrarSesion,
            icon: Icon(Icons.logout, color: theme.colorScheme.error),
          ),
        ],
      ),
    );
  }
}
