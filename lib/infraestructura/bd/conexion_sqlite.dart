import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ConexionSqlite {
  ConexionSqlite._();

  static final ConexionSqlite _instancia = ConexionSqlite._();

  static ConexionSqlite get instancia => _instancia;

  Database? _bd;

  Future<Database> get database async {
    if (_bd != null) return _bd!;
    _bd = await _inicializarBD();
    return _bd!;
  }

  Future<Database> _inicializarBD() async {
    final directorio = await getDatabasesPath();
    final ruta = join(directorio, 'sistema_gestion.db');

    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transacciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            monto REAL NOT NULL,
            medio_pago TEXT NOT NULL,
            tipo_movimiento TEXT NOT NULL,
            descripcion TEXT,
            fecha_hora TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> cerrar() async {
    final db = _bd;
    if (db != null) {
      await db.close();
      _bd = null;
    }
  }
}