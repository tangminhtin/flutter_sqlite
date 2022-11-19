import 'package:flutter_sqlite/car.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  /// Database file and version
  static const _databaseName = 'cardb.db';
  static const _databaseVersion = 1;

  /// Table name
  static const table = 'cars_table';

  /// Fields
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnMiles = 'miles';

  /// Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  /// Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    /// Lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  /// This opens the database (and creates it if doesn't exist)
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: _databaseVersion,
    );
  }

  /// SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnMiles INTEGER NOT NULL
      )
    ''');
  }

  /// Helper methods
  ///
  /// Inserts a row in the database where each key in the Map is a column name
  /// and the value is the column value. The return value is the id of the
  /// inserted row.
  Future<int> insert(Car car) async {
    Database db = await instance.database;
    return await db.insert(table, {
      'name': car.name,
      'miles': car.miles,
    });
  }

  /// All of the rows are returned as a list of maps, where each map is
  /// a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return db.query(table);
  }

  /// Queries rows based on the argument received
  Future<List<Map<String, dynamic>>> queryRows(name) async {
    Database db = await instance.database;
    return await db.query(table, where: "$columnName LIKE '%$name%'");
  }

  /// All of methods (insert, query, update, delete) can also be done using
  /// raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $table'),
    );
  }

  /// We are assuming here that the id column in the map is set. The other
  /// column values will be used to update the row
  Future<int> update(Car car) async {
    Database db = await instance.database;
    int id = car.toMap()['id'];
    return await db.update(
      table,
      car.toMap(),
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Deletes the row specified by the id. The number of affected rows is
  /// returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
