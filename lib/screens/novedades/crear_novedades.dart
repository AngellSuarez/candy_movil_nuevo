import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/novedades/novedades_manicurista_service.dart';

class CrearNovedadPage extends StatefulWidget {
  const CrearNovedadPage({super.key});

  @override
  State<CrearNovedadPage> createState() => _CrearNovedadPageState();
}

class _CrearNovedadPageState extends State<CrearNovedadPage> {
  final _formKey = GlobalKey<FormState>();
  final _fechaCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _salidaCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();

  final NovedadesApi _novedadesApi = NovedadesApi();
  final ManicuristasApi _manicuristasApi = ManicuristasApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> _manicuristas = [];
  Map<String, dynamic>? _manicuristaSel;
  bool _enviando = false;
  String? _rol;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final rol = await _storage.read(key: "rol");
    final userIdStr = await _storage.read(key: "user_id");

    if (!mounted) return;

    setState(() {
      _rol = rol;
    });

    if (rol?.toLowerCase() == "manicurista" && userIdStr != null) {
      try {
        final userId = int.parse(userIdStr);
        final manicuristas = await _manicuristasApi
            .obtenerManicuristasActivos();

        final manicuristaSel = manicuristas.firstWhere(
          (m) => m['usuario_id'] == userId,
          orElse: () => throw Exception('Manicurista no encontrado'),
        );

        setState(() {
          _manicuristas = manicuristas;
          _manicuristaSel = manicuristaSel;
        });
      } catch (e) {
        // Manejar el error, por ejemplo, mostrar un mensaje.
        print("Error al cargar datos del manicurista: $e");
      }
    } else {
      try {
        final manicuristas = await _manicuristasApi
            .obtenerManicuristasActivos();
        setState(() {
          _manicuristas = manicuristas;
        });
      } catch (e) {
        print("Error al cargar lista de manicuristas: $e");
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await _novedadesApi.crearNovedad({
        "manicurista_id": _manicuristaSel?['usuario_id'],
        "Fecha": _fechaCtrl.text,
        "HoraEntrada": _entradaCtrl.text,
        "HoraSalida": _salidaCtrl.text,
        "Motivo": _motivoCtrl.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Novedad creada con éxito")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esManicurista = _rol?.toLowerCase() == "manicurista";

    return Scaffold(
      appBar: AppBar(title: const Text("Crear Novedad")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              esManicurista
                  ? const SizedBox.shrink() // Oculta el widget si es manicurista
                  : DropdownButtonFormField<Map<String, dynamic>>(
                      value: _manicuristaSel,
                      decoration: const InputDecoration(
                        labelText: "Manicurista",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      items: _manicuristas.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text("${m['nombre']} ${m['apellido']}"),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _manicuristaSel = val),
                      validator: (val) =>
                          val == null ? "Selecciona un manicurista" : null,
                    ),
              const SizedBox(height: 16),
              // ⬇️ siguen los campos ya existentes
              TextFormField(
                controller: _fechaCtrl,
                decoration: const InputDecoration(
                  labelText: "Fecha",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (date != null) {
                    _fechaCtrl.text = date.toIso8601String().split("T").first;
                  }
                },
                validator: (v) => v!.isEmpty ? "Ingresa la fecha" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _entradaCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Hora de Entrada",
                  prefixIcon: Icon(Icons.login),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    final time =
                        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
                    _entradaCtrl.text = time;
                  }
                },
                validator: (v) =>
                    v!.isEmpty ? "Ingresa la hora de entrada" : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _salidaCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Hora de Salida",
                  prefixIcon: Icon(Icons.logout),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    final time =
                        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
                    _salidaCtrl.text = time;
                  }
                },
                validator: (v) =>
                    v!.isEmpty ? "Ingresa la hora de salida" : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _motivoCtrl,
                decoration: const InputDecoration(
                  labelText: "Motivo",
                  prefixIcon: Icon(Icons.note_alt),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _enviando ? null : _guardar,
                  icon: _enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text("Guardar Novedad"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
