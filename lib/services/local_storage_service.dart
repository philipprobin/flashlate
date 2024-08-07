import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'lang_local_storage_service.dart';

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
        await deleteAllDeckRefs(deckName);
        List<String> allDeckNames = await LocalStorageService.getDeckNames();
        LocalStorageService.setCurrentDeck(allDeckNames[0]);
        return;
      }
    }
    await deleteAllDeckRefs(deckName);
  }

  static Future<void> deleteAllDeckRefs(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // remove all Cards
    await prefs.remove(deckName);
    // remove review deck if exists
    await prefs.remove("rEvIeWdEcK-$deckName");
    // remove review mode if exists
    await prefs.remove("rEvIeWmOde-$deckName");
    // remove index deck if exists
    await prefs.remove("iNdEx-$deckName");
    // remove practice deck if exists
    await prefs.remove("pRaCtIcEmOde-$deckName");

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

  static Future<void> deleteCardFromLocalDecks(
      String deckName, Map<String, dynamic> dict) async {


    List<String> listsToDelete = [deckName, "pRaCtIcEmOde-$deckName","rEvIeWDeCk-$deckName"];

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int currentIndex = await LocalStorageService.getIndex("iNdEx-$deckName");
    bool isReviewMode = await LocalStorageService.getReviewMode("rEvIeWmOde-$deckName");

    for(String listName in listsToDelete){
      // Check if the SharedPreferences entry with the listName exists
      if (!prefs.containsKey(listName)) {
        continue; // The deck doesn't exist, so nothing to delete
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
        // debugPrint("Modus: $listName ${deck[i].toString()} == ${dict.toString()} || ${deck[i]["translation"].toString()} == ${dict.toString()}");
        if (deck[i].toString() == dict.toString() || deck[i]["translation"].toString() == dict.toString()) {
          indexToDelete = i;
          debugPrint("word deleted in mode $listName");
          break;
        }
      }

      // check if which index in which mode (review or not) change index if indexToDelete is <= current index
      // what happens if card is at last place or only card

      // reset current index for practice page
      if (listName.contains("rEvIeWDeCk") && isReviewMode ) {
        if (indexToDelete  <= currentIndex){
          //what happends if only one in deck?
          await LocalStorageService.setIndex("iNdEx-$deckName", currentIndex-1 );
        }
      }
      if (listName.contains("pRaCtIcEmOde") && !isReviewMode ) {
        if (indexToDelete  <= currentIndex){
          //what happends if only one in deck?
          await LocalStorageService.setIndex("iNdEx-$deckName", currentIndex-1 );
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
      } else {
        // Dictionary doesn't exist in the deck
        debugPrint("card to delete doesnt exit");
      }
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
      if (deck[i]["toLearn"] == true) {
        return false;
      }
    }

    return true;
  }

  static Future<void> updateCardInDeck(String listName,
      Map<String, dynamic> oldCard, Map<String, dynamic> newCard) async {
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
      if (deck[i].toString() == oldCard["translation"].toString() ||
          deck[i]["translation"].toString() ==
              oldCard["translation"].toString()) {
        debugPrint("match");
        deck[i] = newCard; // Update the card3
        break;
      }
    }
    debugPrint("oldCard $oldCard");
    debugPrint("newCard $newCard");
    debugPrint("updateCardInDeck $deck");

    // Save the updated deck to shared preferences
    List<String> encodedUpdatedDeck =
        deck.map((deckDict) => json.encode(deckDict)).toList();

    await prefs.setStringList(listName, encodedUpdatedDeck);
  }

  static Future<List<Map<String, dynamic>>> fetchLocalDeck(
      String listName) async {
    /// set review deck from practice deck, if review is true practice was called before
    /// practice should copy from current and add translate and toLearn
    /// create storage method that takes currentDeck, look for practiceDeck-Current deck:
    /// if available check for translate and toLearn:
    /// if form like [{amparado: geschützt}, {hassen: odiar}, {übermorgen: pasado mañana]] change it,
    /// if not available copy current to practice with translate and to learn and save it as new instance
    /// return the list of method createCardsDeck
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
        } else {
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

    List<String> encodedUpdatedDeck =
        fetchedLocalDeck.map((deckDict) => json.encode(deckDict)).toList();

    await prefs.setStringList(deckName, encodedUpdatedDeck);
  }

  static Future<bool> getReviewMode(String deckname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool reviewMode = prefs.getBool(deckname) ?? false;

    if (!prefs.containsKey(deckname)) {
      await prefs.setBool(deckname, false);
    }

    return reviewMode;
  }

  static Future<void> setReviewMode(String deckname, bool reviewMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(deckname, reviewMode);
  }

  static Future<int> getIndex(String deckname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt(deckname) ?? 0;

    if (!prefs.containsKey(deckname)) {
      await prefs.setInt(deckname, 0);
    }

    return index;
  }

  static Future<void> setIndex(String deckname, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(deckname, index);
  }

  static Future<List<Map<String, dynamic>>> copyDeck(
      String sourceListName, String targetListName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch the source deck
    List<Map<String, dynamic>> sourceDeck =
        await fetchLocalDeck(sourceListName);

    if (sourceDeck.isNotEmpty) {
      // Encode and save the source deck to the target list in SharedPreferences
      List<String> encodedDeck = sourceDeck.map((deckItem) {
        return json.encode(deckItem);
      }).toList();

      await prefs.setStringList(targetListName, encodedDeck);
    } else {
      // Handle the case when the source deck is empty or doesn't exist
      throw Exception("Source deck is empty or doesn't exist.");
    }

    // Return the copied deck (target deck)
    return fetchLocalDeck(targetListName);
  }

  static Future<void> deleteToLearnFalses(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch the source deck
    List<Map<String, dynamic>> deck = await fetchLocalDeck(deckName);

    deck.removeWhere((entry) => entry['toLearn'] == false);

    // Encode and save the filtered deck back to SharedPreferences
    List<String> updatedEncodedDeck = deck.map((entry) {
      return json.encode(entry);
    }).toList();

    await prefs.setStringList(deckName, updatedEncodedDeck);
  }

  static Future<List<Map<String, dynamic>>?> getPracticeDeck(String deckName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Define the keys for the original deck and practice mode deck.
    final String originalDeckKey = deckName;
    final String practiceModeDeckKey = 'pRaCtIcEmOde-$deckName';

    // Check if the practice mode deck already exists.
    bool practiceModeDeckExists = prefs.containsKey(practiceModeDeckKey);
    bool practiceDeckIsEmpty = await LocalStorageService.checkDeckIsEmpty(practiceModeDeckKey);
    // If it doesn't exist, create it by copying the original deck.
    if (!practiceModeDeckExists || practiceDeckIsEmpty) {
      // Retrieve the original deck from shared preferences.
      final List<String>? originalDeckJsonList = prefs.getStringList(originalDeckKey);

      if (originalDeckJsonList != null) {
        // Parse the original deck data from the list of JSON strings.
        final List<Map<String, dynamic>> originalDeckData = originalDeckJsonList
            .map((jsonString) => json.decode(jsonString) as Map<String, dynamic>)
            .toList();

        // Add the 'translation' and 'toLearn' keys to each entry in the practice mode deck.
        final List<Map<String, dynamic>> transformedPracticeModeDeck = originalDeckData
            .map((entry) => {
          'translation': entry,
          'toLearn': true,
        })
            .toList();

        // Store the transformed practice mode deck as a list of JSON strings.
        final List<String> practiceModeDeckJsonList = transformedPracticeModeDeck
            .map((data) => jsonEncode(data))
            .toList();
        await prefs.setStringList(practiceModeDeckKey, practiceModeDeckJsonList);
      } else {
        // Handle the case when the original deck doesn't exist.
        debugPrint("The original deck '$deckName' doesn't exist.");
      }
    }

    // Retrieve and return the practice mode deck as a list of maps.
    final List<String>? practiceModeDeckJsonList = prefs.getStringList(practiceModeDeckKey);
    if (practiceModeDeckJsonList != null) {
      final List<Map<String, dynamic>> practiceModeDeckData = practiceModeDeckJsonList
          .map((jsonString) => json.decode(jsonString) as Map<String, dynamic>)
          .toList();
      return practiceModeDeckData;
    } else {
      // Handle the case when the practice mode deck doesn't exist.
      debugPrint("The practice mode deck for '$deckName' doesn't exist.");
      return null;
    }
  }

  static Future<Map<String, String>> loadDropdownLangValuesFromPreferences(List<String> translationLanguages, bool setLanguages) async {

    String? currentSourceLang = await LangLocalStorageService.getLanguage("source");
    if (translationLanguages.isNotEmpty) {
      currentSourceLang = translationLanguages[0];
      if (setLanguages)
      await LangLocalStorageService.setLanguage("source", currentSourceLang);
    }

    String? currentTargetLang = await LangLocalStorageService.getLanguage("target");
    if (translationLanguages.length > 1) {
      currentTargetLang = translationLanguages[1];
      if(setLanguages)
      await LangLocalStorageService.setLanguage("target", currentTargetLang);
    }

    return {
      "sourceLang": currentSourceLang ?? translationLanguages[0],
      "targetLang": currentTargetLang ?? translationLanguages[1]
    };
  }




}

