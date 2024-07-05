import 'package:flutter/material.dart';
import '../models/core/conjugation/conjugation_result.dart';
import '../services/database/conjugations.dart';
import '../services/lang_local_storage_service.dart';
import '../services/local_storage_service.dart';
import '../services/translation_service.dart';
import '../utils/supported_languages.dart';

class TranslationHelper {
  final TranslationService translationService = TranslationService();
  final LocalStorageService localStorageService = LocalStorageService();

  Future<void> loadDropdownLangValuesFromPreferences(
      Function(String, String) updateLangs) async {
    String? currentSourceLang =
        await LangLocalStorageService.getLanguage("source");

    debugPrint("translation helper: currentSourceLang: $currentSourceLang");

    if (currentSourceLang == null) {
      debugPrint("currentSourceLang is null");
      currentSourceLang = SupportedLanguages.translationLanguages[0];
      await LangLocalStorageService.setLanguage(
          "source", SupportedLanguages.translationLanguages[1]);
    }
    String? currentTargetLang =
        await LangLocalStorageService.getLanguage("target");
    if (currentTargetLang == null) {
      currentTargetLang = SupportedLanguages.translationLanguages[1];
      await LangLocalStorageService.setLanguage(
          "target", SupportedLanguages.translationLanguages[0]);
    }

    updateLangs(currentSourceLang, currentTargetLang);
  }

  Future<void> getDeckNames(
      Function(String, List<String>) updateDecks) async {
    String currentDeck = await LocalStorageService.getCurrentDeck ();
    List<String> fetchedItems = await LocalStorageService.getDeckNames();

    if (!fetchedItems.contains(currentDeck)) {
      await LocalStorageService.addDeck(currentDeck, true);
      fetchedItems = await LocalStorageService.getDeckNames();
    }

    updateDecks(currentDeck, fetchedItems);
  }

  Future<void> translateSourceText(String sourceLang, String targetLang,
      String textToTranslate, Function(String) updateTranslatedText) async {
    final translation = await translationService.translateText(
        sourceLang, targetLang, textToTranslate);
    updateTranslatedText(translation);
  }

  Future<void> translateTargetText(String sourceLang, String targetLang,
      String textToTranslate, Function(String) updateTranslatedText) async {
    final translation = await translationService.translateText(
         sourceLang, targetLang, textToTranslate);

    updateTranslatedText(translation);
  }

  Future<void> speakTextWrapper(String text, String lang) async {
    await translationService.speakText(text, lang);
  }

  Future<void> speakText(TextEditingController textEditingController,
      String currentLanguage) async {
    await translationService.speakText(
        textEditingController.text, currentLanguage);
  }

  void checkConjugations(String translatedText, String targetLang,
      Function(ConjugationResult?) updateConjugationResult) async {
    ConjugationResult? conjugationResult =
        await Conjugations.fetchConjugations(translatedText, targetLang);
    updateConjugationResult(conjugationResult);
  }
}
