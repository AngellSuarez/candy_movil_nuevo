import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../services/citas/citas_service.dart';
import '../../../core/app_exports.dart';

class CitasClienteScreen extends StatefulWidget {
  const CitasClienteScreen({super.key});

  @override
  State<CitasClienteScreen> createState() => _CitasClienteScreenState();
}

class _CitasClienteScreenState extends State<CitasClienteScreen> {
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
      final userIdStr = await _storage.read(key: "user_id");
      if (userIdStr == null) throw Exception("Usuario no encontrado");

      final userId = int.parse(userIdStr);
      final citas = await _citasService.obtenerCitasPorCliente(userId);

      setState(() => _citas = citas);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar citas: $e")));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cancelarCita(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar cancelación"),
        content: const Text("¿Deseas cancelar esta cita?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sí"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _citasService.eliminarCita(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cita cancelada"),
            backgroundColor: Colors.green,
          ),
        );
        _cargarCitas();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al cancelar: $e")));
      }
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
                        "No tienes citas registradas",
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(4.w),
                      itemCount: _citas.length,
                      separatorBuilder: (_, __) => SizedBox(height: 1.h),
                      itemBuilder: (context, i) {
                        final c = _citas[i];
                        final estado = (c['estado_nombre'] ?? "")
                            .toString()
                            .toLowerCase();

                        final estadoColor = estado == "cancelada"
                            ? theme.colorScheme.error
                            : (estado == "pendiente"
                                  ? Colors.orange
                                  : theme.colorScheme.primary);

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomIconWidget(
                                  iconName: "event",
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Manicurista: ${c['manicurista_nombre']}",
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        "Fecha: ${c['Fecha']}  •  Hora: ${c['Hora']}",
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        "Estado: ${c['estado_nombre']}",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: estadoColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: "Ver detalles",
                                      icon: const Icon(
                                        Icons.info_outline,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          "/detalles_cita_admin",
                                          arguments: c['id'],
                                        );
                                      },
                                    ),
                                    if (estado == "pendiente")
                                      IconButton(
                                        tooltip: "Cancelar cita",
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _cancelarCita(c['id'] as int),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, "/crear_cita"),
        icon: const Icon(Icons.add),
        label: const Text("Nueva Cita"),
      ),
    );
  }
}
