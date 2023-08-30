import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fk_toggle/fk_toggle.dart';
import 'package:flashlate/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flashlate/services/translation_service.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_app_bar_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TranslationService translationService = TranslationService();

  String originalText = '';
  String translatedText = '';
  bool uploadSuccess = false;

  TextEditingController bottomTextEditingController = TextEditingController();
  TextEditingController topTextEditingController = TextEditingController();
  bool editingMode = false;
  LocalStorageService localStorageService = LocalStorageService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  List<Map<String, String>> storedData = [];

  void _addToStorage(String originalText, String translatedText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing data
    String? jsonData = prefs.getString('data');
    Map<String, String> dataMap = {}; // Create an empty map

    if (jsonData != null) {
      dataMap = Map<String, String>.from(json.decode(jsonData));
    }

    // Add new translation
    dataMap[originalText] = translatedText;

    debugPrint("saved: $originalText : $translatedText");

    // Encode the updated map to JSON
    String updatedJsonData = json.encode(dataMap);

    // Save updated data
    prefs.setString('data', updatedJsonData);
  }

  Future<void> translateDeEsText() async {
    final translation =
        await translationService.translateDeEsText(originalText);
    setState(() {
      translatedText = translation;
      bottomTextEditingController.text = translatedText;
      debugPrint('Translated Text: $translatedText');
    });
  }

  Future<void> translateEsDeText() async {
    final translation =
        await translationService.translateEsDeText(originalText);
    setState(() {
      translatedText = translation;
      topTextEditingController.text = translatedText;
      debugPrint('Translated Text: $translatedText');
    });
  }

  @override
  Widget build(BuildContext context) {
    final OnSelected selected = ((index, instance) {
      debugPrint('Select $index, toggle ${instance.labels[index]}');
      editingMode = (index == 0);
    });

    return KeyboardVisibilityBuilder(builder: (context, visible) {
      return Scaffold(
        appBar: CustomAppBarWidget(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                (visible)
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FkToggle(
                                width: 60,
                                height: 40,
                                icons: const [
                                  Icon(Icons.edit),
                                  Icon(Icons.compare_arrows),
                                ],
                                labels: const ['', ''],
                                onSelected: selected,
                                enabledElementColor:
                                    Theme.of(context).primaryColor,
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor, // Set the background color here
                                ),
                                onPressed: () async {
                                  final databaseService = DatabaseService();
                                  String deckName = await LocalStorageService.getCurrentDeck()?? await localStorageService.getLastAddedDeck()?? "Deck";
                                  //String deckName = await localStorageService.getLastAddedDeck()?? "Deck";
                                  bool response = await databaseService.addCard(
                                      deckName,
                                      originalText,
                                      translatedText);
                                  if (!response) {
                                    debugPrint('upload failed');
                                  } else {
                                    setState(() {
                                      uploadSuccess = true;
                                    });
                                    Future.delayed(const Duration(seconds: 1),
                                        () {
                                      setState(() {
                                        uploadSuccess = false;
                                      });
                                    });
                                  }
                                  //_addToStorage(originalText, translatedText);
                                  //Map<String, dynamic> myDict = {originalText: translatedText, };

                                  /*String deckName = "deck1";
                                final deckManager1 = DeckManagerService(deckName);
                                await deckManager1.addToDeck(deckName, {originalText: translatedText});
                                */
                                  //await localStorageService.addToDeck('deck1', myDict);
                                  // Your onPressed function here
                                },
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                // Set the icon color

                                label: const Text(
                                  'hinzufügen',
                                  style: TextStyle(
                                    color: Colors.white, // Set the text color
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      )
                    : Container(),

                // Second Box

                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: uploadSuccess
                            ? Theme.of(context).primaryColor
                            : Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        const Text(
                          "Deutsch",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: TextFormField(
                              maxLines: 4,
                              onChanged: (value) {
                                if (!editingMode) {
                                  setState(() {
                                    originalText = value;
                                    translateDeEsText();
                                  });
                                }
                              },
                              textAlign: TextAlign.center,
                              // Center horizontally
                              textAlignVertical: TextAlignVertical.center,
                              controller: topTextEditingController,
                              decoration: const InputDecoration.collapsed(
                                hintText: 'Text eingeben',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10, // Adjust the top position as needed
                          right: 10, // Adjust the right position as needed
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                topTextEditingController.text =
                                    ''; // Clear the text
                              });
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              child: const Icon(
                                Icons.clear,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: uploadSuccess
                            ? Theme.of(context).primaryColor
                            : Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        const Text(
                          "Spanisch",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: TextFormField(
                              maxLines: 4,
                              onChanged: (value) {
                                if (!editingMode) {
                                  setState(() {
                                    originalText = value;
                                    translateEsDeText();
                                  });
                                }
                              },
                              textAlign: TextAlign.center,
                              // Center horizontally
                              textAlignVertical: TextAlignVertical.center,
                              controller: bottomTextEditingController,
                              decoration: const InputDecoration.collapsed(
                                hintText: 'Text eingeben',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10, // Adjust the top position as needed
                          right: 10, // Adjust the right position as needed
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                bottomTextEditingController.text =
                                    ''; // Clear the text
                              });
                            },
                            child: const SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.clear,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
