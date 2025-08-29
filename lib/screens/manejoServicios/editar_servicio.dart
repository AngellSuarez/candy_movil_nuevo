import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/servicios/servicios_service.dart';

class EditarServicioPage extends StatefulWidget {
  final Map<String, dynamic> servicio;
  const EditarServicioPage({required this.servicio, super.key});

  @override
  State<EditarServicioPage> createState() => _EditarServicioPageState();
}

class _EditarServicioPageState extends State<EditarServicioPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ServiciosService();

  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _duracionCtrl; // Nuevo controlador
  String _estado = 'Activo';
  String _tipo = 'Manicure'; // Nueva variable para el tipo

  File? _nuevaImagen;

  // ... dentro del método initState()
  @override
  void initState() {
    super.initState();
    final s = widget.servicio;
    _nombreCtrl = TextEditingController(text: s['nombre'] ?? '');
    _descripcionCtrl = TextEditingController(text: s['descripcion'] ?? '');
    _precioCtrl = TextEditingController(text: s['precio']?.toString() ?? '');

    // Manejar el formato de duración
    int minutos = 0;
    final duracion = s['duracion'];
    if (duracion is String) {
      // Si la duración es un string (e.g., "01:30:00"), se parsea
      final parts = duracion.split(':');
      if (parts.length >= 2) {
        minutos = int.tryParse(parts[0])! * 60 + int.tryParse(parts[1])!;
      }
    } else if (duracion is int) {
      // Si la duración ya es un entero (segundos), se convierte a minutos
      minutos = duracion ~/ 60;
    }

    _duracionCtrl = TextEditingController(text: minutos.toString());
    _tipo = (s['tipo'] ?? 'Manicure');
    _estado = (s['estado'] ?? 'Activo');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _duracionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _nuevaImagen = File(picked.path));
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Conversión de duración (minutos → segundos)
      int minutos = int.tryParse(_duracionCtrl.text.trim()) ?? 0;
      int segundos = minutos * 60;

      await _service.editarServicio(widget.servicio['id'], {
        'nombre': _nombreCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'precio': _precioCtrl.text.trim(),
        'duracion': segundos,
        'estado': _estado,
        'tipo': _tipo,
      }, pathImagen: _nuevaImagen?.path);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    final imagenUrl =
        widget.servicio['url_imagen'] ?? widget.servicio['imagen'];

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Servicio"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: _dec("Nombre"),
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: _dec("Descripción"),
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioCtrl,
                keyboardType: TextInputType.number,
                decoration: _dec("Precio"),
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _duracionCtrl,
                decoration: _dec("Duración (min)"),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: _dec("Estado"),
                items: const [
                  DropdownMenuItem(value: "Activo", child: Text("Activo")),
                  DropdownMenuItem(value: "Inactivo", child: Text("Inactivo")),
                ],
                onChanged: (v) => setState(() => _estado = v ?? 'Activo'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: _dec("Tipo"),
                items: const [
                  DropdownMenuItem(value: "Manicure", child: Text("Manicure")),
                  DropdownMenuItem(value: "Pedicure", child: Text("Pedicure")),
                  DropdownMenuItem(value: "Retiros", child: Text("Retiros")),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'Manicure'),
              ),
              const SizedBox(height: 16),
              if (_nuevaImagen != null)
                Image.file(_nuevaImagen!, height: 150, fit: BoxFit.cover)
              else if (imagenUrl != null)
                Image.network(imagenUrl, height: 150, fit: BoxFit.cover),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Cambiar Imagen"),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
