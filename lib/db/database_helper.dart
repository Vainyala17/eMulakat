// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/visitor_model.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;
//
//   DatabaseHelper._internal();
//
//   factory DatabaseHelper() {
//     return _instance;
//   }
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'emulakat.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDatabase,
//     );
//   }
//
//   Future<void> _createDatabase(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE visitors (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         visitorName TEXT NOT NULL,
//         fatherName TEXT NOT NULL,
//         address TEXT NOT NULL,
//         gender TEXT NOT NULL,
//         age INTEGER NOT NULL,
//         relation TEXT NOT NULL,
//         idProof TEXT NOT NULL,
//         idNumber TEXT NOT NULL,
//         imagePath TEXT,
//         isInternational INTEGER NOT NULL,
//         email TEXT,
//         mobile TEXT,
//         state TEXT NOT NULL,
//         jail TEXT NOT NULL,
//         visitDate TEXT NOT NULL,
//         additionalVisitors INTEGER NOT NULL,
//         additionalVisitorNames TEXT NOT NULL,
//         prisonerName TEXT NOT NULL,
//         prisonerFatherName TEXT NOT NULL,
//         prisonerAge INTEGER NOT NULL,
//         prisonerGender TEXT NOT NULL,
//         mode TEXT NOT NULL
//       )
//     ''');
//   }
//
//   Future<int> insertVisitor(VisitorModel visitor) async {
//     final db = await database;
//     return await db.insert('visitors', visitor.toMap());
//   }
//
//   Future<List<VisitorModel>> getVisitors() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('visitors');
//     return List.generate(maps.length, (i) {
//       return VisitorModel.fromMap(maps[i]);
//     });
//   }
//
//   Future<int> updateVisitor(VisitorModel visitor) async {
//     final db = await database;
//     return await db.update(
//       'visitors',
//       visitor.toMap(),
//       where: 'id = ?',
//       whereArgs: [visitor.id],
//     );
//   }
//
//   Future<int> deleteVisitor(int id) async {
//     final db = await database;
//     return await db.delete(
//       'visitors',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }