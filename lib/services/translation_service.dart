import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flashlate/api_key.dart';

class TranslationService {
  final String apiKey = ApiKey.googleTranslateApiKey;

  Future<String> translateDeEsText(String text) async {
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2');
    final response = await http.post(url, body: {
      'key': apiKey,
      'q': text,
      'source': 'de', // Source language code
      'target': 'es', // Target language code
    });

    final data = json.decode(response.body);
    debugPrint("other translations ${data}");
    return data['data']['translations'][0]['translatedText'];
  }

  Future<String> translateEsDeText(String text) async {
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2');
    final response = await http.post(url, body: {
      'key': apiKey,
      'q': text,
      'source': 'es', // Source language code
      'target': 'de', // Target language code
    });

    final data = json.decode(response.body);
    return data['data']['translations'][0]['translatedText'];
  }
}
