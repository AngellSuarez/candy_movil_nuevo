import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_exports.dart';
import '../../services/auth/auth_service.dart';
import './widgets/citas_cliente.dart';

class ClienteDashboard extends StatefulWidget {
  const ClienteDashboard({super.key});

  @override
  State<ClienteDashboard> createState() => _ClienteDashboardState();
}

class _ClienteDashboardState extends State<ClienteDashboard> {
  final AuthService _authService = AuthService();
  String nombreCliente = "Cargando...";
  String apellidoCliente = "";

  @override
  void initState() {
    super.initState();
    _cargarDatosCliente();
  }

  Future<void> _cargarDatosCliente() async {
    final nombre = await _authService.secureStorage.read(key: 'nombre');
    final apellido = await _authService.secureStorage.read(key: 'apellido');
    setState(() {
      nombreCliente = nombre ?? "Cliente";
      apellidoCliente = apellido ?? "";
    });
  }

  Future<void> _cerrarSesion() async {
    final result = await _authService.logout();
    if (result['success']) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/', // Ruta de inicio de sesión
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cerrar sesión: ${result['message']}")),
      );
    }
  }

  Future<void> _recargarDatos() async {
    // Solo refresca el widget de citas
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _recargarDatos,
                child:
                    const CitasClienteScreen(), // 👈 Directo, sin ListView padre
              ),
            ),
          ],
        ),
      ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Hola, $nombreCliente $apellidoCliente",
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: "Cerrar Sesión",
            onPressed: _cerrarSesion,
            icon: Icon(
              Icons.logout,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
