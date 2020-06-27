import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './../models/variables_persistentes.dart';


/**
 * Clase que controla los servicios de comunicación con la base de datos
 */
class DatabaseService {
  //  Variables de la base de datos
  static final _dbName = "serpiente.db";
  static final _dbVersion = 1;
  static final DatabaseService instance = DatabaseService._();
  static Database _database;
  static final _tableName = "varper";

  // Constructor de la clase privado
  DatabaseService._();

  Future<Database> get database async {
    if (_database != null){
      return _database;
    }

    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase ()  async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate
    );
  }

  Future _onCreate(Database db , int version){
    return db.execute(
      '''CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value INTEGER,
        nombre TEXT,
        createdTime DATETIME)
      '''
    );
  }
  


  /*
  // Creamos la instancia de la base de datos
  static final DatabaseService _instance = DatabaseService._internal();
  Future<Database> database;

  // Método que crea la conexión con el servicio de la base de datos
  factory DatabaseService() {
    return _instance;
  }

  //Método que crea la base de datos en el caso de que no exista
  DatabaseService._internal() {
    initDatabase();
  }

  //Método de creación de la base de datos
  initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'serpiente.db');

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {

    }

    database = await openDatabase(
      path, version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        db.execute(
          '''CREATE TABLE $tablaVariablesPersistentes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value INTEGER,
            nombre TEXT,
            createdTime DATETIME)
          ''',
        );
      }) as Future<Database>;
  }*/

  //Método para insertar una varible a la base de datos
  Future<int> insertVar(VariablesPersistentes variable) async {
    Database db = await instance.database;
    int id = await db.insert(_tableName, variable.toMap());
    return id;
  }

  //Método para obtener valores de la base de datos
  Future<VariablesPersistentes> getVar(String nombre) async {
    Database db = await instance.database;
    List<Map> datas = await db.query(_tableName,
        where: 'nombre = ?',
        whereArgs: [nombre]);
    if (datas.length > 0) {
      return VariablesPersistentes.fromMap(datas.first);
    }
    return null;
  }

  Future<int> updateVar(String nombre,int valor) async {
    Database db = await instance.database;
    int filasCambiadas = await db.rawUpdate(
      'UPDATE $_tableName SET value = ?, nombre = ? WHERE nombre = ?',
      [valor, nombre, nombre]
    );
    return filasCambiadas;
  }

}