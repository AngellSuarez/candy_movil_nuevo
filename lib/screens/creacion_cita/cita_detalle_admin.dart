import 'package:flutter/material.dart';

import '../../services/citas/citas_service.dart';
import '../../services/citas/estados_citas_services.dart';

class DetallesCitaPage extends StatefulWidget {
  final int citaId;

  const DetallesCitaPage({Key? key, required this.citaId}) : super(key: key);

  @override
  State<DetallesCitaPage> createState() => _DetallesCitaPageState();
}

class _DetallesCitaPageState extends State<DetallesCitaPage> {
  Map<String, dynamic>? cita;
  List<Map<String, dynamic>> _servicios =
      []; // Nueva variable de estado para los servicios
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCita();
  }

  Future<void> _loadCita() async {
    try {
      final data = await CitasService().obtenerDetallesCita(widget.citaId);
      final serviciosData = await CitasService().obtenerServiciosDeCita(
        widget.citaId,
      );
      if (!mounted) return;
      setState(() {
        cita = data;
        _servicios = serviciosData; // Almacenamos los servicios obtenidos
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar cita: $e")));
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    try {
      await EstadosCitasServices().actualizarEstadoCita(
        widget.citaId,
        nuevoEstado,
      );
      _loadCita();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Estado de la cita actualizado a '$nuevoEstado'"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cambiar estado: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detalle de Cita")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (cita == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detalle de Cita")),
        body: const Center(
          child: Text("No se pudo cargar la información de la cita."),
        ),
      );
    }

    // Datos de la cita
    final String fecha = cita!['Fecha'] ?? 'N/A';
    final String hora = cita!['Hora'] ?? 'N/A';
    final String cliente = cita!['cliente_nombre'] ?? 'N/A';
    final String manicurista = cita!['manicurista_nombre'] ?? 'N/A';
    final String estado = cita!['estado_nombre'] ?? 'N/A';
    final String descripcion = cita!['Descripcion'] ?? 'Sin descripción';
    final double total = double.tryParse(cita!['Total'].toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Cita")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard("Cliente", cliente, Icons.person),
            _infoCard("Manicurista", manicurista, Icons.brush),
            _infoCard("Fecha", fecha, Icons.calendar_today),
            _infoCard("Hora", hora, Icons.access_time),
            _infoCard(
              "Estado",
              estado,
              Icons.info,
              color: _getEstadoColor(estado),
            ),
            _infoCard("Descripción", descripcion, Icons.notes),
            _infoCard(
              "Total",
              "\$${total.toStringAsFixed(0)}",
              Icons.attach_money,
            ),
            const SizedBox(height: 16),
            const Text(
              "Servicios de la cita:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Iterar y mostrar los servicios
            if (_servicios
                .isNotEmpty) // Ahora usamos la nueva variable _servicios
              ..._servicios.map(
                (srv) => ListTile(
                  title: Text(srv['servicio_nombre'] ?? 'Sin nombre'),
                  subtitle: Text("\$${srv['subtotal'] ?? '0'}"),
                ),
              ),
            if (_servicios.isEmpty)
              const ListTile(
                title: Text("No hay servicios asociados a esta cita."),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Finalizar"),
                  onPressed: () => _cambiarEstado("finalizada"),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancelar"),
                  onPressed: () => _cambiarEstado("cancelada"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blue),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case "activo":
        return Colors.green.shade300;
      case "inactivo":
        return Colors.grey.shade400;
      case "cancelada":
        return Colors.red.shade300;
      case "reprogramada":
        return Colors.orange.shade300;
      case "finalizada":
        return Colors.blue.shade300;
      default:
        return Colors.grey;
    }
  }
}
