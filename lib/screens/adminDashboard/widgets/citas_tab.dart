import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../core/app_exports.dart';

import '../../../services/citas/citas_service.dart';
import './metricas_dashboard.dart';

class CitasTab extends StatefulWidget {
  final int totalCitasHoy;
  final int citasPendientesHoy;
  final VoidCallback onNuevaCita;

  const CitasTab({
    super.key,
    required this.totalCitasHoy,
    required this.citasPendientesHoy,
    required this.onNuevaCita,
  });

  @override
  State<CitasTab> createState() => _CitasTabState();
}

class _CitasTabState extends State<CitasTab> {
  final CitasService _citasService = CitasService();
  final TextEditingController _clienteCtrl = TextEditingController();
  final TextEditingController _manicuristaCtrl = TextEditingController();

  List<Map<String, dynamic>> _citas = [];
  List<Map<String, dynamic>> _filtradas = [];
  DateTime? _fecha;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final data = await _citasService.obtenerCitas();
      setState(() {
        _citas = data;
        _filtradas = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar citas: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _aplicarFiltros() {
    final cli = _clienteCtrl.text.trim().toLowerCase();
    final mani = _manicuristaCtrl.text.trim().toLowerCase();
    setState(() {
      _filtradas = _citas.where((c) {
        final cliente = (c['cliente_nombre'] ?? '').toString().toLowerCase();
        final manicurista = (c['manicurista_nombre'] ?? '')
            .toString()
            .toLowerCase();
        final coincideCli = cliente.contains(cli);
        final coincideMani = manicurista.contains(mani);
        final coincideFecha =
            _fecha == null ||
            c['Fecha'] == DateFormat('yyyy-MM-dd').format(_fecha!);
        return coincideCli && coincideMani && coincideFecha;
      }).toList();
    });
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (f != null) {
      setState(() => _fecha = f);
      _aplicarFiltros();
    }
  }

  Future<void> _cancelarCita(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar cancelación'),
        content: const Text('¿Deseas cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
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
            content: Text('Cita cancelada'),
            backgroundColor: Colors.green,
          ),
        );
        _cargar();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  InputDecoration _inputDeco(String label) {
    final theme = AppTheme.lightTheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.colorScheme.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return RefreshIndicator(
      onRefresh: _cargar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del día
            Row(
              children: [
                Expanded(
                  child: DashboardMetricsCard(
                    title: 'Citas hoy',
                    value: '${widget.totalCitasHoy}',
                    subtitle: 'Programadas',
                    iconName: 'event',
                  ),
                ),
                Expanded(
                  child: DashboardMetricsCard(
                    title: 'Pendientes',
                    value: '${widget.citasPendientesHoy}',
                    subtitle: 'Hoy',
                    iconName: 'schedule',
                    backgroundColor: theme.colorScheme.secondary.withValues(
                      alpha: 0.1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Filtros
            Text(
              'Filtrar Citas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clienteCtrl,
                    decoration: _inputDeco('Cliente'),
                    onChanged: (_) => _aplicarFiltros(),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: TextField(
                    controller: _manicuristaCtrl,
                    decoration: _inputDeco('Manicurista'),
                    onChanged: (_) => _aplicarFiltros(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFecha,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _fecha == null
                        ? 'Seleccionar fecha'
                        : DateFormat('yyyy-MM-dd').format(_fecha!),
                  ),
                ),
                SizedBox(width: 2.w),
                if (_fecha != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _fecha = null);
                      _aplicarFiltros();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: widget.onNuevaCita,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Nueva Cita'),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Lista
            if (_cargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_filtradas.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'No hay citas que coincidan',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filtradas.length,
                separatorBuilder: (_, __) => SizedBox(height: 1.h),
                itemBuilder: (context, i) {
                  final c = _filtradas[i];

                  // Estado y colores
                  final estado = (c['estado_nombre'] ?? '')
                      .toString()
                      .toLowerCase();
                  final estadoColor = estado == 'Cancelada'
                      ? theme.colorScheme.error
                      : (estado == 'Pendiente'
                            ? Colors.orange
                            : theme.colorScheme.primary);

                  // >>> NUEVO: lógica de habilitación del botón cancelar

                  final canCancelar = estado == 'Pendiente';
                  // <<<

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
                            iconName: 'event',
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cliente: ${c['cliente_nombre']}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Manicurista: ${c['manicurista_nombre']}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  'Fecha: ${c['Fecha']}  •  Hora: ${c['Hora']}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  'Estado: ${c['estado_nombre']}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: estadoColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${c['Total']}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Ver detalles',
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/detalles_cita_admin',
                                        arguments: c['id'],
                                      );
                                    },
                                  ),

                                  // >>> CAMBIO: botón siempre visible pero habilitado SOLO si canCancelar
                                  IconButton(
                                    tooltip: 'Cancelar cita',
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _cancelarCita(c['id'] as int),
                                  ),

                                  // <<<
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
