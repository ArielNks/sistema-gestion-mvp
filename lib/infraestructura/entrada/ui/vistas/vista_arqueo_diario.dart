import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/consultar_arqueo_diario.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart';
import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';
import 'package:sistema_gestion/inyeccion_dependencias.dart';

class VistaArqueoDiario extends StatefulWidget {
  const VistaArqueoDiario({super.key});

  @override
  State<VistaArqueoDiario> createState() => _VistaArqueoDiarioState();
}

class _VistaArqueoDiarioState extends State<VistaArqueoDiario> {
  DateTime _fechaSeleccionada = DateTime.now();
  ResumenFinanciero? _reporte;
  List<Transaccion> _transacciones = [];
  bool _isCargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarArqueo();
  }

  Future<void> _cargarArqueo() async {
    setState(() {
      _isCargando = true;
      _error = null;
    });

    try {
      final casoUso = getIt<ConsultarArqueoDiario>();
      final reporte = await casoUso.ejecutar(_fechaSeleccionada);
      if (mounted) {
        setState(() {
          _reporte = reporte;
          _isCargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar arqueo: $e';
          _isCargando = false;
        });
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null && fecha != _fechaSeleccionada) {
      setState(() => _fechaSeleccionada = fecha);
      _cargarArqueo();
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _formatearFechaHora(DateTime fecha) {
    return '${_formatearFecha(fecha)} ${_formatearHora(fecha)}';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Arqueo Diario',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.calendar_today, size: 20),
                label: Text(_formatearFecha(_fechaSeleccionada), style: const TextStyle(fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (_isCargando)
            const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 3)))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 72, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _cargarArqueo,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reintentar', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            )
          else if (_reporte != null) ...[
            _buildResumenCards(_reporte!),
            const SizedBox(height: 24),
            Expanded(child: _buildListaTransacciones()),
          ] else
            const Expanded(
              child: Center(
                child: Text('No hay datos disponibles', style: TextStyle(fontSize: 17, color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumenCards(ResumenFinanciero r) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildResumenCard(
                    'Total Ingresos',
                    _formatearMonto(r.totalIngresos),
                    'Ef: ${_formatearMonto(r.ingresosEfectivo)} | Transf: ${_formatearMonto(r.ingresosTransferencia)}',
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildResumenCard(
                    'Total Egresos',
                    _formatearMonto(r.totalEgresos),
                    'Ef: ${_formatearMonto(r.egresosEfectivo)} | Transf: ${_formatearMonto(r.egresosTransferencia)}',
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
              ),
              const VerticalDivider(color: Colors.grey, thickness: 2, width: 40, indent: 8, endIndent: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildResumenCard(
                    'Saldo Efectivo',
                    _formatearMonto(r.totalEfectivo),
                    'Ing: ${_formatearMonto(r.ingresosEfectivo)} - Egr: ${_formatearMonto(r.egresosEfectivo)}',
                    Colors.blue,
                    Icons.money,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildResumenCard(
                    'Saldo Transferencia',
                    _formatearMonto(r.totalTransferencia),
                    'Ing: ${_formatearMonto(r.ingresosTransferencia)} - Egr: ${_formatearMonto(r.egresosTransferencia)}',
                    Colors.purple,
                    Icons.account_balance,
                  ),
                ),
              ),
              const VerticalDivider(color: Colors.grey, thickness: 2, width: 40, indent: 8, endIndent: 8),
              Expanded(
                child: _buildResumenCard(
                  'Balance Total',
                  _formatearMonto(r.balanceNeto),
                  'Ingresos: ${_formatearMonto(r.totalIngresos)} - Egresos: ${_formatearMonto(r.totalEgresos)}',
                  r.balanceNeto >= 0 ? Colors.green : Colors.red,
                  Icons.balance,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumenCard(
    String titulo,
    String valor,
    String detalle,
    Color color,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              valor,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 28,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              detalle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaTransacciones() {
    return FutureBuilder<List<Transaccion>>(
      future: getIt<RepositorioTransaccion>().obtenerTransaccionesPorFecha(_fechaSeleccionada),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 3));
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 72, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Error al cargar movimientos: ${snapshot.error}', style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _cargarArqueo,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reintentar', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        }
        _transacciones = snapshot.data ?? [];

        if (_transacciones.isEmpty) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(56),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 72,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sin movimientos registrados en esta fecha',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 17,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Movimientos del día (${_transacciones.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _transacciones.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final t = _transacciones[index];
                    final esIngreso = t.tipoMovimiento == TipoMovimiento.ingreso;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (esIngreso ? Colors.green : Colors.red).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                              color: esIngreso ? Colors.green : Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatearFechaHora(t.fechaHora),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.descripcion ?? 'Sin descripción',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: esIngreso ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
              ),
            ],
          ),
        );
      },
    );
  }
}