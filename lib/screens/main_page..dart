import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fk_toggle/fk_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flashlate/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/top_bar_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TranslationService translationService = TranslationService();

  String originalText = '';
  String translatedText = '';
  TextEditingController bottomTextEditingController = TextEditingController();
  TextEditingController topTextEditingController = TextEditingController();
  bool editingMode = false;

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

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                  ? Column(
                    children: [
                      const SizedBox(height: 12),
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
                              onSelected: selected),
                          ElevatedButton.icon(
                            onPressed: () {
                              _addToStorage(originalText, translatedText);
                              // Your onPressed function here
                            },
                            icon: const Icon(Icons.add, color: Colors.white), // Set the icon color
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
                  : const TopBarWidget(),


              // Second Box

              Container(
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(

                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 2, // Spread radius
                      blurRadius: 5, // Blur radius
                      offset: Offset(0, 3), // Shadow offset
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 2, // Spread radius
                      blurRadius: 5, // Blur radius
                      offset: Offset(0, 3), // Shadow offset
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
                    ],
                  ),
                ),
              ),

              Container(
                decoration: const BoxDecoration(
                  color: Colors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () async {
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    await auth.signOut();
                  },
                  icon: const Icon(
                    Icons.auto_fix_high,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
