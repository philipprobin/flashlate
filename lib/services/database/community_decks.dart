import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/core/card.dart';
import '../../models/core/deck.dart';

class CommunityDecks {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      });
    }
    return decks;
  }
}
