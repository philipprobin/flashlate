import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'local_storage_service.dart';

class DatabaseService {
  static Future<DocumentReference<Map<String, dynamic>>?>
      get _userDocRef async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not authenticated, handle accordingly
      debugPrint("User is not logged in");
      return null;
    }

    final userId = user.uid;
    final userDocRef =
        FirebaseFirestore.instance.collection('flashcards').doc(userId);
    return userDocRef;
  }

  static Future<Map<String, dynamic>> fetchUserDoc() async {
    final userDocRef = await _userDocRef;
    if (userDocRef == null) {
      return {};
    }

    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.exists) {
      return userDocSnapshot.data() as Map<String, dynamic>;
    } else {
      debugPrint("userDoc does not exist");
    }

    return {};
  }

  Future<bool> deleteDeck(String deckName) async {
    final userDocRef = await _userDocRef;
    if (userDocRef == null) {
      return false;
    }

    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (!userDocSnapshot.exists) {
      // Document doesn't exist, handle accordingly
      debugPrint("Document does not exist");
      return false;
    }

    // Delete the deckName field from the document
    try {
      await userDocRef.update({
        deckName: FieldValue.delete(),
      });
      return true;
    } catch (error) {
      debugPrint('Error deleting deck: $error');
      return false;
    }
  }

  Future<bool> addCard(String deckName, String key, dynamic value) async {
    final userDocRef = await _userDocRef;
    if (userDocRef == null) {
      return false;
    }

    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    List<Map<String, dynamic>> deck = [];

    // Create a Flashcard object with key, value, and timestamp
    String time = DateTime.now().toString();
    Map<String, dynamic> content = <String, dynamic>{
      'translation': {key: value},
      "time": time,
    };

    // Add the Flashcard object to the deck map
    deck.add(content);

    if (userDocSnapshot.exists) {
      try {
        if (key != "" && value != "") {
          await userDocRef.update({
            deckName: FieldValue.arrayUnion([content])
          }).catchError((e) => print(e));
        } else {
          await userDocRef
              .update({deckName: FieldValue.arrayUnion([])}).catchError(
                  (e) => print(e)); // Add an empty map as content

          debugPrint("init empty map");
        }
        return true;
      } catch (error) {
        debugPrint('Error updating document: $error');
        return false;
      }
    } else {
      debugPrint("userDoc does not exist");
      return false;
    }
  }

  static Future<bool> deleteCard(
      String deckName, Map<String, dynamic> translation) async {
    final userDocRef = await _userDocRef;
    if (userDocRef == null) {
      return false;
    }
    Map<String, dynamic> downloadDecks = await fetchUserDoc();
    List<Map<String, dynamic>> deck = [];

    int indexToDelete = -1;

    downloadDecks.forEach((listName, cards) {
      if (listName == deckName) {
        int i = 0;
        for (Map<String, dynamic> card in cards) {
          // Find the index of the dictionary with the specified card to delete
          Map<String, String> currentCard = {
            card.keys.first: card.values.first.toString()
          };
          if (currentCard["translation"].toString() == translation.toString()) {
            indexToDelete = i;
          }
          deck.add(card);
          i++;
        }
      }
    });

    if (indexToDelete != -1) {
      // Dictionary found, delete it
      deck.removeAt(indexToDelete);

      try {
        await userDocRef.update({
          deckName: deck,
        });
        return true;
      } catch (error) {
        debugPrint('Error updating document: $error');
        return false;
      }
    } else {
      debugPrint("Translation not found in the deck");
      return false;
    }
  }
}
