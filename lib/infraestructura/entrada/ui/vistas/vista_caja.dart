import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/consultar_arqueo_diario.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/registrar_egreso.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/registrar_ingreso.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart'
    as tipo_movimiento;
//import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/inyeccion_dependencias.dart';

class VistaCaja extends StatefulWidget {
  const VistaCaja({super.key});

  @override
  State<VistaCaja> createState() => _VistaCajaState();
}

class _VistaCajaState extends State<VistaCaja> {
  final _formKey = GlobalKey<FormState>();

  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

  final _montoFocus = FocusNode();
  final _descFocus = FocusNode();

  MedioPago _medioPagoSeleccionado = MedioPago.efectivo;
  bool _isGuardando = false;
  List<Transaccion> _ultimosMovimientos = [];

  @override
  void initState() {
    super.initState();
    _cargarUltimosMovimientos();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _montoFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  Future<void> _cargarUltimosMovimientos() async {
    try {
      final casoUso = getIt<ConsultarArqueoDiario>();
      final movimientos = await casoUso.ejecutar(DateTime.now());
      movimientos.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
      if (mounted) {
        setState(() {
          _ultimosMovimientos = movimientos.take(10).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar movimientos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _registrarMovimiento(tipo_movimiento.TipoMovimiento tipo) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGuardando = true);

    try {
      final transaccion = Transaccion(
        monto: double.parse(_montoController.text),
        medioPago: _medioPagoSeleccionado,
        tipoMovimiento: tipo,
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        fechaHora: DateTime.now(),
      );

      if (tipo == tipo_movimiento.TipoMovimiento.ingreso) {
        await getIt<RegistrarIngreso>().ejecutar(transaccion);
      } else {
        await getIt<RegistrarEgreso>().ejecutar(transaccion);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tipo == tipo_movimiento.TipoMovimiento.ingreso
                  ? 'Ingreso registrado correctamente'
                  : 'Egreso registrado correctamente',
            ),
            backgroundColor: tipo == tipo_movimiento.TipoMovimiento.ingreso
                ? Colors.green
                : Colors.red,
          ),
        );
        _limpiarFormulario();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGuardando = false);
    }
  }

  void _limpiarFormulario() {
    _montoController.clear();
    _descripcionController.clear();
    setState(() => _medioPagoSeleccionado = MedioPago.efectivo);
    _formKey.currentState?.reset();
    _cargarUltimosMovimientos();
    _montoFocus.requestFocus();
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _formatearMonto(double monto) {
    return '\$${monto.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro de Movimientos',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingrese los datos del movimiento a registrar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _montoController,
                        focusNode: _montoFocus,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Monto (\$)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                          hintText: '0.00',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descFocus);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el monto';
                          }
                          final n = double.tryParse(value);
                          if (n == null || n <= 0) {
                            return 'Ingrese un valor mayor a 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        focusNode: _descFocus,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Venta de productos, pago de servicios...',
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<MedioPago>(
                        initialValue: _medioPagoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Medio de Pago',
                          prefixIcon: Icon(Icons.payment),
                          border: OutlineInputBorder(),
                        ),
                        items: MedioPago.values.map((medio) {
                          return DropdownMenuItem(
                            value: medio,
                            child: Text(
                              medio == MedioPago.efectivo
                                  ? 'Efectivo'
                                  : 'Transferencia',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _medioPagoSeleccionado = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isGuardando
                                  ? null
                                  : () =>
                                      _registrarMovimiento(tipo_movimiento.TipoMovimiento.ingreso),
                              icon: _isGuardando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_downward),
                              label: const Text('Registrar Ingreso'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isGuardando
                                  ? null
                                  : () =>
                                      _registrarMovimiento(tipo_movimiento.TipoMovimiento.egreso),
                              icon: _isGuardando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_upward),
                              label: const Text('Registrar Egreso'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 6,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Últimos 10 Movimientos',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (_ultimosMovimientos.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 48, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No hay movimientos registrados hoy',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _ultimosMovimientos.length,
                        itemBuilder: (context, index) {
                          final t = _ultimosMovimientos[index];
                          final esIngreso =
                              t.tipoMovimiento == tipo_movimiento.TipoMovimiento.ingreso;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                              color: esIngreso ? Colors.green : Colors.red,
                            ),
                            title: Text(_formatearHora(t.fechaHora)),
                            subtitle: Text(
                              t.descripcion ?? 'Sin descripción',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              _formatearMonto(t.monto),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: esIngreso ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}