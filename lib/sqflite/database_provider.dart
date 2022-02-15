import 'package:lab_1/entity/score.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider db = DBProvider._inner();  //синглтон типа
  static Database? _database;

  DBProvider._inner(); //приватный конструктор

  Future<Database> get database async { //геттер для БД
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'CustomDB.db');
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        //если надо очистить таблицу
        // await db.execute("DROP TABLE IF EXISTS Score");
        // await db.execute(
        //   'CREATE TABLE Score ('
        //       'id INTEGER PRIMARY KEY,'
        //       'amount INTEGER,'
        //       'date_reached TEXT'
        //       ')',
        // );
      },
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Score ('
          'id INTEGER PRIMARY KEY,'
          'amount INTEGER,'
          'date_reached TEXT'
          ')',
        );
      },
    );
  }

  Future<int> newScore(Score score) async {
    final db = await database;
    final res = await db.insert('Score', score.toJson());
    return res;
  }

  Future<int> updateScore(Score score) async {
    final db = await database;
    final res = await db.update('Score', score.toJson(), where: 'id = ?', whereArgs: [score.id]);
    return res;
  }

  Future<int> deleteScore(Score score) async {
    final db = await database;
    final res = db.delete('Score', where: 'id = ${score.id}');
    return res;
  }

  Future<List<Score>> loadScores() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Score'));
    //если count=0, возвращаем пустой массив, иначе виджет списка счетов будет постоянно ждать и крутиться
    if (count == 0) {
      return [];
    } else {
      final res = await db.query(
        'Score',
        orderBy: 'amount DESC',
      );
      final list = res.isNotEmpty ? res.map((c) => Score.fromJson(c)).toList() : [];
      return list as List<Score>;
    }
  }
}
