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

  static Future<bool> addCardToLocalDeck(String listName, Map<String, dynamic> dict) async {
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
      return card.toString() == dict.toString(); // You may want to compare more selectively.
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
    }else {
      // dict already exist -> saving returns false
      return false;
    }
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

  static Future<Map<String, dynamic>> createMapListMapLocalDecks() async {
    Map<String, dynamic> localDecks = {};
    // local
    List<String> allDecks = await LocalStorageService.getDeckNames();
    for (String deck in allDecks) {
      List<Map<String, dynamic>> fetchedLocalDeck =
          await LocalStorageService.fetchLocalDeck(deck);
      List<Map<String, dynamic>> cardListOneDeck = [];
      for (Map<String, dynamic> card in fetchedLocalDeck) {
        cardListOneDeck.add({
          "translation": {card.keys.first: card.values.first}
        });
      }
      localDecks[deck] = cardListOneDeck;
    }

    debugPrint("localDecks $localDecks");
    // example: localDecks {Deckel : [{translation: {Gruppe : grupo}}, {translation: {oktupus: pulpo}}], Haben : [],}
    return localDecks;
  }
}
