import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flashlate/api_key.dart';

import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';

class TranslationService {
  final String apiKey = ApiKey.googleTranslateApiKey;

  FlutterTts flutterTts = FlutterTts();

  String lastSpokenText = "";

  Map<String, String> languageMap = {
    "Deutsch": "de",
    "English": "en",
    "Español": "es",
    "Français" : "fr",
    "Polski" : "pl",
    "Português" : "pt",
    "Italiano" : "it"
  };

  // text to speech
  Map<String, String> ttsMap = {
    "Deutsch": "de-DE",
    "English": "en-US",
    "Español": "es-US",
    "Français" : "fr-FR",
    "Polski" : "pl-PL",
    "Português" : "pt-BR",
    "Italiano" : "it-IT"
  };

  Future<String> translateText(String source, String target, String text) async {
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2');

    final sourceCode = languageMap[source]!;
    final targetCode = languageMap[target]!;

    if (sourceCode == targetCode) {
      debugPrint("Error translating text, same lang: $sourceCode, $targetCode");
      return text;
    }


    final response = await http.post(url, body: {
      'key': apiKey,
      'q': text,
      'source': sourceCode, // Source language code
      'target': targetCode, // Target language code
    });

    final data = json.decode(response.body);

    // Extract the translated text
    String translatedText = data['data']['translations'][0]['translatedText'];

    debugPrint("SOURCE $sourceCode: $text - TARGET $targetCode: $translatedText");

    // Decode HTML entities
    var document = parse(translatedText);
    String? decodedText = dom.DocumentFragment.html(document.body?.text ?? '').text;

    debugPrint("decodedText translations ${decodedText}");
    return decodedText?? "fail";
  }


  Future<void> speakText(String text, String target) async {
    debugPrint("speakText $text");
    final langCode = ttsMap[target]!;

    try {
      double speechRate = 0.5;
      if (lastSpokenText == text) {
        speechRate = 0.2;
      }
        await flutterTts.setSpeechRate(speechRate);
        await flutterTts.setLanguage(langCode);
        await flutterTts.speak(text);

        lastSpokenText = text;
    } catch (e) {
      print('Error calling flutterTts: $e');
    }
  }

}
