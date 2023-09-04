import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'local_storage_service.dart';

class DatabaseService {

  Future<Map<String, dynamic>> fetchUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not authenticated, handle accordingly
      debugPrint("User is not logged in");
      return {};
    }

    final userId = user.uid;
    final userDocRef =
        FirebaseFirestore.instance.collection('flashcards').doc(userId);

    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.exists) {

      return userDocSnapshot.data() as Map<String, dynamic>;
    } else {
      debugPrint("userDoc does not exist");
    }

    return {};
  }

  Future<bool> deleteDeck(String deckName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not authenticated, handle accordingly
      debugPrint("User is not logged in");
      return false;
    }

    final userId = user.uid;
    final userDocRef = FirebaseFirestore.instance.collection('flashcards').doc(userId);

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not authenticated, handle accordingly
      debugPrint("User is not logged in");
      return false;
    }

    final userId = user.uid;
    final userDocRef =
        FirebaseFirestore.instance.collection('flashcards').doc(userId);

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
}
