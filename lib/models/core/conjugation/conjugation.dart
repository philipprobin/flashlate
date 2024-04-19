class Conjugation {
  final String pronoun;
  final String mainVerb;
  final String auxVerb;

  Conjugation({required this.pronoun, required this.mainVerb, required this.auxVerb});

  factory Conjugation.fromJson(Map<String, dynamic> json) {
    return Conjugation(
      pronoun: json['pronoun'],
      mainVerb: json['mainVerb'],
      auxVerb: json['auxVerb'] ?? '', // Handle possible null auxVerb
    );
  }
}