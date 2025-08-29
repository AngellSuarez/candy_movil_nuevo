import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login/login_screen.dart';
import 'theme/app_theme.dart';

import 'screens/adminDashboard/admin_dashboard.dart';
import 'screens/adminDashboard/novedades_admin.dart';
import 'screens/novedades/crear_novedades.dart';

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
            routes: {
              '/': (context) => const LoginScreen(),
              '/news-feed': (context) =>
                  const PlaceholderScreen(title: 'News Feed'),
              '/admin-dashboard': (context) => const AdminDashboard(),
              '/cliente-dashboard': (context) =>
                  const PlaceholderScreen(title: 'Cliente Dashboard'),
              '/manicurista-dashboard': (context) =>
                  const PlaceholderScreen(title: 'Manicurista Dashboard'),
              '/novedades_admin': (_) => const NovedadesAdminPage(),
              '/crear_novedad': (_) => const CrearNovedadPage(),
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
