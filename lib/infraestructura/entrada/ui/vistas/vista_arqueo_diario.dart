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
                    ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.calendar_today),
                label: Text(_formatearFecha(_fechaSeleccionada)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isCargando)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _cargarArqueo,
                      child: const Text('Reintentar'),
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
                child: Text('No hay datos disponibles'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumenCards(ResumenFinanciero r) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 280,
          child: _buildResumenCard(
            'Total Ingresos',
            _formatearMonto(r.totalIngresos),
            'Ef: ${_formatearMonto(r.ingresosEfectivo)} | Transf: ${_formatearMonto(r.ingresosTransferencia)}',
            Colors.green,
            Icons.arrow_downward,
          ),
        ),
        SizedBox(
          width: 280,
          child: _buildResumenCard(
            'Total Egresos',
            _formatearMonto(r.totalEgresos),
            'Ef: ${_formatearMonto(r.egresosEfectivo)} | Transf: ${_formatearMonto(r.egresosTransferencia)}',
            Colors.red,
            Icons.arrow_upward,
          ),
        ),
        SizedBox(
          width: 280,
          child: _buildResumenCard(
            'Saldo Efectivo',
            _formatearMonto(r.totalEfectivo),
            'Ing: ${_formatearMonto(r.ingresosEfectivo)} - Egr: ${_formatearMonto(r.egresosEfectivo)}',
            Colors.blue,
            Icons.money,
          ),
        ),
        SizedBox(
          width: 280,
          child: _buildResumenCard(
            'Saldo Transferencia',
            _formatearMonto(r.totalTransferencia),
            'Ing: ${_formatearMonto(r.ingresosTransferencia)} - Egr: ${_formatearMonto(r.egresosTransferencia)}',
            Colors.purple,
            Icons.account_balance,
          ),
        ),
        SizedBox(
          width: 280,
          child: _buildResumenCard(
            'Balance Total',
            _formatearMonto(r.balanceNeto),
            'Ingresos: ${_formatearMonto(r.totalIngresos)} - Egresos: ${_formatearMonto(r.totalEgresos)}',
            r.balanceNeto >= 0 ? Colors.green : Colors.red,
            Icons.balance,
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              detalle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaTransacciones() {
    // Obtener transacciones del repositorio para mostrar la lista detallada
    return FutureBuilder<List<Transaccion>>(
      future: getIt<RepositorioTransaccion>().obtenerTransaccionesPorFecha(_fechaSeleccionada),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Error al cargar movimientos: ${snapshot.error}'),
                const SizedBox(height: 16),
                FilledButton(onPressed: _cargarArqueo, child: const Text('Reintentar')),
              ],
            ),
          );
        }
        _transacciones = snapshot.data ?? [];

        if (_transacciones.isEmpty) {
          return Card(
            elevation: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay movimientos registrados en esta fecha',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Movimientos del día',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _transacciones.length,
                  itemBuilder: (context, index) {
                    final t = _transacciones[index];
                    final esIngreso = t.tipoMovimiento == TipoMovimiento.ingreso;
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
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatearMonto(t.monto),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: esIngreso ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            t.medioPago == MedioPago.efectivo ? 'Efectivo' : 'Transferencia',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      onTap: () => _mostrarDetalle(t),
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

  void _mostrarDetalle(Transaccion t) {
    final esIngreso = t.tipoMovimiento == TipoMovimiento.ingreso;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esIngreso ? 'Detalle Ingreso' : 'Detalle Egreso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleFila('Monto', _formatearMonto(t.monto)),
            _buildDetalleFila('Medio de Pago', t.medioPago == MedioPago.efectivo ? 'Efectivo' : 'Transferencia'),
            _buildDetalleFila('Fecha y Hora', '${_formatearFecha(t.fechaHora)} ${_formatearHora(t.fechaHora)}'),
            if (t.descripcion != null) _buildDetalleFila('Descripción', t.descripcion!),
            if (t.id != null) _buildDetalleFila('ID', t.id.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$etiqueta:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}