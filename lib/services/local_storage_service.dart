import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {

  static const String _currentDeckKey = 'currentDeck';

  static Future<void> setCurrentDeck(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentDeckKey, deckName);
  }

  static Future<String?> getCurrentDeck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentDeckKey);
  }

  Future<void> addDeck(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the existing deck names from shared preferences
    List<String>? encodedDeck = prefs.getStringList("decks");

    if (encodedDeck == null) {
      // If the list is null, initialize it with the current deckName
      encodedDeck = [deckName];
    } else {
      // Check if the deckName already exists in the list
      if (encodedDeck.contains(deckName)) {
        // If it exists, find an available number to append
        int number = 1;
        String newDeckName = '$deckName ($number)';
        while (encodedDeck.contains(newDeckName)) {
          number++;
          newDeckName = '$deckName ($number)';
        }
        encodedDeck.add(newDeckName);
      } else {
        // If it doesn't exist, add the deckName to the list
        encodedDeck.add(deckName);
      }
    }

    // Save the updated list back to shared preferences
    await prefs.setStringList("decks", encodedDeck);
  }

  Future<String?> getLastAddedDeck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the existing deck names from shared preferences
    List<String>? encodedDeck = prefs.getStringList("decks");

    if (encodedDeck == null || encodedDeck.isEmpty) {
      return null; // No decks in the list
    }

    // Return the last added deck (last element of the list)
    return encodedDeck.last;
  }


  Future<void> addToDeck(String listName, Map<String, dynamic> dict) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the existing deck from shared preferences
    List<String>? encodedDeck = prefs.getStringList(listName);
    List<Map<String, dynamic>> deck = [];

    if (encodedDeck != null) {
      for (String encodedDict in encodedDeck) {
        Map<String, dynamic> decodedDict = json.decode(encodedDict);
        deck.add(decodedDict);
      }
    }

    // Add the new dictionary to the deck
    deck.add(dict);

    // Save the updated deck to shared preferences
    List<String> encodedUpdatedDeck = [];

    for (Map<String, dynamic> deckDict in deck) {
      debugPrint("hinzugefügt $deckDict");
      String encodedDict = json.encode(deckDict);
      encodedUpdatedDeck.add(encodedDict);
    }

    await prefs.setStringList(listName, encodedUpdatedDeck);
  }

  Future<List<Map<String, dynamic>>> fetchDeck(String listName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the encoded deck from shared preferences
    List<String>? encodedDeck = prefs.getStringList(listName);
    List<Map<String, dynamic>> deck = [];

    if (encodedDeck != null) {
      for (String encodedDict in encodedDeck) {
        Map<String, dynamic> decodedDict = json.decode(encodedDict);
        deck.add(decodedDict);
      }
    }

    return deck;
  }
}
