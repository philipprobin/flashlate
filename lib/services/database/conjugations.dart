import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashlate/utils/supported_languages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../models/core/conjugation/conjugation_result.dart';
import '../cloud_function_service.dart';

class Conjugations {

  static get languageMap => SupportedLanguages.languageMap;

  static Map<String, List<String>> verbSuffixes = {
    "es": ['ar', 'er', 'ir'],
    "de": ['en'],
  };

  static void uploadGptTranslation(String sourceLang, String targetLang,
      String verb, String shortenedGptTranslation) {
    String countryCodeTarget = languageMap[targetLang]!;
    String countryCodeSource = languageMap[sourceLang]!;
    String? countryCodeCapTarget = countryCodeTarget.toUpperCase();
    // Initialize Firebase with your service account credentials
    debugPrint(
        "verb --$verb, gptTranslation --$shortenedGptTranslation, lang --$targetLang");
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('verbs$countryCodeCapTarget');

    final DocumentReference docRef = collectionRef.doc(verb);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }

      Map<String, dynamic> gptTranslation =
          (snapshot.data() as Map<String, dynamic>)
                  .containsKey('gptTranslation')
              ? (snapshot.get('gptTranslation') as Map<String, dynamic>)
              : {};

      // Check if the countryCode already exists
      if (!gptTranslation.containsKey(countryCodeSource)) {
        // Update the map with the new translation
        gptTranslation[countryCodeSource] = shortenedGptTranslation;

        // Update the document
        transaction.update(docRef, {'gptTranslation': gptTranslation});
      }
    }).then((result) {
      print("Transaction completed");
    }).catchError((error) {
      print("Failed to update: $error");
    });
  }

  static void addVerbToDB(String verb, Map verbConjugations) {
    final CollectionReference verbsCollection =
        FirebaseFirestore.instance.collection('esVerbs');

    // Create a document reference for the verb in the Firestore collection.
    final DocumentReference verbDocRef = verbsCollection.doc(verb);

    // Upload the verb conjugations map to Firestore.
    verbDocRef.set({
      'conjugations': verbConjugations,
    }).then((_) {
      print('Verb data added to Firestore for $verb');
    }).catchError((error) {
      print('Error uploading data: $error');
    });
  }

  static Future<Map<String, dynamic>?> queryConjugation(
      String conjToFind, String lang) async {
    // input lang must be supported
    String countryCode = languageMap[lang]!;
    String? countryCodeCap = countryCode.toUpperCase();
    // Initialize Firebase with your service account credentials
    debugPrint("conjToFind --$conjToFind--");

    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('verbs$countryCodeCap');

    final List<String> filterList =
        await generateFilters(conjToFind, countryCode);

    debugPrint("filterList --$filterList--");
    // Search by filters
    for (final filterString in filterList) {
      final querySnapshot =
          await collectionRef.where(filterString, isEqualTo: conjToFind).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        debugPrint("data --$data--");
        return {
          "infinitive": doc.id,
          "path": filterString,
          "input": conjToFind,
          "conjugations": data,
        };
      }
    }

    // Look for infinitive
    List<String>? suffixes = [];
    if (verbSuffixes.containsKey(countryCode)) {
      suffixes = verbSuffixes[countryCode];
    }

    for (final suffix in suffixes!) {
      if (conjToFind.endsWith(suffix)) {
        final doc = await collectionRef.doc(conjToFind).get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          return {
            "infinitive": doc.id,
            "input": conjToFind,
            "conjugations": data,
          };
        }
      }
    }

    return null;
  }

  static Future<ConjugationResult?> fetchConjugations(String translatedText, String language) async {
    final result = await CloudFunctionService.fetchFrenchConjugations(
        translatedText, language);

    if (result != null && result.containsKey('lemmas') &&
        result['lemmas'].isNotEmpty) {
      String lastInfinitive = result['lemmas'].last;
      print("Last infinitive: $lastInfinitive");
      Map<String, dynamic>? data = await queryConjugations(
          lastInfinitive, language);
      if (data != null) {
        ConjugationResult conjugationResult = ConjugationResult.fromJson(data);
        return conjugationResult;
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>?> queryConjugations(String infinitive, String lang) async {
    String countryCode = languageMap[lang]!;
    String countryCodeCap = countryCode.toUpperCase();
    // Initialize Firebase with your service account credentials
    debugPrint("path: ${'verbs$countryCodeCap'}/$infinitive");

    final CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('verbs$countryCodeCap');

    try {
      DocumentSnapshot doc = await collectionRef.doc(infinitive).get(); // Use await to wait for the document to be fetched
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "infinitive": doc.id,
          "data": data,
        };
      } else {
        debugPrint('No document found for $infinitive in verbs$countryCodeCap.');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return null;
    }
  }

  static Future<List<String>> generateFilters(
      String conjToFind, String countryCode) async {
    var filters = <String>[];
    Map<String, dynamic> grammaticalRules = await loadJsonFile(
        "assets/grammar_rules/grammatical_rules_$countryCode.json");

    grammaticalRules.forEach((key, value) {
      if (conjToFind.endsWith(key)) {
        if (value is List<dynamic>) {
          filters.addAll(value.map((item) => item.toString()));
        }
      }
    });

    return filters;
  }

  static Future<Map<String, dynamic>> loadJsonFile(String assetPath) async {
    try {
      final String jsonContent = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonContent);
      return jsonData;
    } catch (e) {
      print('Error loading JSON file: $e');
      return {};
    }
  }
}
