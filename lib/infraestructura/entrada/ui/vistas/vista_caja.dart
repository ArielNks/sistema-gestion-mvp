import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/registrar_egreso.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/registrar_ingreso.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart';
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

  MedioPago _medioPagoSeleccionado = MedioPago.efectivo;
  bool _isGuardando = false;

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _registrarMovimiento(TipoMovimiento tipo) async {
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

      if (tipo == TipoMovimiento.ingreso) {
        await getIt<RegistrarIngreso>().ejecutar(transaccion);
      } else {
        await getIt<RegistrarEgreso>().ejecutar(transaccion);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tipo == TipoMovimiento.ingreso
                  ? 'Ingreso registrado correctamente'
                  : 'Egreso registrado correctamente',
            ),
            backgroundColor: tipo == TipoMovimiento.ingreso
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      decoration: const InputDecoration(
                        labelText: 'Monto (\$)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        hintText: '0.00',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: Venta de productos, pago de servicios...',
                      ),
                      maxLines: 2,
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
                                : () => _registrarMovimiento(TipoMovimiento.ingreso),
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
                                : () => _registrarMovimiento(TipoMovimiento.egreso),
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
      ),
    );
  }
}