import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/entidades/excepciones/excepciones_dominio.dart';
import 'package:sistema_gestion/dominio/puertos/servicio_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ServicioPdfImpl implements ServicioPdf {
  @override
  Future<void> exportarReportePdf(ResumenFinanciero resumen) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Reporte Financiero de Arqueo',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Período: ${_formatearFecha(resumen.fechaInicio)} - ${_formatearFecha(resumen.fechaFin)}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 24),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    _filaTabla('Concepto', 'Monto', esEncabezado: true),
                    _filaTabla('Total Ingresos', _formatearMonto(resumen.totalIngresos)),
                    _filaTabla('Total Egresos', _formatearMonto(resumen.totalEgresos)),
                    _filaTabla('Balance Neto', _formatearMonto(resumen.balanceNeto),
                        esTotal: true),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total Efectivo',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatearMonto(resumen.totalEfectivo)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total Transferencia',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatearMonto(resumen.totalTransferencia)),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Generado el ${_formatearFechaHora(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'reporte_financiero_${_formatearFechaArchivo(resumen.fechaInicio)}_${_formatearFechaArchivo(resumen.fechaFin)}.pdf',
      );
    } catch (e) {
      throw ExcepcionPersistencia('Error al generar reporte PDF: $e');
    }
  }

  pw.TableRow _filaTabla(String concepto, String monto,
      {bool esEncabezado = false, bool esTotal = false}) {
    final estilo = esEncabezado
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)
        : esTotal
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)
            : const pw.TextStyle(fontSize: 12);

    return pw.TableRow(
      decoration: esEncabezado
          ? const pw.BoxDecoration(color: PdfColors.grey300)
          : esTotal
              ? const pw.BoxDecoration(color: PdfColors.grey100)
              : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(concepto, style: estilo),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(monto, style: estilo),
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearFechaArchivo(DateTime fecha) {
    return '${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}';
  }

  String _formatearFechaHora(DateTime fecha) {
    return '${_formatearFecha(fecha)} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _formatearMonto(double monto) {
    return '\$${monto.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}