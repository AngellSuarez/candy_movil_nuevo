import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/citas/citas_service.dart';
import '../../services/servicios/servicios_service.dart';
import '../../services/manicuristas/manicurista_service.dart';
import '../../services/clientes/clientes_service.dart';

class CreacionCitaScreen extends StatefulWidget {
  const CreacionCitaScreen({super.key});

  @override
  State<CreacionCitaScreen> createState() => _CrearCitaPageState();
}

class _CrearCitaPageState extends State<CreacionCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  int? clienteId;
  int? manicuristaId;
  String? fechaSeleccionada;
  String? horaSeleccionada;
  List<String> horariosDisponibles = [];
  List<Map<String, dynamic>> servicios = [];
  List<int> serviciosSeleccionados = [];

  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> manicuristas = [];

  bool loading = false;
  final TextEditingController _descripcionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarServicios();
    _cargarClientes();
    _cargarManicuristas();
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    try {
      final data = await ClientesService().obtenerClientesActivos();
      setState(() {
        clientes = data;
        if (clienteId != null &&
            !clientes.any((c) => c['usuario_id'] == clienteId)) {
          clienteId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar clientes: $e")));
    }
  }

  Future<void> _cargarManicuristas() async {
    try {
      final data = await ManicuristaService().obtenerManicuristasActivos();
      setState(() {
        manicuristas = data;
        if (manicuristaId != null &&
            !manicuristas.any((m) => m['usuario_id'] == manicuristaId)) {
          manicuristaId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar manicuristas: $e")),
      );
    }
  }

  Future<void> _cargarServicios() async {
    try {
      final data = await ServiciosService().obtenerServicios();
      setState(() => servicios = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar servicios: $e")));
    }
  }

  Future<void> _cargarHorariosDisponibles() async {
    if (manicuristaId != null && fechaSeleccionada != null) {
      try {
        final data = await CitasService().getHorasDisponibles(
          manicuristaId: manicuristaId!,
          fecha: fechaSeleccionada!,
        );
        setState(() {
          horariosDisponibles = data;
          if (horaSeleccionada != null &&
              !horariosDisponibles.contains(horaSeleccionada)) {
            horaSeleccionada = null;
          }
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          horariosDisponibles = [];
          horaSeleccionada = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al cargar horarios: $e")));
      }
    }
  }

  Future<void> _selectFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        fechaSeleccionada = DateFormat('yyyy-MM-dd').format(picked);
      });
      _cargarHorariosDisponibles();
    }
  }

  Future<void> _guardarCita() async {
    print('Servicios seleccionados: $serviciosSeleccionados');

    if (_formKey.currentState!.validate() &&
        serviciosSeleccionados.isNotEmpty &&
        horaSeleccionada != null) {
      setState(() => loading = true);

      final String horaConSegundos = horaSeleccionada! + ':00.000Z';

      final citaData = {
        'cliente_id': clienteId!,
        'manicurista_id': manicuristaId!,
        'estado_id': 2,
        'Fecha': fechaSeleccionada!,
        'Hora': horaConSegundos,
        'Descripcion': _descripcionCtrl.text,
      };

      try {
        print('Payload de la cita: $citaData');
        final Map<String, dynamic> nuevaCita = await CitasService().crearCita(
          citaData,
        );
        print('Respuesta de la cita creada: $nuevaCita');
        // AQUI ESTABA EL ERROR: el id está en el campo 'data'
        final int nuevaCitaId = nuevaCita['data']['id'];

        // Preparar los datos para la llamada batch de servicios
        final List<Map<String, dynamic>> serviciosParaEnviar =
            serviciosSeleccionados
                .map((id) => {'cita_id': nuevaCitaId, 'servicio_id': id})
                .toList();

        print('Payload de servicios: $serviciosParaEnviar');
        // Enviar los servicios en una llamada separada
        await CitasService().agregarServicioCitaBatch(serviciosParaEnviar);

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Cita creada con éxito")));
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al crear cita: $e")));
      } finally {
        if (!mounted) return;
        setState(() => loading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecciona al menos un servicio."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Nueva Cita")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Cliente",
                        prefixIcon: Icon(Icons.person),
                      ),
                      value: clienteId,
                      items: clientes.map((cliente) {
                        return DropdownMenuItem<int>(
                          value: cliente['usuario_id'],
                          child: Text(cliente['nombre']),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => clienteId = value),
                      validator: (value) =>
                          value == null ? "Selecciona un cliente" : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Manicurista",
                        prefixIcon: Icon(Icons.brush),
                      ),
                      value: manicuristaId,
                      items: manicuristas.map((manicurista) {
                        return DropdownMenuItem<int>(
                          value: manicurista['usuario_id'],
                          child: Text(manicurista['nombre']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => manicuristaId = value);
                        _cargarHorariosDisponibles();
                      },
                      validator: (value) =>
                          value == null ? "Selecciona una manicurista" : null,
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => _selectFecha(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: fechaSeleccionada ?? '',
                          ),
                          decoration: const InputDecoration(
                            labelText: "Fecha",
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "Selecciona una fecha"
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Hora",
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      value: horaSeleccionada,
                      items: horariosDisponibles.map((hora) {
                        return DropdownMenuItem<String>(
                          value: hora,
                          child: Text(hora),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => horaSeleccionada = value),
                      validator: (value) =>
                          value == null ? "Selecciona una hora" : null,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _descripcionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción de la cita',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    Card(
                      elevation: 2,
                      child: Column(
                        children: [
                          const ListTile(
                            leading: Icon(Icons.design_services),
                            title: Text("Seleccionar Servicios"),
                          ),
                          ...servicios.map(
                            (srv) => CheckboxListTile(
                              title: Text(srv['nombre'] ?? 'Sin nombre'),
                              subtitle: Text(
                                "\$${(double.tryParse(srv['precio']?.toString() ?? '0') ?? 0).toStringAsFixed(0)}",
                              ),
                              value: serviciosSeleccionados.contains(srv['id']),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    serviciosSeleccionados.add(srv['id']);
                                  } else {
                                    serviciosSeleccionados.remove(srv['id']);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Crear Cita"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _guardarCita,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
