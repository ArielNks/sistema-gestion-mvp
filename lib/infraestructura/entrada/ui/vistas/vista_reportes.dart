import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/consultar_reporte_periodo.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/exportar_reporte_pdf.dart';
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
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
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
            )
          else if (_reporte == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 64, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Seleccione un rango de fechas y presione "Consultar Reporte"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            _buildResumenCards(),
            const SizedBox(height: 24),
            _buildExportarButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildResumenCards() {
    final r = _reporte!;

    return Row(
      children: [
        Expanded(child: _buildResumenCard('Total Ingresos', _formatearMonto(r.totalIngresos), Colors.green, Icons.arrow_downward)),
        const SizedBox(width: 16),
        Expanded(child: _buildResumenCard('Total Egresos', _formatearMonto(r.totalEgresos), Colors.red, Icons.arrow_upward)),
        const SizedBox(width: 16),
        Expanded(child: _buildResumenCard('Balance Neto', _formatearMonto(r.balanceNeto), r.balanceNeto >= 0 ? Colors.green : Colors.red, Icons.balance)),
        const SizedBox(width: 16),
        Expanded(child: _buildResumenCard('Total Efectivo', _formatearMonto(r.totalEfectivo), Colors.blue, Icons.money)),
        const SizedBox(width: 16),
        Expanded(child: _buildResumenCard('Total Transferencia', _formatearMonto(r.totalTransferencia), Colors.purple, Icons.account_balance)),
      ],
    );
  }

  Widget _buildResumenCard(String titulo, String valor, Color color, IconData icon) {
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
            const SizedBox(height: 12),
            Text(
              valor,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportarButton() {
    return Row(
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
    );
  }
}