import 'mood.dart';

class ConjugationResult {
  final String infinitive;
  final List<Mood> moods;

  ConjugationResult({required this.infinitive, required this.moods});

  factory ConjugationResult.fromJson(Map<String, dynamic> json) {
    var moodsList = json['data']['moods'] as List;
    List<Mood> moods = moodsList.map((mood) => Mood.fromJson(mood)).toList();
    return ConjugationResult(infinitive: json['infinitive'], moods: moods);
  }
}