import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './../models/variables_persistentes.dart';

/*
 * Clase que controla los servicios de comunicación con la base de datos
 * https://dev.to/thepythongeeks/step-by-step-to-store-data-locally-in-flutter-1mc9
 */
class DatabaseService {
  //  Variables de la base de datos
  static final _dbName = "serpiente.db";
  static final _dbVersion = 1;
  static final DatabaseService instance =
      DatabaseService._(); // Instancia a la base de datos local
  static Database _database;
  static final _tableName = "varper";

  // Constructor de la clase privado
  DatabaseService._();

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initiateDatabase();
    return _database;
  }

  Future<Database> _initiateDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) {
    return db.execute('''CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value INTEGER,
        nombre TEXT,
        createdTime DATETIME)
      ''');
  }

  //Método para insertar una varible a la base de datos
  Future<int> insertVar(VariablesPersistentes variable) async {
    Database db = await instance.database;
    int id = await db.insert(_tableName, variable.toMap());
    db.close();
    return id;
  }

  //Método para obtener valores de la base de datos
  Future<VariablesPersistentes> getVar(String nombre) async {
    Database db = await instance.database;
    List<Map> datas =
        await db.query(_tableName, where: 'nombre = ?', whereArgs: [nombre]);
    if (datas.length > 0) {
      return VariablesPersistentes.fromMap(datas.first);
    }
    db.close();
    return null;
  }

  /// Metodo para actualizar una variable
  Future<int> updateVar(String nombre, int valor) async {
    Database db = await instance.database;
    int filasCambiadas = await db.rawUpdate(
        'UPDATE $_tableName SET value = ?, nombre = ? WHERE nombre = ?',
        [valor, nombre, nombre]);
    db.close();
    return filasCambiadas;
  }
}
