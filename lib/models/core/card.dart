class Card{
  String? time;
  String? term;
  String? translation;

  Card({
    this.time,
    this.term,
    this.translation,
  });

  Card.fromMap(Map<String, dynamic> data) {
    this.time = data['time']?? '';
    var translationMap = data['translation'] as Map<String, dynamic>;
    this.term = translationMap.keys.first;
    this.translation = translationMap.values.first.toString();
  }
}