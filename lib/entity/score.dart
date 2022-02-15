import 'dart:math';

class Score {
  late final int id;
  late int _amount;
  late DateTime dateReached;


  int get amount => _amount;

  void incScore() {
    _amount++;
    dateReached = DateTime.now();
  }

  Score({int amount = 0, DateTime? dateReached, int? id}) {
    _amount = amount;
    this.dateReached = dateReached ?? DateTime.now();
    this.id = id ?? hashCode + Random.secure().nextInt(100);
  }

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        id: json['id'],
        amount: json['amount'],
        dateReached: DateTime.parse(json['date_reached']),
      );

  Map<String, dynamic> toJson() => {

        'id': id,
        'amount': _amount,
        'date_reached': dateReached.toString(),
      };
}
