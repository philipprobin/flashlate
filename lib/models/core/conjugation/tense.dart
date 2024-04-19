import 'conjugation.dart';

class Tense {
  final String tenseName;
  final List<Conjugation> conjugations;

  Tense({required this.tenseName, required this.conjugations});

  factory Tense.fromJson(Map<String, dynamic> json) {
    var conjugationsList = json['conjugations'] as List;
    List<Conjugation> conjugations = conjugationsList.map((conjugation) => Conjugation.fromJson(conjugation)).toList();
    return Tense(tenseName: json['tense'], conjugations: conjugations);
  }
}