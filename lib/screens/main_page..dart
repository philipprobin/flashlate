import 'package:flashlate/screens/conjugation_page.dart';
import 'package:flashlate/services/cloud_function_service.dart';
import 'package:flashlate/services/database_service.dart';
import 'package:flashlate/services/lang_local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flashlate/services/translation_service.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../services/local_storage_service.dart';
import '../widgets/lang_drop_button_widget.dart';
import '../widgets/top_bar_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TranslationService translationService = TranslationService();

  String sourceText = '';
  String targetText = '';
  bool uploadSuccess = false;
  bool originalIsTop = true;

  static const double cornerRadius = 20.0;
  static const secondBoxColor = Color(0xFFf8f8f8);
  var targetTextNotEmpty = false;

  TextEditingController targetTextEditingController = TextEditingController();
  TextEditingController sourceTextEditingController = TextEditingController();
  bool editingMode = false;
  LocalStorageService localStorageService = LocalStorageService();

  List<Map<String, String>> storedData = [];
  List<String> dropdownItems = [];
  List<String> langDropDownItems = [
    "Deutsch",
    "Español",
    "English",
    "Français",
    "Polski",
    "Português"
  ];
  String currentDropdownValue = "";
  String currentTargetValueLang = "Español";
  String currentSourceValueLang = "Deutsch";

  String originalVerb = "";

  Map<String, dynamic>? conjugationResult;

  @override
  void initState() {
    super.initState();
    loadDropdownLangValuesFromPreferences();
    loadDropdownDeckItemsFromPreferences();
  }

  Future<void> loadDropdownLangValuesFromPreferences() async {
    String? currentSourceLang =
        await LangLocalStorageService.getLanguage("source");
    if (currentSourceLang == null) {
      currentSourceLang = langDropDownItems[0];
      await LangLocalStorageService.setLanguage(
          "source", currentSourceLang); // like Español
    }
    String? currentTargetLang =
        await LangLocalStorageService.getLanguage("target");
    if (currentTargetLang == null) {
      currentTargetLang = langDropDownItems[1];
      await LangLocalStorageService.setLanguage(
          "target", currentTargetLang); // like Español
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
    debugPrint("currentDeck iiisss : $currentDeck");

    if (fetchedItems.isEmpty) {
      // TODO: add more langs
    }

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
        sourceLang, targetLang, sourceText);
    if (currentTargetValueLang == "Español") {
      showSpanishConjugations(translation);
    }
    setState(() {
      targetText = translation;
      originalIsTop = true;
      targetTextEditingController.text = targetText;
      targetTextNotEmpty = targetText.isNotEmpty ? true : false;

      debugPrint('Translated Text: $targetText');
    });
  }

  String extractLetters(String input) {
    // Define a regular expression to match letters
    final RegExp regex = RegExp(r'[^0-9]+');

    // Use the RegExp pattern to find all matches in the input string
    Iterable<Match> matches = regex.allMatches(input);

    // Join the matched letters to form a new string
    String result = matches.map((match) => match.group(0)!).join('');

    return result;
  }

  Future<bool> showSpanishConjugations(String translatedText) async {
    debugPrint("showConjugations triggerd");
    Map<String, dynamic>? conjugations =
        await CloudFunctionService.fetchSpanishConjugations(translatedText, currentSourceValueLang);

    if (conjugations != null) {
      if (originalVerb != conjugations["original_verb"]){
        setState(() {
          conjugationResult = conjugations;
          originalVerb = conjugations["original_verb"];
        });
      }

      debugPrint(conjugations.toString());


      return true;
    } else {
      return false;
    }
  }

  Future<void> translateTargetText(String sourceLang, String targetLang) async {
    if (currentTargetValueLang == "Español") {
      showSpanishConjugations(sourceText);
    }
    final translation = await translationService.translateText(
        sourceLang, targetLang, sourceText);
    setState(() {
      targetText = translation;
      targetTextNotEmpty = targetText.isNotEmpty ? true : false;
      originalIsTop = false;
      sourceTextEditingController.text = targetText;
      debugPrint('Translated Text: $targetText');
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
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TopBarWidget(
                  isEditingMode: (value) {
                    // This function will be called when the boolean value changes.
                    debugPrint('Boolean value isEditingMode changed: $value');
                    editingMode = value;
                    // You can perform any action here based on the boolean value.
                  },
                ),
                // DropDown
                /*ElevatedButton(
                  child: Text("ghier"),
                  onPressed: () {
                    // Navigate to ScreenB when the button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPage()),
                    );
                  },
                ),*/
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      // Round only the top-left corner
                      topRight: Radius.circular(
                          10.0), // Round only the top-right corner
                    ), // Make the container round
                  ),

                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  // Adjust horizontal padding as needed
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      icon: const Icon(null // Make the icon transparent
                          ),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      dropdownColor: Theme.of(context).primaryColor,
                      // isExpanded: true,
                      value: currentDropdownValue.isEmpty
                          ? (dropdownItems.isNotEmpty ? dropdownItems[0] : null)
                          : currentDropdownValue,

                      onChanged: (String? newValue) {
                        setState(() {
                          currentDropdownValue = newValue!;
                          LocalStorageService.setCurrentDeck(newValue);
                        });
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return dropdownItems.map<Widget>((String item) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  item,
                                  style: const TextStyle(
                                    fontFamily: 'AvertaStd',
                                    // Specify the font family name
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    // Text color of selected item
                                    fontSize: 18, // Font size of selected item
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      items: dropdownItems.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              // Center the text within each item
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'AvertaStd',
                                  // Specify the font family name
                                  fontWeight: FontWeight.w700,
                                  // Text color of selected item
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),

                // first box
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
                              child: TextFormField(
                                maxLines: 2,
                                onChanged: (value) {
                                  if (!editingMode) {
                                    setState(() {
                                      sourceText = value;
                                      if (value.isEmpty) {
                                        targetText = "";
                                      }
                                      translateSourceText(
                                          currentSourceValueLang,
                                          currentTargetValueLang);
                                    });
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
                            top: 10, // Adjust the top position as needed
                            right: 10, // Adjust the right position as needed
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (editingMode) {
                                    sourceTextEditingController.text = '';
                                  } else {
                                    sourceTextEditingController.text = '';
                                    targetTextEditingController.text = '';
                                  }
                                  targetTextNotEmpty = false;
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
                                items: langDropDownItems,
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
                        onPressed: targetTextNotEmpty
                            ? () async {
                                // Your button's onPressed code here...
                                final databaseService = DatabaseService();
                                // add deckName to Decklist
                                String deckName =
                                    await LocalStorageService.getCurrentDeck();
                                // local
                                // add card to Cardlist
                                String source = "";
                                String target = "";
                                if (originalIsTop) {
                                  source =
                                      sourceTextEditingController.text.trim();
                                  target =
                                      targetTextEditingController.text.trim();
                                } else {
                                  source =
                                      targetTextEditingController.text.trim();
                                  target =
                                      sourceTextEditingController.text.trim();
                                }
                                LocalStorageService.addCardToLocalDeck(
                                    deckName, {source: target});
                                bool practiceDeckIsEmpty =
                                    await LocalStorageService.checkDeckIsEmpty(
                                        "pRaCtIcEmOde-$deckName");
                                // only add if not empty -> if empty gets copied later
                                if (!practiceDeckIsEmpty) {
                                  LocalStorageService.addCardToLocalDeck(
                                      "pRaCtIcEmOde-$deckName",
                                      {source: target});
                                }

                                // upload
                                bool response = await databaseService.addCard(
                                    deckName, source, target);
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
                                items: langDropDownItems,
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
                                child: TextFormField(
                                  maxLines: 2,
                                  onChanged: (value) {
                                    if (!editingMode) {
                                      setState(() {
                                        sourceText = value;
                                        if (value.isEmpty) {
                                          targetText = "";
                                        }
                                        translateTargetText(
                                            currentTargetValueLang,
                                            currentSourceValueLang);
                                      });
                                    }
                                  },
                                  textAlign: TextAlign.center,
                                  // Center horizontally
                                  textAlignVertical: TextAlignVertical.center,
                                  controller: targetTextEditingController,
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
                              top: 10, // Adjust the top position as needed
                              right: 10, // Adjust the right position as needed
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (editingMode) {
                                      targetTextEditingController.text = '';
                                    } else {
                                      sourceTextEditingController.text = '';
                                      targetTextEditingController.text = '';
                                    }
                                    targetTextNotEmpty = false;
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
                            Positioned(
                              bottom: 0,
                              right: 10,
                              child: (conjugationResult != null)
                                  ? (targetTextEditingController.text.contains(originalVerb))
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .indicatorColor // Use the primary color
                                              ),
                                          onPressed: () {
                                            if (conjugationResult != null) {
                                              debugPrint(
                                                  "conjugationResult != null ${extractLetters(conjugationResult!["verb"])}");
                                            } else {
                                              debugPrint(
                                                  "conjugationResult == null");
                                            }

                                            Navigator.pushNamed(
                                              context,
                                              ConjugationPage.routeName,
                                              arguments: ConjugationArguments(
                                                conjugationResult,
                                              ),
                                            );
                                            // Add your button's onPressed functionality here
                                          },
                                          child: Text(
                                              "Conjugate ${extractLetters(conjugationResult!["verb"])}"),
                                        )
                                      : Container()
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
        ),
      );
    });
  }
}

// You can pass any object to the arguments parameter.
// In this example, create a class that contains both
// a customizable title and message.
class ConjugationArguments {
  final Map<String, dynamic>? verbConjugations;

  ConjugationArguments(this.verbConjugations);
}
