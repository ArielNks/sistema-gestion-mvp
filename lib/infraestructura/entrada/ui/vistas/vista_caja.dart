import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/registrar_egreso.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/registrar_ingreso.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart'
    as tipo_movimiento;
import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';
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
      final repo = getIt<RepositorioTransaccion>();
      final transacciones = await repo.obtenerTransaccionesPorFecha(DateTime.now());
      final lista = List<Transaccion>.from(transacciones);
      lista.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
      if (mounted) {
        setState(() {
          _ultimosMovimientos = lista.take(10).toList();
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro de Movimientos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingrese los datos del movimiento a registrar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _montoController,
                        focusNode: _montoFocus,
                        autofocus: true,
                        style: const TextStyle(fontSize: 19),
                        decoration: const InputDecoration(
                          labelText: 'Monto (\$)',
                          labelStyle: TextStyle(fontSize: 16),
                          prefixIcon: Icon(Icons.attach_money, size: 24),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          hintText: '0.00',
                          hintStyle: TextStyle(fontSize: 17, color: Colors.grey),
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
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _descripcionController,
                        focusNode: _descFocus,
                        style: const TextStyle(fontSize: 17),
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                          labelStyle: TextStyle(fontSize: 16),
                          prefixIcon: Icon(Icons.description, size: 24),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          hintText: 'Ej: Venta de productos, pago de servicios...',
                          hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<MedioPago>(
                        initialValue: _medioPagoSeleccionado,
                        style: const TextStyle(fontSize: 17, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Medio de Pago',
                          labelStyle: TextStyle(fontSize: 16),
                          prefixIcon: Icon(Icons.payment, size: 24),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                        items: MedioPago.values.map((medio) {
                          return DropdownMenuItem(
                            value: medio,
                            child: Text(
                              medio == MedioPago.efectivo
                                  ? 'Efectivo'
                                  : 'Transferencia',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _medioPagoSeleccionado = value);
                          }
                        },
                      ),
                      const SizedBox(height: 30),
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
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_downward, size: 22),
                              label: const Text('Registrar Ingreso',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_upward, size: 22),
                              label: const Text('Registrar Egreso',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
          const SizedBox(width: 28),
          Expanded(
            flex: 6,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Últimos 10 Movimientos',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 18),
                    if (_ultimosMovimientos.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                              const SizedBox(height: 16),
                              Text(
                                'No hay movimientos registrados hoy',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 17,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: _ultimosMovimientos.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) {
                          final t = _ultimosMovimientos[index];
                          final esIngreso =
                              t.tipoMovimiento == tipo_movimiento.TipoMovimiento.ingreso;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: (esIngreso ? Colors.green : Colors.red).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: esIngreso ? Colors.green : Colors.red,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatearHora(t.fechaHora),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        t.descripcion ?? 'Sin descripción',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatearMonto(t.monto),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: esIngreso ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (t.medioPago == MedioPago.efectivo ? Colors.blue : Colors.purple).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        t.medioPago == MedioPago.efectivo ? 'Efectivo' : 'Transferencia',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: t.medioPago == MedioPago.efectivo ? Colors.blue : Colors.purple,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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