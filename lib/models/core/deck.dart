import 'card.dart';

class Deck{
  String deckName;
  List<Card> cards;
  // todo add source and target language
  Deck({
    required this.deckName,
    required this.cards,
  });

  // add a card to the deck
  void add(Card card) {
    cards.add(card);
  }
}