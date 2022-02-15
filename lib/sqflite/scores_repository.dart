import 'package:lab_1/entity/score.dart';

import 'database_provider.dart';

class ScoresRepository {
  //конструктор вызывается
  static Score newScore() => Score();

  //создаем в бд запись только когда увеличивается счетчик. Если =1, создаем запись
  static void incScore(Score score) {
    score.incScore();

    if (score.amount == 1) {
      DBProvider.db.newScore(score);
    } else {
      DBProvider.db.updateScore(score);
    }
  }
  //в бд (Future = async)
  static Future<List<Score>> getScores() => DBProvider.db.loadScores();
}
