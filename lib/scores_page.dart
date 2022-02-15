import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_1/sqflite/scores_repository.dart';

import 'entity/score.dart';


DateFormat fullDateFormatter = DateFormat('d MMM y HH:mm');

class ScoresPage extends StatelessWidget {
  const ScoresPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result\'s page'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Score>>(
              future: ScoresRepository.getScores(),

              initialData: const [],
              //то что строим
              builder: (context, snapshot) {
                //пока данные не пришли, крутим загрузку
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else {
                  final list = snapshot.data as List<Score>;
                  //строит для каждого элемента строит запись
                  return ListView.builder(
                    itemCount: list.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    //physics - скролим
                    physics: const AlwaysScrollableScrollPhysics(),
                    //делаю карточку для каждого элемента
                    itemBuilder: (context, index) {
                      return _scoreCard(list[index], index);
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreCard(Score score, int index) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration( //цвета
        //список приходит отсортированный по убыванию, самый большой счет - с индексом 0
        color: index == 0
            ? Colors.yellow //типа золотой
            : index == 1
                ? Colors.grey //типа серебряный
                : index == 2
                    ? Colors.orangeAccent
                    : Colors.transparent,
      ),
      child: Row(
        children: <Widget>[
          Text('${score.amount.toString()}  points   -'),
          const SizedBox(width: 10),
          //дата по формату
          Text(fullDateFormatter.format(score.dateReached)),
        ],
      ),
    );
  }
}
