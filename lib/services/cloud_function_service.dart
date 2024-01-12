import 'dart:convert';
import 'package:flashlate/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CloudFunctionService {
  static Future<String> get_gpt_translations(
      String verb, String currentSourceValueLang, String currentTargetValueLang) async {
    const parameterlessUrl =
        "https://us-central1-flashlate-397020.cloudfunctions.net/gpt_translate_function?verb=";
    final url =
        Uri.parse("$parameterlessUrl$verb&sourceLang=$currentSourceValueLang");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Successful response with a status code of 200.
      final String responseBody = response.body;
      // Handle the response data here.
      String shortenedGptTranslation = extractStringUntil5thComma(responseBody);
      debugPrint("get_gpt_translation - verb $verb");
      DatabaseService.uploadGptTranslation(currentSourceValueLang, currentTargetValueLang, verb, shortenedGptTranslation);
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
}
