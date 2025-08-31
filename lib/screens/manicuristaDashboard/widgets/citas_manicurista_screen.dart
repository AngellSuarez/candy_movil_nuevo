import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sizer/sizer.dart';

import '../../../services/citas/citas_service.dart';
import '../../../core/app_exports.dart';

class CitasManicuristaScreen extends StatefulWidget {
  const CitasManicuristaScreen({super.key});

  @override
  State<CitasManicuristaScreen> createState() => _CitasManicuristaScreenState();
}

class _CitasManicuristaScreenState extends State<CitasManicuristaScreen> {
  final CitasService _citasService = CitasService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> _citas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() => _cargando = true);
    try {
      final manicuristaIdStr = await _storage.read(key: "user_id");
      if (manicuristaIdStr == null) throw Exception("Usuario no encontrado");

      final manicuristaId = int.parse(manicuristaIdStr);
      final citas = await _citasService.obtenerCitasManicurista(manicuristaId);

      if (mounted) setState(() => _citas = citas);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar citas: $e")));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Citas")),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarCitas,
              child: _citas.isEmpty
                  ? Center(
                      child: Text(
                        "No tienes citas asignadas",
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(4.w),
                      itemCount: _citas.length,
                      separatorBuilder: (_, __) => SizedBox(height: 1.h),
                      itemBuilder: (context, i) {
                        final c = _citas[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text("Cliente: ${c['cliente_nombre']}"),
                            subtitle: Text(
                              "Fecha: ${c['Fecha']} • Hora: ${c['Hora']}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/detalles_cita_admin",
                                  arguments: c['id'],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
