import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/consultar_reporte_periodo.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/exportar_reporte_pdf.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart';
import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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
                      fontSize: 28,
                    ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _seleccionarRangoFechas,
                icon: const Icon(Icons.date_range, size: 20),
                label: Text(
                  '${_formatearFecha(_rangoFechas.start)} - ${_formatearFecha(_rangoFechas.end)}',
                  style: const TextStyle(fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: _isCargando ? null : _consultarReporte,
                icon: _isCargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.search, size: 20),
                label: const Text('Consultar Reporte', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: _isExportando || _reporte == null ? null : _exportarPdf,
                icon: _isExportando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf, size: 20),
                label: const Text('Exportar a PDF / Imprimir',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      onPressed: _consultarReporte,
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
          else if (_reporte == null)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics, size: 72, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Seleccione un rango de fechas y presione "Consultar Reporte"',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildResumenCards(),
            const SizedBox(height: 28),
            Expanded(child: _buildListaTransacciones()),
          ],
        ],
      ),
    );
  }

  Widget _buildResumenCards() {
    final r = _reporte!;

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
    final transacciones = _reporte!.transacciones;

    if (transacciones.isEmpty) {
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
                  'Sin movimientos registrados en este rango de fechas',
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
              'Movimientos del Período (${transacciones.length})',
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
              itemCount: transacciones.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final t = transacciones[index];
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
  }
}