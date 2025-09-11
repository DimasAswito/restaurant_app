import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/restaurant.dart';

class FavoriteDb {
  static final FavoriteDb _instance = FavoriteDb._internal();
  static Database? _database;

  FavoriteDb._internal();
  factory FavoriteDb() => _instance;

  static const String _tableName = 'favorites';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'favorite_restaurant.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id TEXT PRIMARY KEY,
            name TEXT,
            city TEXT,
            rating REAL,
            pictureId TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'id': restaurant.id,
        'name': restaurant.name,
        'city': restaurant.city,
        'rating': restaurant.rating,
        'pictureId': restaurant.pictureId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);

    return result.map((row) {
      return Restaurant(
        id: row['id'],
        name: row['name'],
        description: '', // tidak disimpan di favorit
        pictureId: row['pictureId'],
        city: row['city'],
        rating: row['rating'],
      );
    }).toList();
  }

  Future<Restaurant?> getFavoriteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> result =
    await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      final row = result.first;
      return Restaurant(
        id: row['id'],
        name: row['name'],
        description: '',
        pictureId: row['pictureId'],
        city: row['city'],
        rating: row['rating'],
      );
    }
    return null;
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

}
