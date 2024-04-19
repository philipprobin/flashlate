import 'package:flashlate/models/core/conjugation/tense.dart';

class Mood {
  final String moodName;
  final List<Tense> tenses;

  Mood({required this.moodName, required this.tenses});

  factory Mood.fromJson(Map<String, dynamic> json) {
    var tensesList = json['tenses'] as List;
    List<Tense> tenses = tensesList.map((tense) => Tense.fromJson(tense)).toList();
    return Mood(moodName: json['mood'], tenses: tenses);
  }
}