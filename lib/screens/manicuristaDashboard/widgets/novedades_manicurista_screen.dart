import 'package:flutter/material.dart';
import '../../../services/novedades/novedades_service.dart';

class NovedadesManicuristaScreen extends StatefulWidget {
  const NovedadesManicuristaScreen({super.key});

  @override
  State<NovedadesManicuristaScreen> createState() =>
      _NovedadesManicuristaScreenState();
}

class _NovedadesManicuristaScreenState
    extends State<NovedadesManicuristaScreen> {
  final NovedadesService _api = NovedadesService();
  List<Map<String, dynamic>> _novedades = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarNovedades();
  }

  Future<void> _cargarNovedades() async {
    setState(() => _loading = true);
    try {
      final novedades = await _api.obtenerNovedades();
      if (mounted) setState(() => _novedades = novedades);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar novedades: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Novedades")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          "/crear_novedad",
        ).then((_) => _cargarNovedades()),
        icon: const Icon(Icons.add),
        label: const Text("Nueva Novedad"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarNovedades,
              child: _novedades.isEmpty
                  ? const Center(child: Text("No hay novedades"))
                  : ListView.builder(
                      itemCount: _novedades.length,
                      itemBuilder: (ctx, i) {
                        final n = _novedades[i];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.pink.shade300,
                              child: const Icon(
                                Icons.event_note,
                                color: Colors.white,
                              ),
                            ),
                            title: Text("Fecha: ${n['Fecha']}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Entrada: ${n['HoraEntrada']}"),
                                Text("Salida: ${n['HoraSalida']}"),
                                if ((n['Motivo'] ?? "").isNotEmpty)
                                  Text("Motivo: ${n['Motivo']}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
