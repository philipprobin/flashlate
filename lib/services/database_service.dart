import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';


import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class DatabaseService {

  static Future<void> signupWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],

      // TODO: Remove these if you have no need for them
      // nonce: 'example-nonce',
      // state: 'example-state',
    );

    // ignore: avoid_print
    print(credential);

    final credential1 = await SignInWithApple.getAppleIDCredential(
        scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
        ],
    );

    print(credential.authorizationCode);
    final signInCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken!,
      accessToken: credential.authorizationCode!,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(signInCredential);

// Now use your user
    print(userCredential.user);
  }
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

    // Check if the document exists
    await userDocRef.get().then((docSnapshot) {
      if (!docSnapshot.exists) {
        // Document doesn't exist, so create an empty one
        userDocRef.set({}).then((_) {
          // Empty document created successfully
          debugPrint("document $userId newly added");
        }).catchError((error) {
          // Handle errors, e.g., document creation failed
          debugPrint("document creation failed: $error");
        });
      }
    }).catchError((error) {
      // Handle errors, e.g., getting document failed
      debugPrint("getting document failed: $error");
    });
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
      debugPrint("userDoc does not exist (fetchUserDoc)");
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
      debugPrint("userDoc does not exist (addCard)");
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

  static void addVerbToDB(String verb, Map verbConjugations) {
    final CollectionReference verbsCollection =
        FirebaseFirestore.instance.collection('esVerbs');

    // Create a document reference for the verb in the Firestore collection.
    final DocumentReference verbDocRef = verbsCollection.doc(verb);

    // Upload the verb conjugations map to Firestore.
    verbDocRef.set({
      'conjugations': verbConjugations,
    }).then((_) {
      print('Verb data added to Firestore for $verb');
    }).catchError((error) {
      print('Error uploading data: $error');
    });
  }

  static Future<Map<String, dynamic>?> queryVerbES(String conjToFind) async {
    // Initialize Firebase with your service account credentials
    debugPrint("conjToFind --$conjToFind--");

    final CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('verbsES');

    final List<String> filterList = await generateFilters(conjToFind);

    // Search by filters
    for (final filterString in filterList) {
      final querySnapshot = await collectionRef.where(filterString, isEqualTo: conjToFind).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        return {
          "infinitive": doc.id,
          "path": filterString,
          "input": conjToFind,
          "conjugations": data,
        };
      }
    }

    // Look for infinitive
    final verbSuffixesEs = ['ar', 'er', 'ir'];

    for (final suffix in verbSuffixesEs) {
      if (conjToFind.endsWith(suffix)) {
        final doc = await collectionRef.doc(conjToFind).get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          return {
            "infinitive": doc.id,
            "input": conjToFind,
            "conjugations": data,
          };
        }
      }
    }

    return null;
  }


  static Future<List<String>> generateFilters(String conjToFind) async {
    var filters = <String>[];
    Map<String, dynamic> grammaticalRules =
        await loadJsonFile("assets/grammar_rules/grammatical_rules_es.json");

    grammaticalRules.forEach((key, value) {
      if (conjToFind.endsWith(key)) {
        if (value is List<dynamic>) {
          filters.addAll(value.map((item) => item.toString()));
        }
      }
    });

    return filters;
  }

  static Future<Map<String, dynamic>> loadJsonFile(String assetPath) async {
    try {
      final String jsonContent = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonContent);
      return jsonData;
    } catch (e) {
      print('Error loading JSON file: $e');
      return {};
    }
  }
}
