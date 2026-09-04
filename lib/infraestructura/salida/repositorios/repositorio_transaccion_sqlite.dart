import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart';
import 'package:sistema_gestion/dominio/entidades/resumen_financiero.dart';
import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/dominio/entidades/excepciones/excepciones_dominio.dart';
import 'package:sistema_gestion/dominio/puertos/repositorio_transaccion.dart';
import 'package:sistema_gestion/infraestructura/salida/bd/conexion_sqlite.dart';
import 'package:sqflite/sqflite.dart';

class RepositorioTransaccionSqlite implements RepositorioTransaccion {
  final ConexionSqlite _conexion;

  RepositorioTransaccionSqlite(this._conexion);

  @override
  Future<void> registrarIngreso(Transaccion transaccion) async {
    try {
      final db = await _conexion.database;
      final map = _transaccionAMap(transaccion, 'ingreso');
      await db.insert('transacciones', map, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw ExcepcionPersistencia('Error al registrar ingreso: $e');
    }
  }

  @override
  Future<void> registrarEgreso(Transaccion transaccion) async {
    try {
      final db = await _conexion.database;
      final map = _transaccionAMap(transaccion, 'egreso');
      await db.insert('transacciones', map, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw ExcepcionPersistencia('Error al registrar egreso: $e');
    }
  }

  @override
  Future<List<Transaccion>> obtenerTransaccionesPorFecha(DateTime fecha) async {
    try {
      final db = await _conexion.database;
      final inicioDia = DateTime(fecha.year, fecha.month, fecha.day);
      final finDia = inicioDia.add(const Duration(days: 1));

      final inicioStr = inicioDia.toIso8601String().substring(0, 10);
      final finStr = finDia.toIso8601String().substring(0, 10);

      final resultados = await db.query(
        'transacciones',
        where: 'fecha_hora >= ? AND fecha_hora < ?',
        whereArgs: [inicioStr, finStr],
        orderBy: 'fecha_hora DESC',
      );

      return resultados.map(_mapATransaccion).toList();
    } catch (e) {
      throw ExcepcionPersistencia('Error al obtener transacciones por fecha: $e');
    }
  }

  @override
  Future<List<Transaccion>> obtenerUltimasTransacciones(int limite) async {
    try {
      final db = await _conexion.database;
      final resultados = await db.query(
        'transacciones',
        orderBy: 'fecha_hora DESC',
        limit: limite,
      );

      return resultados.map(_mapATransaccion).toList();
    } catch (e) {
      throw ExcepcionPersistencia('Error al obtener últimas transacciones: $e');
    }
  }

  @override
  Future<ResumenFinanciero> obtenerResumenPorPeriodo(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final db = await _conexion.database;

      final inicioStr = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day)
          .toIso8601String()
          .substring(0, 10);
      final finStr = DateTime(fechaFin.year, fechaFin.month, fechaFin.day)
          .add(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);

      final resultados = await db.query(
        'transacciones',
        where: 'fecha_hora >= ? AND fecha_hora < ?',
        whereArgs: [inicioStr, finStr],
      );

      double totalIngresos = 0;
      double totalEgresos = 0;
      double totalEfectivo = 0;
      double totalTransferencia = 0;

      for (final row in resultados) {
        final monto = (row['monto'] as num).toDouble();
        final tipo = row['tipo_movimiento'] as String;
        final medio = row['medio_pago'] as String;

        if (tipo == 'ingreso') {
          totalIngresos += monto;
        } else {
          totalEgresos += monto;
        }

        if (medio == 'efectivo') {
          totalEfectivo += monto;
        } else {
          totalTransferencia += monto;
        }
      }

      return ResumenFinanciero(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        totalIngresos: totalIngresos,
        totalEgresos: totalEgresos,
        balanceNeto: totalIngresos - totalEgresos,
        totalEfectivo: totalEfectivo,
        totalTransferencia: totalTransferencia,
      );
    } catch (e) {
      throw ExcepcionPersistencia('Error al obtener resumen por período: $e');
    }
  }

  Map<String, dynamic> _transaccionAMap(Transaccion transaccion, String tipoMovimiento) {
    return {
      'monto': transaccion.monto,
      'medio_pago': transaccion.medioPago.name,
      'tipo_movimiento': tipoMovimiento,
      'descripcion': transaccion.descripcion,
      'fecha_hora': transaccion.fechaHora.toIso8601String(),
    };
  }

  Transaccion _mapATransaccion(Map<String, dynamic> map) {
    return Transaccion(
      id: map['id'] as int?,
      monto: (map['monto'] as num).toDouble(),
      medioPago: MedioPago.values.firstWhere((e) => e.name == map['medio_pago']),
      tipoMovimiento: TipoMovimiento.values.firstWhere((e) => e.name == map['tipo_movimiento']),
      descripcion: map['descripcion'] as String?,
      fechaHora: DateTime.parse(map['fecha_hora'] as String),
    );
  }
}