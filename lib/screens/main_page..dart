import 'package:flashlate/screens/conjugation_page.dart';
import 'package:flashlate/services/cloud_function_service.dart';
import 'package:flashlate/services/database/personal_decks.dart';
import 'package:flashlate/services/lang_local_storage_service.dart';
import 'package:flashlate/utils/supported_languages.dart';
import 'package:flutter/material.dart';
import 'package:flashlate/services/translation_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../models/core/conjugation/conjugation_result.dart';
import '../services/database/conjugations.dart';
import '../services/local_storage_service.dart';
import '../widgets/current_deck_widget.dart';
import '../widgets/lang_drop_button_widget.dart';
import '../widgets/app_bar_main_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TranslationService translationService = TranslationService();

  String textToTranslate = '';
  String translatedText = '';
  bool uploadSuccess = false;

  static const double cornerRadius = 20.0;
  static const secondBoxColor = Color(0xFFf8f8f8);

  TextEditingController targetTextEditingController = TextEditingController();
  TextEditingController sourceTextEditingController = TextEditingController();
  bool editingMode = false;
  LocalStorageService localStorageService = LocalStorageService();

  List<Map<String, String>> storedData = [];
  List<String> dropdownItems = [];
  List<String> oldTargetWordList = [];
  List<Map<String, dynamic>> verbDictsInTargetText = [];

  String currentDropdownValue = "";
  String currentTargetValueLang = "Español";
  String currentSourceValueLang = "Deutsch";

  String originalVerb = "";

  ConjugationResult? conjugationResult;

  get translationLanguages => SupportedLanguages.translationLanguages;

  @override
  void initState() {
    super.initState();
    loadDropdownLangValuesFromPreferences();
    loadDropdownDeckItemsFromPreferences();
  }

  Future<void> _pasteFromClipboard(
      TextEditingController controller, String controllerType) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null) {
      setState(() {
        controller.text = clipboardData.text ?? '';
        if (controllerType == "source") {
          // Assuming you want to translate the source text after pasting
          textToTranslate = controller.text;
          if (textToTranslate.isNotEmpty) {
            // Call the relevant translation function based on your logic
            // For example, translating from source to target language
            translateSourceText(currentSourceValueLang, currentTargetValueLang);
          }
        }
        if (controllerType == "target") {
          textToTranslate = controller.text;
          if (textToTranslate.isNotEmpty) {
            debugPrint("_pasteFromClipboard: $translatedText");
            // Call the relevant translation function based on your logic
            // For example, translating from source to target language
            translateTargetText(currentTargetValueLang, currentSourceValueLang);
          }
        }
      });
    }
  }

  Future<void> refreshOnTogglePress(bool mode) async {
    setState(() {
      if (!mode) {
        debugPrint("translateMode: $translatedText");
        if (textToTranslate.isEmpty && translatedText.isNotEmpty) {
          translateTargetText(currentTargetValueLang, currentSourceValueLang);
        }
        if (textToTranslate.isNotEmpty && translatedText.isEmpty) {
          translateSourceText(currentSourceValueLang, currentTargetValueLang);
        }
      }
      editingMode = mode;
    });
  }

  void targetTextDeleted() {
    targetTextEditingController.text = '';
    translatedText = "";
    conjugationResult = null;
  }

  void sourceTextDeleted() {
    sourceTextEditingController.text = '';
    textToTranslate = "";
  }

  Future<void> loadDropdownLangValuesFromPreferences() async {
    String? currentSourceLang =
        await LangLocalStorageService.getLanguage("source");
    if (currentSourceLang == null) {
      currentSourceLang = translationLanguages[0];
      await LangLocalStorageService.setLanguage(
          "source", currentTargetValueLang); // like Español
    }
    String? currentTargetLang =
        await LangLocalStorageService.getLanguage("target");
    if (currentTargetLang == null) {
      currentTargetLang = translationLanguages[1];
      await LangLocalStorageService.setLanguage(
          "target", currentSourceValueLang); // like Español
    }

    setState(() {
      // Update the state with the fetched items
      currentTargetValueLang = currentTargetLang!;
      currentSourceValueLang = currentSourceLang!;
    });
  }

  Future<void> loadDropdownDeckItemsFromPreferences() async {
    // Fetch the items from local preferences (shared preferences)

    // creates new deck "Deck" if list empty
    String currentDeck = await LocalStorageService.getCurrentDeck();

    List<String> fetchedItems = await LocalStorageService.getDeckNames();
    debugPrint("currentDeck is : $currentDeck");

    if (!fetchedItems.contains(currentDeck)) {
      debugPrint("not contains :(");
      await LocalStorageService.addDeck(currentDeck, true);
      fetchedItems = await LocalStorageService.getDeckNames();
    }

    setState(() {
      // Update the state with the fetched items
      currentDropdownValue = currentDeck;
      dropdownItems = fetchedItems;
    });
  }

  Future<void> translateSourceText(String sourceLang, String targetLang) async {
    final translation = await translationService.translateText(
        sourceLang, targetLang, textToTranslate);
    if (currentTargetValueLang == "Español" ||
        currentTargetValueLang == "Deutsch" ||
        "Français" == currentTargetValueLang) {
      // input in source, translation is forwarded
      checkConjugations(translation);
    }
    setState(() {
      translatedText = translation;
      targetTextEditingController.text = translatedText;
    });
  }

  Future<void> speakText(
      TextEditingController textEditingController, currentLanguage) async {
    if (currentLanguage == currentSourceValueLang) {
      await translationService.speakText(
          textEditingController.text, currentLanguage);
    } else {
      await translationService.speakText(
          textEditingController.text, currentLanguage);
    }
  }

  List<String> findAndReplaceWords(List<String> currentTranslatedTextList) {
    List<String> newWords = [];

    for (String word in currentTranslatedTextList) {
      if (!oldTargetWordList.contains(word)) {
        newWords.add(word);
      }
    }

    // Replace oldTargetWordList with currentTranslatedTextList
    oldTargetWordList = List.from(currentTranslatedTextList);

    return newWords;
  }

  void checkConjugations(String translatedText) async {
    ConjugationResult? _conjugationResult =
        await Conjugations.fetchConjugations(
            translatedText, currentTargetValueLang);
    if (_conjugationResult != null) {
      setState(() {
        conjugationResult = _conjugationResult;
      });
    } else {
      setState(() {
        conjugationResult = null;
      });
    }
  }

  Future<void> translateTargetText(String sourceLang, String targetLang) async {
    if (currentTargetValueLang == "Français" ||
        currentTargetValueLang == "Español" ||
        currentTargetValueLang == "Deutsch") {
      checkConjugations(textToTranslate);
    }
    final translation = await translationService.translateText(
        sourceLang, targetLang, textToTranslate);
    setState(() {
      translatedText = translation;
      sourceTextEditingController.text = translatedText;
    });
  }

  @override
  Widget build(BuildContext context) {
    double factor = 0.40;
    double translateBoxHeight =
        MediaQuery.of(context).size.width * factor; // 40 -> 14, 42 -> 12
    double addBoxPadding = (1 - factor - 0.46) * 100;

    Color addBoxColor = Theme.of(context).primaryColor;

    return KeyboardVisibilityBuilder(builder: (context, visible) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBarWidget(
                isEditingMode: (value) async {
                  // This function will be called when the boolean value changes.
                  debugPrint('Boolean value isEditingMode changed: $value');
                  await refreshOnTogglePress(value);
                  // You can perform any action here based on the boolean value.
                },
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    // current deck dropdown
                    CurrentDeckWidget(
                      dropdownItems: dropdownItems,
                      currentDropdownValue: currentDropdownValue,
                      onDeckChanged: (newValue) {
                        setState(() {
                          currentDropdownValue = newValue;
                          // Additional logic if needed when the deck is changed
                        });
                      },
                    ),

                    // first container
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(cornerRadius),
                          // Adjust the radius as needed
                          topRight: Radius.circular(
                              cornerRadius), // Adjust the radius as needed
                        ),
                        color: secondBoxColor,
                      ), // Adjust the radius as needed
                      child: Container(
                        height: translateBoxHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(cornerRadius),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  // source box
                                  child: TextFormField(
                                    maxLines: 2,
                                    onChanged: (value) {
                                      if (!editingMode) {
                                        setState(() {
                                          textToTranslate = value;
                                          if (value.isEmpty) {
                                            translatedText = "";
                                          }
                                          translateSourceText(
                                              currentSourceValueLang,
                                              currentTargetValueLang);
                                        });
                                      } else {
                                        // just to update add card to deck button color if empty, bc of reload
                                        setState(() {});
                                      }
                                    },
                                    textAlign: TextAlign.center,
                                    // Center horizontally
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: sourceTextEditingController,
                                    decoration: const InputDecoration.collapsed(
                                      hintText: 'Enter text',
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24,
                                          color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 10,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  // To fit the column size to its children
                                  children: [
                                    // Clear button - Shown only if the text field is not empty
                                    if (sourceTextEditingController
                                        .text.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Colors.black45),
                                        onPressed: () {
                                          setState(() {
                                            if (editingMode) {
                                              sourceTextDeleted();
                                            } else {
                                              sourceTextDeleted();
                                              targetTextDeleted();
                                            }
                                          });
                                        },
                                      ),

                                    // Copy to clipboard or Paste button
                                    // Shown based on the text field content
                                    IconButton(
                                      icon: Icon(
                                          sourceTextEditingController
                                                  .text.isNotEmpty
                                              ? Icons.copy
                                              : Icons.content_paste,
                                          color: Colors.black45),
                                      onPressed: () {
                                        setState(() {
                                          if (sourceTextEditingController
                                              .text.isNotEmpty) {
                                            // Copy to clipboard
                                            Clipboard.setData(ClipboardData(
                                                    text:
                                                        sourceTextEditingController
                                                            .text))
                                                .then((_) {
                                              // Show SnackBar upon successful copy
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Copied to clipboard'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            });
                                          } else {
                                            // Paste from clipboard
                                            _pasteFromClipboard(
                                                sourceTextEditingController,
                                                "source");
                                          }
                                        });
                                      },
                                    ),
                                    if (sourceTextEditingController
                                        .text.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.volume_up,
                                            color: Colors.black45),
                                        onPressed: () {
                                          setState(() {
                                            speakText(
                                                sourceTextEditingController,
                                                currentSourceValueLang);
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  "Source",
                                  style: TextStyle(
                                    color: Color(0xFFbcbcbd),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                left: 15,
                                child: Container(
                                  color: Colors.white,
                                  child: LangDropButtonWidget(
                                    items: translationLanguages,
                                    value: currentSourceValueLang,
                                    onChanged: (String? newValue) {
                                      // Handle the selected value here
                                      setState(() {
                                        currentSourceValueLang = newValue!;
                                        LangLocalStorageService.setLanguage(
                                            "source", newValue);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //second box
                    Stack(
                      children: [
                        // Button container
                        Positioned(
                          top: MediaQuery.of(context).size.width * 0.32,
                          child: ElevatedButton(
                            onPressed: (sourceTextEditingController
                                        .text.isNotEmpty &&
                                    targetTextEditingController.text.isNotEmpty)
                                ? () async {
                                    // Your button's onPressed code here...
                                    final databaseService = PersonalDecks();
                                    // add deckName to deck list
                                    String deckName = await LocalStorageService
                                        .getCurrentDeck();
                                    // local
                                    // add card to card list
                                    String source = "";
                                    String target = "";

                                    source =
                                        sourceTextEditingController.text.trim();
                                    target =
                                        targetTextEditingController.text.trim();
                                    LocalStorageService.addCardToLocalDeck(
                                        deckName, {source: target});
                                    bool practiceDeckIsEmpty =
                                        await LocalStorageService
                                            .checkDeckIsEmpty(
                                                "pRaCtIcEmOde-$deckName");
                                    // only add if not empty -> if empty gets copied later
                                    if (!practiceDeckIsEmpty) {
                                      LocalStorageService.addCardToLocalDeck(
                                          "pRaCtIcEmOde-$deckName", {
                                        "translation": {source: target},
                                        "toLearn": true
                                      });
                                    }

                                    // upload
                                    bool response = await databaseService
                                        .addCard(deckName, source, target);
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
                                    targetTextEditingController.text = "";
                                    sourceTextEditingController.text = "";
                                  }
                                : null,
                            // Disable the button if translatedText is empty
                            style: ElevatedButton.styleFrom(
                              backgroundColor: addBoxColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(cornerRadius),
                                  bottomLeft: Radius.circular(cornerRadius),
                                ),
                              ),
                            ),
                            child: Container(
                              height: MediaQuery.of(context).size.width * 0.20,
                              width: MediaQuery.of(context).size.width - 64,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(cornerRadius),
                                  bottomRight: Radius.circular(cornerRadius),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                // Align content to the bottom
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.all(addBoxPadding),
                                      child: Text(
                                        "Add Card To Deck",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Second Container
                        Container(
                          height: translateBoxHeight,
                          decoration: const BoxDecoration(
                            color: secondBoxColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(cornerRadius),
                              bottomRight: Radius.circular(cornerRadius),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    "Target",
                                    style: TextStyle(
                                      color: Color(0xFFbcbcbd),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                // lang target Dropdown
                                Positioned(
                                  top: 5,
                                  left: 15,
                                  child: LangDropButtonWidget(
                                    items: translationLanguages,
                                    value: currentTargetValueLang,
                                    onChanged: (String? newValue) {
                                      // Handle the selected value here
                                      setState(() {
                                        currentTargetValueLang = newValue!;
                                        LangLocalStorageService.setLanguage(
                                            "target", newValue);
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    // target box
                                    child: TextFormField(
                                      maxLines: 2,
                                      onChanged: (value) {
                                        if (!editingMode) {
                                          setState(() {
                                            textToTranslate = value;
                                            if (value.isEmpty) {
                                              translatedText = "";
                                            }
                                            translateTargetText(
                                                currentTargetValueLang,
                                                currentSourceValueLang);
                                          });
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                      textAlign: TextAlign.center,
                                      // Center horizontally
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      controller: targetTextEditingController,
                                      decoration:
                                          const InputDecoration.collapsed(
                                        hintText: 'Enter text',
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 24,
                                            color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                                //new
                                Positioned(
                                  top: 0,
                                  right: 10,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    // To fit the column size to its children
                                    children: [
                                      // Clear button - Shown only if the text field is not empty
                                      if (targetTextEditingController
                                          .text.isNotEmpty)
                                        IconButton(
                                          icon: const Icon(Icons.clear,
                                              color: Colors.black45),
                                          onPressed: () {
                                            setState(() {
                                              if (editingMode) {
                                                targetTextDeleted();
                                              } else {
                                                sourceTextDeleted();
                                                targetTextDeleted();
                                              }
                                            });
                                          },
                                        ),

                                      // Copy to clipboard or Paste button
                                      // Shown based on the text field content
                                      IconButton(
                                        icon: Icon(
                                            targetTextEditingController
                                                    .text.isNotEmpty
                                                ? Icons.copy
                                                : Icons.content_paste,
                                            color: Colors.black45),
                                        onPressed: () {
                                          setState(() {
                                            if (targetTextEditingController
                                                .text.isNotEmpty) {
                                              // Copy to clipboard
                                              Clipboard.setData(ClipboardData(
                                                      text:
                                                          targetTextEditingController
                                                              .text))
                                                  .then((_) {
                                                // Show SnackBar upon successful copy
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Copied to clipboard'),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              });
                                            } else {
                                              // Paste from clipboard
                                              _pasteFromClipboard(
                                                  targetTextEditingController,
                                                  "target");
                                            }
                                          });
                                        },
                                      ),
                                      if (targetTextEditingController
                                          .text.isNotEmpty)
                                        IconButton(
                                          icon: const Icon(Icons.volume_up,
                                              color: Colors.black45),
                                          onPressed: () {
                                            setState(() {
                                              speakText(
                                                  targetTextEditingController,
                                                  currentTargetValueLang);
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                Positioned(
                                  bottom: 0,
                                  left: 10,
                                  child: (conjugationResult != null)
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .indicatorColor // Use the primary color
                                              ),
                                          onPressed: () {
                                            if (conjugationResult != null) {
                                            } else {
                                              debugPrint(
                                                  "conjugationResult == null");
                                            }

                                            Navigator.pushNamed(
                                              context,
                                              ConjugationPage.routeName,
                                              arguments: ConjugationArguments(
                                                conjugationResult!,
                                                // Make sure this is a ConjugationResult object
                                                currentTargetValueLang,
                                                // String representing the target language
                                                currentSourceValueLang, // String representing the source language
                                              ),
                                            );

                                            // Add your button's onPressed functionality here
                                          },
                                          child: Text(
                                            "Conjugate ${conjugationResult!.infinitive}",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          height: MediaQuery.of(context).size.width * 0.63,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// You can pass any object to the arguments parameter.
// In this example, create a class that contains both
// a customizable title and message.
class ConjugationArguments {
  final ConjugationResult conjugationResult;
  final String currentTargetValueLang;
  final String currentSourceValueLang;

  ConjugationArguments(this.conjugationResult, this.currentTargetValueLang,
      this.currentSourceValueLang);
}
