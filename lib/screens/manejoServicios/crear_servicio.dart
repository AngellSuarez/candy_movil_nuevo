import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/servicios/servicios_service.dart';

class CrearServicioPage extends StatefulWidget {
  const CrearServicioPage({Key? key}) : super(key: key);

  @override
  State<CrearServicioPage> createState() => _CrearServicioPageState();
}

class _CrearServicioPageState extends State<CrearServicioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController();

  String _estado = "Activo"; // default según el modelo
  String _tipo = "Manicure"; // default según el modelo

  File? _imagen;
  final _service = ServiciosService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagen = File(picked.path));
    }
  }

  // En el archivo crear_servicio.dart
  Future<void> _crearServicio() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Convertir la duración de minutos a segundos
      int minutos = int.tryParse(_duracionCtrl.text.trim()) ?? 0;
      int segundos = minutos * 60;

      final data = {
        'nombre': _nombreCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'precio':
            double.tryParse(_precioCtrl.text.trim())?.toStringAsFixed(2) ??
            "0.00",
        'duracion': segundos, // <-- ¡Este es el cambio clave!
        'estado': _estado,
        'tipo': _tipo,
      };

      await _service.crearServicio(data, _imagen?.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Servicio creado exitosamente")),
      );
      Navigator.pop(context, true);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Servicio")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: _dec("Nombre"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingrese el nombre" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: _dec("Descripción"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingrese la descripción" : null,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioCtrl,
                decoration: _dec("Precio"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingrese el precio" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _duracionCtrl,
                decoration: _dec("Duración (min)"),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? "Ingrese la duración en minutos"
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: _dec("Estado"),
                items: const [
                  DropdownMenuItem(value: "Activo", child: Text("Activo")),
                  DropdownMenuItem(value: "Inactivo", child: Text("Inactivo")),
                ],
                onChanged: (v) => setState(() => _estado = v ?? "Activo"),
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
                onChanged: (v) => setState(() => _tipo = v ?? "Manicure"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Seleccionar Imagen"),
                  ),
                  const SizedBox(width: 12),
                  if (_imagen != null)
                    Text(
                      "Imagen seleccionada",
                      style: TextStyle(color: Colors.green[700]),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _crearServicio,
                icon: const Icon(Icons.save),
                label: const Text("Guardar"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
