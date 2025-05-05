import 'package:plat_number_detection/models/data_mobil.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MobilDatabase {
  static final MobilDatabase instance = MobilDatabase._init();

  MobilDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('platNomor.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE $tableDB ADD COLUMN ${DataMobilFields.plateBox} TEXT NOT NULL DEFAULT \'[]\'');
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const sql = '''
      CREATE TABLE $tableDB(
        ${DataMobilFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DataMobilFields.name} TEXT NOT NULL,
        ${DataMobilFields.image} TEXT NOT NULL,
        ${DataMobilFields.platDaerah} TEXT NOT NULL,
        ${DataMobilFields.platNomor} TEXT NOT NULL,
        ${DataMobilFields.platRegional} TEXT NOT NULL,
        ${DataMobilFields.jenisKendaraan} TEXT NOT NULL,
        ${DataMobilFields.plateBox} TEXT NOT NULL,
        ${DataMobilFields.timestamp} TEXT NOT NULL
      )
    ''';
    await db.execute(sql);
  }

  Future<DataMobil> create(DataMobil dataMobil) async {
    final db = await instance.database;
    final id = await db.insert(tableDB, dataMobil.toJson());
    return dataMobil.copy(id: id);
  }

  Future<List<DataMobil>> getAllData() async {
    final db = await instance.database;
    final result = await db.query(tableDB);
    return result.map((json) => DataMobil.fromJSON(json)).toList();
  }

  Future<DataMobil> getDataById(int id) async {
    final db = await instance.database;
    final result = await db
        .query(tableDB, where: '${DataMobilFields.id} = ?', whereArgs: [id]);
    if (result.isEmpty) throw Exception('ID $id not found!!!');
    return DataMobil.fromJSON(result.first);
  }

  Future<int> deleteDataById(int id) async {
    final db = await instance.database;
    return await db
        .delete(tableDB, where: '${DataMobilFields.id} = ?', whereArgs: [id]);
  }

  Future<int> updateNote(DataMobil dataMobil) async {
    final db = await instance.database;
    return await db.update(tableDB, dataMobil.toJson(),
        where: '${DataMobilFields.id} = ?', whereArgs: [dataMobil.id]);
  }

  Future<void> deleteAllRecords() async {
    final db = await instance.database;
    await db.delete(tableDB);
  }
}
