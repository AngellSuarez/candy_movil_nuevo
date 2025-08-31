import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login/login_screen.dart';
import 'theme/app_theme.dart';

import 'screens/adminDashboard/admin_dashboard.dart';
import 'screens/adminDashboard/novedades_admin.dart';
import 'screens/novedades/crear_novedades.dart';
import 'screens/manejoServicios/crear_servicio.dart';
import 'screens/manejoServicios/manejo_servicios.dart';
import 'screens/creacion_cita/creacion_cita_screen.dart';
import 'screens/creacion_cita/cita_detalle_admin.dart';

import 'screens/clienteDashboard/cliente_dashboard.dart';
import 'screens/manicuristaDashboard/manicurista_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CandySoft',
            theme: AppTheme.lightTheme,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/news-feed':
                  return MaterialPageRoute(
                    builder: (_) => const PlaceholderScreen(title: 'News Feed'),
                  );
                case '/admin-dashboard':
                  return MaterialPageRoute(
                    builder: (_) => const AdminDashboard(),
                  );
                case '/cliente-dashboard':
                  return MaterialPageRoute(
                    builder: (_) => const ClienteDashboard(),
                  );
                case '/manicurista-dashboard':
                  return MaterialPageRoute(
                    builder: (_) => const ManicuristaDashboard(),
                  );
                case '/novedades_admin':
                  return MaterialPageRoute(
                    builder: (_) => const NovedadesAdminPage(),
                  );
                case '/crear_novedad':
                  return MaterialPageRoute(
                    builder: (_) => const CrearNovedadPage(),
                  );
                case '/crear_servicio':
                  return MaterialPageRoute(
                    builder: (_) => const CrearServicioPage(),
                  );
                case '/servicios_admin':
                  return MaterialPageRoute(
                    builder: (_) => const ServiciosAdminPage(),
                  );
                case '/crear_cita': // <<<--- ESTE ES EL NUEVO CASE
                  return MaterialPageRoute(
                    builder: (_) => const CreacionCitaScreen(),
                  );
                case '/detalles_cita_admin':
                  final citaId = settings.arguments as int; // ahora sí es int
                  return MaterialPageRoute(
                    builder: (_) => DetallesCitaPage(citaId: citaId),
                  );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

/// Pantalla temporal para pruebas de navegación
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Estás en $title'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
