
import 'package:fk_toggle/fk_toggle.dart';
import 'package:flashlate/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flashlate/services/translation_service.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
  bool originalIsTop = true;

  TextEditingController bottomTextEditingController = TextEditingController();
  TextEditingController topTextEditingController = TextEditingController();
  bool editingMode = false;
  LocalStorageService localStorageService = LocalStorageService();

  List<Map<String, String>> storedData = [];
  List<String> dropdownItems = [];
  String currentDropdownValue = "";

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
    setState(() {
      translatedText = translation;
      originalIsTop = true;
      bottomTextEditingController.text = translatedText;
      debugPrint('Translated Text: $translatedText');
    });
  }

  Future<void> translateEsDeText() async {
    final translation =
        await translationService.translateEsDeText(originalText);
    setState(() {
      translatedText = translation;
      originalIsTop = false;
      topTextEditingController.text = translatedText;
      debugPrint('Translated Text: $translatedText');
    });
  }

  @override
  Widget build(BuildContext context) {
    final OnSelected selected = ((index, instance) {
      debugPrint('Select $index, toggle ${instance.labels[index]}');
      editingMode = (index == 1);
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
                                  Icon(Icons.compare_arrows),
                                  Icon(Icons.edit),
                                ],
                                labels: const ['', ''],
                                onSelected: selected,
                                enabledElementColor:
                                    Theme.of(context).primaryColor,
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: translatedText.isNotEmpty
                                      ? Theme.of(context).highlightColor
                                      : Colors
                                          .grey, // Use primaryColor when text is not empty, otherwise gray
                                ),
                                onPressed: translatedText
                                        .isNotEmpty // Enable the button only if translatedText is not empty
                                    ? () async {
                                        final databaseService =
                                            DatabaseService();
                                        // add deckName to Decklist
                                        String deckName =
                                            await LocalStorageService
                                                .getCurrentDeck();
                                        // local
                                        // add card to Cardlist
                                        String source = "";
                                        String target = "";
                                        if (originalIsTop){
                                          source = originalText.trim();
                                          target = translatedText.trim();
                                        }
                                        else{
                                          source = translatedText.trim();
                                          target = originalText.trim();
                                        }
                                        LocalStorageService.addCardToLocalDeck(
                                            deckName,
                                            {source: target});
                                        // upload
                                        bool response =
                                            await databaseService.addCard(
                                                deckName,
                                                source,
                                                target);
                                        if (!response) {
                                          debugPrint('upload failed');
                                        } else {
                                          setState(() {
                                            uploadSuccess = true;
                                          });
                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            setState(() {
                                              uploadSuccess = false;
                                            });
                                          });
                                        }
                                      }
                                    : null,
                                // Disable the button when translatedText is empty
                                icon: translatedText.isNotEmpty
                                    ? const Icon(Icons.add, color: Colors.white)
                                    : const Icon(Icons.add, color: Colors.grey),
                                label: const Text("add"),
                                // Set the icon color
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      )
                    : Container(),

                // Second Box
                (!visible)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(
                                8), // Make the container round
                          ),

                          padding: EdgeInsets.symmetric(horizontal: 16),
                          // Adjust horizontal padding as needed
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              dropdownColor: Theme.of(context).primaryColor,
                              // isExpanded: true,
                              value: currentDropdownValue.isEmpty
                                  ? (dropdownItems.isNotEmpty
                                      ? dropdownItems[0]
                                      : null)
                                  : currentDropdownValue,

                              onChanged: (String? newValue) {
                                setState(() {
                                  currentDropdownValue = newValue!;
                                  LocalStorageService.setCurrentDeck(newValue);
                                });
                              },
                              items:
                                  dropdownItems.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      // Center the text within each item
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          color: Colors.white,
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
                      )
                    : Container(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
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
                                hintText: 'Enter text',
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
                                if (editingMode) {
                                  topTextEditingController.text = '';
                                } else {
                                  topTextEditingController.text = '';
                                  bottomTextEditingController.text = '';
                                }
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
                  height: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
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
                          "Español",
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
                                hintText: 'Enter text',
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
                                if (editingMode) {
                                  bottomTextEditingController.text = '';
                                } else {
                                  topTextEditingController.text = '';
                                  bottomTextEditingController.text = '';
                                }
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
