import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/puertos/servicio_pdf.dart';

class ExportarReportePdf {
  ExportarReportePdf(this._servicioPdf);

  final ServicioPdf _servicioPdf;

  Future<void> ejecutar(ResumenFinanciero resumen) {
    return _servicioPdf.exportarReportePdf(resumen);
  }
}