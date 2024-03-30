import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:scapp/model/model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'scapp.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE persons(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            image TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertPerson(Model person) async {
    final dbClient = await db;
    await dbClient.insert(
      'persons',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );  
  }  

  Future<List<Model>> getPersons() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('persons');
    return List.generate(maps.length, (i) {
      return Model(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        image: maps[i]['image'],
      );
    });
  }

  Future<void> updatePerson(Model person) async {
    final dbClient = await db;
    await dbClient.update(
      'persons',
      person.toMap(),
      where: 'id = ?',
      whereArgs: [person.id],
    ); 
    
  }

  Future<void> deletePerson(String id) async {
    final dbClient = await db;
    await dbClient.delete(
      'persons',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
