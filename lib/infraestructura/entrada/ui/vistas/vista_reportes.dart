import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/consultar_reporte_periodo.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/exportar_reporte_pdf.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart';
import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/inyeccion_dependencias.dart';

class VistaReportes extends StatefulWidget {
  const VistaReportes({super.key});

  @override
  State<VistaReportes> createState() => _VistaReportesState();
}

class _VistaReportesState extends State<VistaReportes> {
  DateTimeRange _rangoFechas = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  ResumenFinanciero? _reporte;
  bool _isCargando = false;
  bool _isExportando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _consultarReporte();
  }

  Future<void> _seleccionarRangoFechas() async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _rangoFechas,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (rango != null && rango != _rangoFechas) {
      setState(() => _rangoFechas = rango);
      _consultarReporte();
    }
  }

  Future<void> _consultarReporte() async {
    setState(() {
      _isCargando = true;
      _error = null;
      _reporte = null;
    });

    try {
      final casoUso = getIt<ConsultarReportePeriodo>();
      final resultado = await casoUso.ejecutar(
        fechaInicio: _rangoFechas.start,
        fechaFin: _rangoFechas.end,
      );
      if (mounted) {
        setState(() {
          _reporte = resultado;
          _isCargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al consultar reporte: $e';
          _isCargando = false;
        });
      }
    }
  }

  Future<void> _exportarPdf() async {
    if (_reporte == null) return;

    setState(() => _isExportando = true);

    try {
      final casoUso = getIt<ExportarReportePdf>();
      await casoUso.ejecutar(_reporte!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte PDF generado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExportando = false);
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearFechaHora(DateTime fecha) {
    return '${_formatearFecha(fecha)} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
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
                'Reportes por Período',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _seleccionarRangoFechas,
                icon: const Icon(Icons.date_range),
                label: Text(
                  '${_formatearFecha(_rangoFechas.start)} - ${_formatearFecha(_rangoFechas.end)}',
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: _isCargando ? null : _consultarReporte,
                icon: _isCargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: const Text('Consultar Reporte'),
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
                      onPressed: _consultarReporte,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else if (_reporte == null)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Seleccione un rango de fechas y presione "Consultar Reporte"',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildResumenCards(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: _isExportando ? null : _exportarPdf,
                  icon: _isExportando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: const Text('Exportar a PDF / Imprimir'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildListaTransacciones()),
          ],
        ],
      ),
    );
  }

  Widget _buildResumenCards() {
    final r = _reporte!;

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
    final transacciones = _reporte!.transacciones;

    if (transacciones.isEmpty) {
      return Card(
        elevation: 2,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
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
                  'Sin movimientos registrados en este rango de fechas',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Movimientos del Período (${transacciones.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: transacciones.length,
              itemBuilder: (context, index) {
                final t = transacciones[index];
                final esIngreso = t.tipoMovimiento == TipoMovimiento.ingreso;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                    color: esIngreso ? Colors.green : Colors.red,
                  ),
                  title: Text(_formatearFechaHora(t.fechaHora)),
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
            _buildDetalleFila('Fecha y Hora', _formatearFechaHora(t.fechaHora)),
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