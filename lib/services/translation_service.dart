import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flashlate/api_key.dart';

class TranslationService {
  final String apiKey = ApiKey.googleTranslateApiKey;
  Map<String, String> languageMap = {
    "Deutsch": "de",
    "English": "en",
    "Español": "es",
    "Français" : "fr",
    "Polski" : "pl",
    "Português" : "pt",
  };

  Future<String> translateText(String source, String target, String text) async {
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2');

    final sourceCode = languageMap[source]!;
    final targetCode = languageMap[target]!;
    final response = await http.post(url, body: {
      'key': apiKey,
      'q': text,
      'source': sourceCode, // Source language code
      'target': targetCode, // Target language code
    });

    final data = json.decode(response.body);
    debugPrint("other translations ${data}");
    return data['data']['translations'][0]['translatedText'];
  }

}
