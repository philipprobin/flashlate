import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/cloud_function_service.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import 'conjugation_page.dart';
import 'main_page..dart';

class PracticePage extends StatefulWidget {
  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  List<Map<String, String>> userDeck = [];
  final databaseService = DatabaseService();
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  bool showFrontSide = true;
  Map<String, dynamic>? conjugationResult;

  @override
  void initState() {
    super.initState();
    _fetchStoredData();
  }

  @override
  void dispose() {
    _savePracticeDeck();
    debugPrint("disposed!!!");
    super.dispose();
  }

  Future<void> _savePracticeDeck() async {
    String currentDeck = await LocalStorageService.getCurrentDeck();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert userDeck to a list of encoded strings
    List<String> encodedUserDeck = [];

    for (Map<String, String> card in userDeck) {
      String encodedCard = json.encode(card);
      encodedUserDeck.add(encodedCard);
    }

    // Save the encoded userDeck to SharedPreferences
    await prefs.setStringList("pRaCtIcEmOde-$currentDeck", encodedUserDeck);
  }

/*  Future<void> verbIsShown(String word) async {
    await showConjugations(word);
  }

  Future<bool> showConjugations(String translatedText) async {
    debugPrint("showConjugations triggerd");
    Map<String, dynamic>? conjugations =
        await CloudFunctionService.fetchSpanishConjugations(translatedText);
    if (conjugations != null) {
      debugPrint(conjugations.toString());
      setState(() {
        conjugationResult = conjugations;
      });

      return true;
    } else {
      return false;
    }
  }*/

  String extractLetters(String input) {
    // Define a regular expression to match letters
    final RegExp regex = RegExp(r'[^0-9]+');

    // Use the RegExp pattern to find all matches in the input string
    Iterable<Match> matches = regex.allMatches(input);

    // Join the matched letters to form a new string
    String result = matches.map((match) => match.group(0)!).join('');

    return result;
  }

  Future<void> _fetchStoredData() async {
    // download
    // Map<String,dynamic> downloadDecks = await databaseService.fetchUserDoc();
    // local
    // Map<String,dynamic> localDecks = await LocalStorageService.createMapListMapLocalDecks("");

    String currentDeck = await LocalStorageService.getCurrentDeck();

    List<Map<String, String>> cardsList = [];

    bool practiceDeckIsEmpty =
        await LocalStorageService.checkDeckIsEmpty("pRaCtIcEmOde-$currentDeck");

    if (practiceDeckIsEmpty) {
      bool res = await LocalStorageService.copyDeckToPracticeMode(currentDeck);
      debugPrint("copyDeckToPracticeMode $res");
    }

    Map<String, dynamic> localDecks =
        await LocalStorageService.createMapListMapLocalDecks(
            "pRaCtIcEmOde-$currentDeck");

    debugPrint("localDecks $localDecks");
    localDecks.forEach((deckName, cards) {
      for (Map<String, dynamic> card in cards) {
        Map<String, dynamic> translation = card['translation'];

        cardsList
            .add({translation.keys.first: translation.values.first.toString()});
      }
    });

    setState(() {
      _savePracticeDeck();
      userDeck = cardsList;
      debugPrint("list elements ${userDeck.length}");
      currentIndex = 0;
      showFrontSide = true;
    });
  }

  void _handleCardTap() {
    setState(() {
      showFrontSide = !showFrontSide;
    });
  }

  void _moveAndAnimate(int moveToIndex) {
    if (moveToIndex >= 0 &&
        moveToIndex < userDeck.length &&
        moveToIndex != currentIndex) {
      // Get the current card to move
      Map<String, String> currentCard = userDeck[currentIndex];

      // Remove the card from the current position
      userDeck.removeAt(currentIndex);

      // Insert the card at the specified index
      userDeck.insert(moveToIndex, currentCard);

      Future.delayed(Duration(milliseconds: 300), () {
        // Add your animation here if needed

        setState(() {
          _savePracticeDeck();
          pageController.animateToPage(
            currentIndex,
            duration: Duration(seconds: 1), // Set the desired duration
            curve: Curves.easeInOut,
          );
        });
      });

      debugPrint("SWIPED: $userDeck");
      // Trigger your swipe left animation here.
      // You can add your animation code or call your animation function here.
    }
  }

  // Update _swipeCard method as follows
  void _swipeCard(int delta) {
    int newIndex = currentIndex + delta;
    if (newIndex >= 0 && newIndex < userDeck.length) {
      setState(() {
        currentIndex = newIndex;
        pageController.animateToPage(
          currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        showFrontSide = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _handleCardTap,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: userDeck.length,

                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Center(
                      child: Stack(
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                key: ValueKey<int>(index),
                                height: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    showFrontSide
                                        ? userDeck[index].keys.first
                                        : userDeck[index].values.first,
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 32, // Adjust the top position as needed
                            right: 32, // Adjust the right position as needed
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.touch_app_rounded,
                                color: Colors.grey,
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
                                        debugPrint("conjugationResult == null");
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
                    );
                  },
                ),
              ),
            ),
          ),
          // Button Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle the button press.
                            _moveAndAnimate(userDeck.length ~/ 2);
                          },
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(BorderSide(
                              color: Color(0xFFe15055), // Outline color
                              width: 2.0, // Adjust the width as needed
                            )),
                            foregroundColor: MaterialStateProperty.all(
                              Color(0xFFe15055),
                            ), // Font color
                          ),
                          child: Text('Bad'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle the button press.
                            _moveAndAnimate(userDeck.length ~/ 2);
                          },
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(BorderSide(
                              color: Color(0xfffbcb6e), // Outline color
                              width: 2.0, // Adjust the width as needed
                            )),
                            foregroundColor: MaterialStateProperty.all(
                                Color(0xfffbcb6e)), // Font color
                          ),
                          child: Text('Well'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle the button press.
                            _moveAndAnimate(userDeck.length ~/ 2);
                          },
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(BorderSide(
                              color: Theme.of(context)
                                  .primaryColor, // Outline color
                              width: 2.0, // Adjust the width as needed
                            )),
                            foregroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ), // Font color
                          ),
                          child: Text('Nice'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
