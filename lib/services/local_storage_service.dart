import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _currentDeckKey = 'currentDeck';

  static Future<void> setCurrentDeck(String deckName) async {
    // doesnt create entry for cards
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentDeckKey, deckName);
    debugPrint("current Deck was set $deckName");
  }

  static Future<String> getCurrentDeck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_currentDeckKey) == null) {
      return await LocalStorageService.addDeck("Deck", true);
    } else {
      return prefs.getString(_currentDeckKey)!;
    }
  }

  static Future<List<String>> getDeckNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the existing deck names from shared preferences
    List<String>? encodedDeck = prefs.getStringList("decks");

    if (encodedDeck == null || encodedDeck.isEmpty) {
      return []; // No decks in the list
    }
    return encodedDeck;
  }

  static Future<void> deleteDeck(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> allDeckNames = await LocalStorageService.getDeckNames();
    String currentDeck = await LocalStorageService.getCurrentDeck();
    if (deckName == currentDeck) {
      if (allDeckNames.length == 1) {
        // only current is in list
        prefs.getString(_currentDeckKey) == null;
      } else {
        await deleteDeckRefs(deckName);
        List<String> allDeckNames = await LocalStorageService.getDeckNames();
        LocalStorageService.setCurrentDeck(allDeckNames[0]);
        return;
      }
    }
    await deleteDeckRefs(deckName);
  }

  static Future<void> deleteDeckRefs(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // remove all Cards
    await prefs.remove(deckName);

    // remove name from deckList
    // Retrieve the existing deck names from shared preferences
    List<String>? encodedDeck = prefs.getStringList("decks");

    if (encodedDeck == null || encodedDeck.isEmpty) {
      return; // No decks in the list to remove from
    }

    // Remove the desired string from the list
    encodedDeck.remove(deckName);

    // Save the updated list back to shared preferences
    await prefs.setStringList("decks", encodedDeck);
    debugPrint("deckDeleted: $deckName");
  }

  static Future<String> addDeck(String deckName, bool setCurrent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the existing deck names from shared preferences
    List<String>? encodedDeck = prefs.getStringList("decks") ?? [];

    if (encodedDeck.contains(deckName)) {
      // If the deckName already exists in the list, find an available number to append
      int number = 1;
      String newDeckName = '$deckName ($number)';
      while (encodedDeck.contains(newDeckName)) {
        number++;
        newDeckName = '$deckName ($number)';
      }
      deckName = newDeckName;
    }

    encodedDeck.add(deckName);

    if (setCurrent) {
      setCurrentDeck(deckName);
    }

    // Save the updated deck names list to shared preferences
    prefs.setStringList("decks", encodedDeck);

    return deckName;
  }

  static Future<bool> addCardToLocalDeck(
      String listName, Map<String, dynamic> dict) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the SharedPreferences entry with the listName exists
    if (!prefs.containsKey(listName)) {
      // If it doesn't exist, create an empty list and save it
      await prefs.setStringList(listName, []);
    }

    // Retrieve the existing deck from shared preferences
    List<String>? encodedDeck = prefs.getStringList(listName);
    List<Map<String, dynamic>> deck = [];

    // Copy to List
    if (encodedDeck != null) {
      for (String encodedDict in encodedDeck) {
        Map<String, dynamic> decodedDict = json.decode(encodedDict);
        deck.add(decodedDict);
      }
    }

    // Check if the dictionary already exists in the deck
    bool dictionaryExists = deck.any((card) {
      return card.toString() ==
          dict.toString(); // You may want to compare more selectively.
    });

    if (!dictionaryExists) {
      // Add the new dictionary to the deck
      deck.add(dict);

      // Save the updated deck to shared preferences
      List<String> encodedUpdatedDeck = [];

      for (Map<String, dynamic> deckDict in deck) {
        String encodedDict = json.encode(deckDict);
        encodedUpdatedDeck.add(encodedDict);
      }

      await prefs.setStringList(listName, encodedUpdatedDeck);
      return true;
    } else {
      // dict already exist -> saving returns false
      return false;
    }
  }

  // Method to copy a deck from one key to another
  static Future<bool> copyDeckToPracticeMode(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the SharedPreferences entry with listName exists
    if (!prefs.containsKey(deckName)) {
      // The deck you want to copy doesn't exist
      return false;
    }

    // Retrieve the deck from listName
    List<String>? encodedDeck = prefs.getStringList(deckName);
    List<Map<String, dynamic>> deck = [];

    // Copy to List
    if (encodedDeck != null) {
      for (String encodedDict in encodedDeck) {
        Map<String, dynamic> decodedDict = json.decode(encodedDict);
        deck.add(decodedDict);
      }
    }

    // Save the deck to "pRaCtIcEmOde-deckName"
    List<String> encodedUpdatedDeck = [];

    for (Map<String, dynamic> deckDict in deck) {
      String encodedDict = json.encode(deckDict);
      // add
      encodedUpdatedDeck.add(encodedDict);
    }

    await prefs.setStringList("pRaCtIcEmOde-$deckName", encodedUpdatedDeck);
    return true;
  }

  static Future<bool> deleteCardFromLocalDeck(
      String listName, Map<String, dynamic> dict) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the SharedPreferences entry with the listName exists
    if (!prefs.containsKey(listName)) {
      return false; // The deck doesn't exist, so nothing to delete
    }

    // Retrieve the existing deck from shared preferences
    List<String>? encodedDeck = prefs.getStringList(listName);
    List<Map<String, dynamic>> deck = [];

    // Copy to List
    if (encodedDeck != null) {
      for (String encodedDict in encodedDeck) {
        Map<String, dynamic> decodedDict = json.decode(encodedDict);
        deck.add(decodedDict);
      }
    }

    // Check if the dictionary exists in the deck
    int indexToDelete = -1;

    for (int i = 0; i < deck.length; i++) {
      if (deck[i].toString() == dict.toString()) {
        indexToDelete = i;
        break;
      }
    }

    if (indexToDelete != -1) {
      // Dictionary found, delete it
      deck.removeAt(indexToDelete);

      // Save the updated deck to shared preferences
      List<String> encodedUpdatedDeck = [];

      for (Map<String, dynamic> deckDict in deck) {
        String encodedDict = json.encode(deckDict);
        encodedUpdatedDeck.add(encodedDict);
      }

      await prefs.setStringList(listName, encodedUpdatedDeck);
      return true;
    } else {
      // Dictionary doesn't exist in the deck
      return false;
    }
  }

  static Future<bool> allSolved(String listName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the SharedPreferences entry with the listName exists
    if (!prefs.containsKey(listName)) {
      return false; // The deck doesn't exist, so nothing to update
    }

    // Retrieve the existing deck from shared preferences
    List<String>? encodedDeck = prefs.getStringList(listName);
    List<Map<String, dynamic>> deck = [];

    // Copy to List
    if (encodedDeck != null) {
      for (String encodedDict in encodedDeck) {
        Map<String, dynamic> decodedDict = json.decode(encodedDict);
        deck.add(decodedDict);
      }
    }

    // Find and update the card in the deck
    for (int i = 0; i < deck.length; i++) {
      if (deck[i]["toLearn"] == true){
        return false;
      }
    }

    return true;
  }

  static Future<void> updateCardInDeck(String listName, Map<String, dynamic> oldCard, Map<String, dynamic> newCard) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the SharedPreferences entry with the listName exists
    if (!prefs.containsKey(listName)) {
      return; // The deck doesn't exist, so nothing to update
    }

    // Retrieve the existing deck from shared preferences
    List<String>? encodedDeck = prefs.getStringList(listName);
    List<Map<String, dynamic>> deck = [];

    // Copy to List
    if (encodedDeck != null) {
      for (String encodedDict in encodedDeck) {
        Map<String, dynamic> decodedDict = json.decode(encodedDict);
        deck.add(decodedDict);
      }
    }

    // Find and update the card in the deck
    for (int i = 0; i < deck.length; i++) {
      debugPrint("check: ${deck[i].toString()} ${oldCard.toString()}");
      if (deck[i].toString() == oldCard["translation"].toString() || deck[i]["translation"].toString() == oldCard["translation"].toString()) {
        debugPrint("match");
        deck[i] = newCard; // Update the card3
        break;
      }
    }
    debugPrint("oldCard $oldCard");
    debugPrint("newCard $newCard");
    debugPrint("updateCardInDeck $deck");

    // Save the updated deck to shared preferences
    List<String> encodedUpdatedDeck = deck.map((deckDict) => json.encode(deckDict)).toList();

    await prefs.setStringList(listName, encodedUpdatedDeck);
  }


  static Future<List<Map<String, dynamic>>> fetchLocalDeck(
      String listName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the existing deck from shared preferences
    List<String>? encodedDeck = prefs.getStringList(listName);
    List<Map<String, dynamic>> deck = [];

    // Copy to List
    if (encodedDeck != null) {
      for (String encodedDict in encodedDeck) {
        Map<String, dynamic> decodedDict = json.decode(encodedDict);
        deck.add(decodedDict);
      }
      return deck;
    } else {
      return deck; // Return null if the list doesn't exist
    }
  }

  static Future<Map<String, dynamic>> createMapListMapLocalDecks(
      String specificDeck) async {
    Map<String, dynamic> localDecks = {};
    // local
    List<String> allDecks = [];
    if (specificDeck == "") {
      allDecks = await LocalStorageService.getDeckNames();
    } else {
      allDecks = [specificDeck];
    }
    for (String deck in allDecks) {
      //debugPrint("the deck doesnt work $deck");
      List<Map<String, dynamic>> fetchedLocalDeck =
          await LocalStorageService.fetchLocalDeck(deck);

      List<Map<String, dynamic>> cardListOneDeck = [];
      debugPrint("fetchedLocalDeck: $fetchedLocalDeck");
      for (Map<String, dynamic> card in fetchedLocalDeck) {
        cardListOneDeck.add(cardWithToLearn(card));
      }
      localDecks[deck] = cardListOneDeck;
    }
    // example: localDecks {Deckel : [{: {Gruppe : grupo}}, {translation: {oktupus: pulpo}}], Haben : [],}
    return localDecks;
  }

  static Map<String, dynamic> cardWithToLearn(Map<String, dynamic> card) {
    Map<String, dynamic> newCard = {};

    // copy values in newCard
    card.forEach((key, value) {
      if (key != "toLearn") {
        // is translation already saved under practice-deck?
        if (key == "translation" && value is Map<String, dynamic>) {
          // Copy the "translation" key along with its map value to the new card
          newCard["translation"] = Map.from(value);
        }else {
          // add the translation, occurs the first time practice deck is opened
          newCard["translation"] = {key: value};
        }
      }
      /*old: {translation: {dismiss: zurückweisen}, toLearn: false}
        new: {translation: {translation: {dismiss: zurückweisen}}, toLearn: false}*/
      if (key == "toLearn") {
        newCard["toLearn"] = value;
      }
    });
    // if toLearn not available yet, add it
    if (!newCard.containsKey("toLearn")) {
      newCard["toLearn"] = true;
    }
    return newCard;
  }

  static Future<bool> checkDeckIsEmpty(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the SharedPreferences entry with the deckName exists
    if (prefs.containsKey(deckName)) {
      List<String>? encodedDeck = prefs.getStringList(deckName);

      // Check if the deck is empty (contains no items)
      return encodedDeck == null || encodedDeck.isEmpty;
    }

    // Deck doesn't exist, so it's considered empty
    return true;
  }

  static Future<void> setPracticeCardsToLearnTrue(String deckName) async {
    List<Map<String, dynamic>> fetchedLocalDeck =
    await LocalStorageService.fetchLocalDeck(deckName);

    // Iterate through the list and set 'toLearn' to false for all maps
    for (int i = 0; i < fetchedLocalDeck.length; i++) {
      print("setToTrue ${fetchedLocalDeck[i]["toLearn"]}");
      fetchedLocalDeck[i]["toLearn"] = true;
      print("setToTrue new ${fetchedLocalDeck[i]["toLearn"]}");
    }

    // Save the JSON string to SharedPreferences under the deckName instance
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> encodedUpdatedDeck = fetchedLocalDeck.map((deckDict) => json.encode(deckDict)).toList();

    await prefs.setStringList(deckName, encodedUpdatedDeck);
  }
}
