import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/servicios/servicios_service.dart';
import 'editar_servicio.dart';

class ServiciosAdminPage extends StatefulWidget {
  const ServiciosAdminPage({super.key});

  @override
  State<ServiciosAdminPage> createState() => _ServiciosAdminPageState();
}

class _ServiciosAdminPageState extends State<ServiciosAdminPage> {
  final ServiciosService _service = ServiciosService();
  late Future<List<Map<String, dynamic>>> _serviciosFuture;

  @override
  void initState() {
    super.initState();
    _serviciosFuture = _service.obtenerServicios();
  }

  Future<void> _refresh() async {
    setState(() {
      _serviciosFuture = _service.obtenerServicios();
    });
  }

  // Después de _refresh()
  Future<void> _eliminarServicio(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Eliminación"),
        content: const Text(
          "¿Estás seguro de que quieres eliminar este servicio?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.eliminarServicio(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Servicio eliminado correctamente")),
          );
        }
        _refresh(); // Recarga la lista para reflejar el cambio
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al eliminar el servicio: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Crear un formateador de moneda para Colombia (COP)
    final formatter = NumberFormat.currency(
      locale: 'es_CO', // Formato para español de Colombia
      symbol: '\$', // Símbolo de moneda
      decimalDigits: 0, // Sin decimales para montos enteros
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Servicios"), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _serviciosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay servicios disponibles"));
          }

          final servicios = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: servicios.length,
              itemBuilder: (context, index) {
                final servicio = servicios[index];
                final nombre = servicio['nombre'] ?? "Sin nombre";
                final precio = servicio['precio'] ?? 0;

                // Convertir el precio a un número si es un string
                final num precioNumerico;
                if (precio is String) {
                  precioNumerico = double.tryParse(precio) ?? 0;
                } else {
                  precioNumerico = precio;
                }

                final urlImagen = servicio['url_imagen'] ?? servicio['imagen'];
                final precioFormateado = formatter.format(
                  precioNumerico,
                ); // Se usa la variable corregida

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: urlImagen != null
                          ? Image.network(
                              urlImagen,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                    ),
                    title: Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          "$precioFormateado COP",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            servicio['estado'],
                            style: TextStyle(
                              color: servicio['estado'] == 'Activo'
                                  ? Colors.white
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: servicio['estado'] == 'Activo'
                              ? Colors.green[600]
                              : Colors.red[600],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditarServicioPage(servicio: servicio),
                              ),
                            ).then((actualizado) {
                              if (actualizado == true) _refresh();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarServicio(
                            servicio['id'],
                          ), // Llama a la nueva función
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/crear_servicio').then((created) {
              if (created == true) _refresh();
            }),
        icon: const Icon(Icons.add),
        label: const Text("Agregar Servicio"),
      ),
    );
  }
}
