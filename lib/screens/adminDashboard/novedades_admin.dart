import 'package:flutter/material.dart';
import '../../services/novedades/novedades_manicurista_service.dart';

class NovedadesAdminPage extends StatefulWidget {
  const NovedadesAdminPage({super.key});

  @override
  _NovedadesAdminPageState createState() => _NovedadesAdminPageState();
}

class _NovedadesAdminPageState extends State<NovedadesAdminPage> {
  final NovedadesApi _api = NovedadesApi();
  List<Map<String, dynamic>> _novedades = [];
  bool _loading = true;
  String _searchText = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _cargarNovedades();
  }

  Future<void> _cargarNovedades() async {
    setState(() => _loading = true);
    try {
      final novedades = await _api.obtenerNovedades();
      setState(() => _novedades = novedades);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar novedades: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filtrar(String value) {
    setState(() => _searchText = value.toLowerCase());
  }

  void _seleccionarFecha() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  List<Map<String, dynamic>> get _filtradas {
    return _novedades.where((n) {
      final nombre = (n['manicurista'] ?? '').toString().toLowerCase();
      final fecha = DateTime.tryParse(n['Fecha'] ?? '');
      final matchNombre = nombre.contains(_searchText);
      final matchFecha =
          _selectedDate == null ||
          (fecha != null && fecha.isAtSameMomentAs(_selectedDate!));
      return matchNombre && matchFecha;
    }).toList();
  }

  Future<void> _eliminarNovedad(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar novedad"),
        content: const Text("¿Seguro que quieres eliminar esta novedad?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _api.eliminarNovedad(id);
      _cargarNovedades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novedades"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _seleccionarFecha,
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _selectedDate = null),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/crear_novedad',
        ).then((_) => _cargarNovedades()),
        icon: const Icon(Icons.add),
        label: const Text("Nueva"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar por manicurista...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filtrar,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtradas.isEmpty
                ? const Center(child: Text("No hay novedades registradas"))
                : RefreshIndicator(
                    onRefresh: _cargarNovedades,
                    child: ListView.builder(
                      itemCount: _filtradas.length,
                      itemBuilder: (ctx, i) {
                        final novedad = _filtradas[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              novedad['manicurista_nombre'] ?? "Sin nombre",
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Fecha: ${novedad['Fecha']}"),
                                Text(
                                  "Entrada: ${novedad['HoraEntrada']} - Salida: ${novedad['HoraSalida']}",
                                ),
                                if (novedad['Motivo'] != null &&
                                    novedad['Motivo'].isNotEmpty)
                                  Text("Motivo: ${novedad['Motivo']}"),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarNovedad(novedad['id']),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
