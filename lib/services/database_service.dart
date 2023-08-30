import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'local_storage_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchAllCards() async {
    final user = _auth.currentUser;
    if (user == null) {
      // User not authenticated, handle accordingly
      debugPrint("User is not logged in");
      return {};
    }

    final userId = user.uid;
    final userDocRef = _firestore.collection('flashcards').doc(userId);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.exists) {
      return userDocSnapshot.data() as Map<String, dynamic>;
    } else {
      debugPrint("userDoc does not exist");
      return {};
    }
  }

  Future<List<Map<String, String>>> getCardsForCurrentDeck() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("User is not logged in");
      return []; // Return an empty list if the user is not logged in
    }

    final userId = user.uid;
    final userDocRef = _firestore.collection('flashcards').doc(userId);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      final currentDeck = await LocalStorageService.getCurrentDeck(); // Retrieve the current deck name

      Map<String, dynamic> deckData = userDocSnapshot.data() as Map<String, dynamic>;
      if (deckData.containsKey(currentDeck)) {
        Map<String, dynamic> currentDeckData = deckData[currentDeck] as Map<String, dynamic>;

        // Convert map entries to List<Map<String, String>>
        List<Map<String, String>> cardsList = [];
        currentDeckData.forEach((key, value) {
          cardsList.add({key: value.toString()});
        });

        return cardsList;
      }
    }

    return []; // Return an empty list if the current deck doesn't exist or other issues occur
  }


  Future<bool> addCard(String deckName, String key, dynamic value) async {
    final user = _auth.currentUser;
    if (user == null) {
      // User not authenticated, handle accordingly
      debugPrint("User is not logged in");

      return false;
    }

    final userId = user.uid;
    final userDocRef = _firestore.collection('flashcards').doc(userId);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    Map<String, dynamic> deck = {};
    deck[key] = value;

    if (userDocSnapshot.exists) {
      LocalStorageService.setCurrentDeck(deckName);

      try {
        if (key != "" && value != "") {
          await userDocRef.update({
            '$deckName.$key': value,
          });
        } else {

          await userDocRef.update({
            deckName: {}, // Add an empty map as content
          });
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

  Future<Map<String, dynamic>> fetchCards(String deckName) async {
    final user = _auth.currentUser;
    if (user == null) {
      // User not authenticated, handle accordingly
      debugPrint("User is not logged in");
      return {};
    }

    final userId = user.uid;
    final userDocRef = _firestore.collection('flashcards').doc(userId);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.exists) {
      Map<String, dynamic> userData =
          userDocSnapshot.data() as Map<String, dynamic>;
      if (userData.containsKey(deckName)) {
        return userData[deckName] as Map<String, dynamic>;
      } else {
        debugPrint("$deckName not found in user data");
        return {};
      }
    } else {
      debugPrint("userDoc does not exist");
      return {};
    }
  }
}
