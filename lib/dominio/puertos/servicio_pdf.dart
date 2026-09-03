import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';

abstract class ServicioPdf {
  Future<void> exportarReportePdf(ResumenFinanciero resumen);
}