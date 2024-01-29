import 'package:flashlate/services/database/personal_decks.dart';
import 'package:flutter/cupertino.dart';

import 'local_storage_service.dart';

class SynchronizeService {

  static Future<void> writeDbToLocal() async {
    try{
      Map<String, dynamic> userData = await PersonalDecks.fetchUserDoc();
      List<String> deckNames = await LocalStorageService.getDeckNames();

      userData.forEach((deckName, cards) {
        // add local deckname if doesnt exist
        if (!deckNames.contains(deckName)) {
          LocalStorageService.addDeck(deckName, false);
        }
        for (Map<String, dynamic> card in cards) {
          // retreive server map: translation
          Map<String, dynamic> translation = card['translation'];
          // add local, if already existing skips automatically
          LocalStorageService.addCardToLocalDeck(deckName, translation);
        }
      });
    }
    catch (e) {
      debugPrint('Google sync Error: $e');
    }
  }
}
