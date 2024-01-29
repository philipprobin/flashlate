import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/core/card.dart';
import '../../models/core/deck.dart';

class CommunityDecks {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _extractNumber(String str) {
    var numbers = RegExp(r'\d+').allMatches(str).map((m) => int.parse(m.group(0)!)).toList();
    return numbers.isNotEmpty ? numbers.reduce((a, b) => a + b) : 0;
  }

  Future<List<Deck>> fetchCommunityDecks(String langCodes) async {
    print("fetching community decks $langCodes");
    CollectionReference collectionReference =
        _firestore.collection("communityDecks");

    // Find the document with the specified langCodes
    DocumentSnapshot documentSnapshot =
        await collectionReference.doc(langCodes).get();

    List<Deck> decks = [];

    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      var decksMap = documentSnapshot.data() as Map<String, dynamic>;
      decksMap.forEach((listName, cards) {
        {
          Deck deck = Deck(deckName: listName, cards: []);
          for (Map<String, dynamic> cardMap in cards) {
            // Parse each deck and its cards
            Card card = Card.fromMap(cardMap);
            deck.add(card);
          }
          decks.add(deck);
        }
        // Sort the decks by extracting and comparing numbers in deckName

      });
      // Sort the decks by extracting and comparing numbers in deckName
      decks.sort((a, b) {
        var numA = _extractNumber(a.deckName);
        var numB = _extractNumber(b.deckName);

        if (numA != numB) {
          return numA.compareTo(numB);
        }
        return a.deckName.compareTo(b.deckName);
      });
    }
    return decks.reversed.toList();
  }


}
