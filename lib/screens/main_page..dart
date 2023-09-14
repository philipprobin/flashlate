import 'package:flashlate/screens/conjugation_page.dart';
import 'package:flashlate/services/cloud_function_service.dart';
import 'package:flashlate/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flashlate/services/translation_service.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../services/local_storage_service.dart';
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
  bool uploadSuccess = false;
  bool originalIsTop = true;
  static const double cornerRadius = 20.0;
  static const secondBoxColor = Color(0xFFf8f8f8);
  static const addBoxColor = Color(0xFF2f3638);
  var translatedTextNotEmpty = false;

  TextEditingController bottomTextEditingController = TextEditingController();
  TextEditingController topTextEditingController = TextEditingController();
  bool editingMode = false;
  LocalStorageService localStorageService = LocalStorageService();

  List<Map<String, String>> storedData = [];
  List<String> dropdownItems = [];
  String currentDropdownValue = "";

  Map<String, dynamic>? conjugationResult;

  @override
  void initState() {
    super.initState();

    loadDropdownItemsFromPreferences();
  }

  Future<void> loadDropdownItemsFromPreferences() async {
    // Fetch the items from local preferences (shared preferences)

    // creates new deck "Deck" if list empty
    String currentDeck = await LocalStorageService.getCurrentDeck();

    List<String> fetchedItems = await LocalStorageService.getDeckNames();
    debugPrint("currentDeck iiisss : $currentDeck");

    if (fetchedItems.isEmpty) {
      // TODO: add App Icon
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

  Future<void> translateDeEsText() async {
    final translation =
        await translationService.translateDeEsText(originalText);
    showConjugations(translation);
    setState(() {
      translatedText = translation;
      originalIsTop = true;
      bottomTextEditingController.text = translatedText;
      translatedTextNotEmpty = translatedText.isNotEmpty ? true : false;

      debugPrint('Translated Text: $translatedText');
    });
  }

  String extractLetters(String input) {
    // Define a regular expression to match letters
    final RegExp regex = RegExp(r'[a-zA-Z]+');

    // Use the RegExp pattern to find all matches in the input string
    Iterable<Match> matches = regex.allMatches(input);

    // Join the matched letters to form a new string
    String result = matches.map((match) => match.group(0)!).join('');

    return result;
  }

  Future<bool> showConjugations(String translatedText) async {
    debugPrint("showConjugations triggerd");
    Map<String, dynamic>? conjugations =
        await CloudFunctionService.fetchVerConjugations(translatedText);
    if (conjugations != null) {
      debugPrint(conjugations.toString());
      setState(() {
        conjugationResult = conjugations;
      });

      return true;
    } else {
      return false;
    }
  }

  Future<void> translateEsDeText() async {
    showConjugations(originalText);
    final translation =
        await translationService.translateEsDeText(originalText);
    setState(() {
      translatedText = translation;
      translatedTextNotEmpty = translatedText.isNotEmpty ? true : false;
      originalIsTop = false;
      topTextEditingController.text = translatedText;
      debugPrint('Translated Text: $translatedText');
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, visible) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                    height: MediaQuery.of(context).size.width * 0.42,
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
                                    topTextEditingController.text = '';
                                  } else {
                                    topTextEditingController.text = '';
                                    bottomTextEditingController.text = '';
                                  }
                                  translatedTextNotEmpty = false;
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
                            top: 0,
                            left: 10,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).secondaryHeaderColor,
                                // Other button styling options here
                              ),
                              onPressed: () {
                                // Your button's onPressed code here
                              },
                              child: const Text(
                                "Deutsch",
                                style: TextStyle(
                                  color: Color(0xFFbcbcbd),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
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
                        onPressed: translatedTextNotEmpty
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
                                  source = originalText.trim();
                                  target = translatedText.trim();
                                } else {
                                  source = translatedText.trim();
                                  target = originalText.trim();
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
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            // Align content to the bottom
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    "Add Translation To Deck",
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
                      height: MediaQuery.of(context).size.width * 0.42,
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
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              top: 0,
                              left: 10,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                                  // Other button styling options here
                                ),
                                onPressed: () {
                                  // Your button's onPressed code here
                                },
                                child: const Text(
                                  "Español",
                                  style: TextStyle(
                                    color: Color(0xFFbcbcbd),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
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
                                      bottomTextEditingController.text = '';
                                    } else {
                                      topTextEditingController.text = '';
                                      bottomTextEditingController.text = '';
                                    }
                                    translatedTextNotEmpty = false;
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
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .primaryColor, // Use the primary color
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
