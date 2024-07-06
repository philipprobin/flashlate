import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../helpers/language_preferences.dart';
import 'database/conjugations.dart';

class CloudFunctionService {
  static LanguagePreferences languagePreferences = LanguagePreferences();


  static Future<String> get_gpt_translations(
      String verb) async {

    final sourceLang = await languagePreferences.sourceLanguage;
    final targetLang = await languagePreferences.targetLanguage;
    const parameterlessUrl =
        "https://us-central1-flashlate-397020.cloudfunctions.net/gpt_translate_function?verb=";
    final url =
        Uri.parse("$parameterlessUrl$verb&sourceLang=$sourceLang");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Successful response with a status code of 200.
      final String responseBody = response.body;
      // Handle the response data here.
      String shortenedGptTranslation = extractStringUntil5thComma(responseBody);
      debugPrint("get_gpt_translation - verb $verb");
      Conjugations.uploadGptTranslation(sourceLang, targetLang, verb, shortenedGptTranslation);
      return shortenedGptTranslation;
    } else {
      // Handle the error if the response has a different status code.
      print('Request failed with status: ${response.statusCode}');
      return "";
    }
  }

  static String extractStringUntil5thComma(String input) {
    List<String> parts = input.split(',');
    if (parts.length <= 5) {
      return input;
    } else {
      return parts.sublist(0, 5).join(',');
    }
  }

  // not in use, switch to firebase call Database.queryConjugation
  static Future<Map<String, dynamic>?> fetchSpanishConjugations(
      String verb, String currentSourceValueLang) async {
    const parameterlessUrl =
        "https://us-central1-flashlate-397020.cloudfunctions.net/check_is_spanish_verb?verb=";
    final url =
        Uri.parse("$parameterlessUrl$verb&sourceLang=$currentSourceValueLang");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Convert the response to UTF-8
        final utf8Response = utf8.decode(response.bodyBytes);

        // Parse the JSON
        final jsonResult = json.decode(utf8Response);

        // Save the JSON to a file (optional)
        // You can use the `path_provider` package to manage file I/O.

        // Print the JSON result
        print("jsonresult $jsonResult");
        return jsonResult;
      } else {
        // Handle HTTP error
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchFrenchConjugations(String verb, String language) async {
    const endpointUrl = "https://us-central1-flashlate-397020.cloudfunctions.net/spacyVerbRecognizer";

    final url = Uri.parse("$endpointUrl?verb=$verb&lang=$language");
    final headers = {"Content-Type": "application/json"};

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        // Convert the response to UTF-8
        final utf8Response = utf8.decode(response.bodyBytes);

        // Parse the JSON
        final jsonResult = json.decode(utf8Response);

        // Print the JSON result
        print("jsonresult $jsonResult");
        return jsonResult;
      } else {
        // Handle HTTP error
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
      return null;
    }
  }



}
void main() async {
  String translatedText = "gehen"; // Example verb to fetch conjugations for
  final result = await CloudFunctionService.fetchFrenchConjugations(
      translatedText, "Deutsch");

  if (result != null && result.containsKey('lemmas') &&
      result['lemmas'].isNotEmpty) {
    String lastInfinitive = result['lemmas'].last;
    print("Last infinitive: $lastInfinitive");
  } else {
    print("No lemmas found or error occurred.");
  }
}