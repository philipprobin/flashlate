import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import 'conjugation_page.dart';
import 'main_page..dart';

class PracticePage extends StatefulWidget {
  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  List<Map<String, dynamic>> userDeck = [];
  final databaseService = DatabaseService();
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  bool showFrontSide = true;
  Map<String, dynamic>? conjugationResult;
  String currentDeck = "";

  @override
  void initState() {
    super.initState();
    _fetchStoredData();
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
    final RegExp regex = RegExp(r'\D+');

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

    currentDeck = await LocalStorageService.getCurrentDeck();

    List<Map<String, dynamic>> cardsList = [];

    //await LocalStorageService.deleteDeck("pRaCtIcEmOde-$currentDeck");
    bool practiceDeckIsEmpty =
        await LocalStorageService.checkDeckIsEmpty("pRaCtIcEmOde-$currentDeck");

    debugPrint("practiceDeckIsEmpty: $practiceDeckIsEmpty");

    if (practiceDeckIsEmpty) {
      // toLearn doesnt exist yet
      bool res = await LocalStorageService.copyDeckToPracticeMode(currentDeck);
      debugPrint("copyDeckToPracticeMode $res");
    }

    /*var fetch = await LocalStorageService.fetchLocalDeck("pRaCtIcEmOde-$currentDeck");
    debugPrint("before $fetch");*/

    // hier wird toLearn auf true gesetzt
    Map<String, dynamic> localDecks =
        await LocalStorageService.createMapListMapLocalDecks(
            "pRaCtIcEmOde-$currentDeck");

    /*fetch = await LocalStorageService.fetchLocalDeck("pRaCtIcEmOde-$currentDeck");
    debugPrint("before $fetch");*/

    cardsList = localDecks["pRaCtIcEmOde-$currentDeck"];
    debugPrint("cardsList $cardsList");

    List<Map<String, dynamic>> filteredCardsList =
        cardsList.where((element) => element['toLearn'] == true).toList();

    //if all cards are titled with I KNOW, (allSolved)
    if (cardsList.length > 0 && filteredCardsList.length == 0) {
      _showCustomPopupDialog(context, true);
    }

    debugPrint("");
    debugPrint("filteredCardsList length: ${filteredCardsList.length}");
    debugPrint("");

    setState(() {
      //_savePracticeDeck();
      userDeck = filteredCardsList;
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

  Future<void> _showNextCard(bool mustLearn, BuildContext context) async {
    // user knows the card, switch value toLearn to false
    Map<String, dynamic> oldCard = userDeck[currentIndex];

    Map<String, dynamic> newCard = Map.from(oldCard);
    if (oldCard.containsKey("toLearn")) {
      newCard["toLearn"] = mustLearn;
    }

    await LocalStorageService.updateCardInDeck(
        "pRaCtIcEmOde-$currentDeck", oldCard, newCard);
    /*var fetch = await LocalStorageService.fetchLocalDeck("pRaCtIcEmOde-$currentDeck");
    debugPrint("update that $fetch");*/

    if (currentIndex + 1 < userDeck.length) {
      Future.delayed(Duration(milliseconds: 20), () {
        // Add your animation here if needed
        currentIndex += 1;
        setState(() {
          pageController.animateToPage(
            currentIndex,
            duration: Duration(milliseconds: 400), // Set the desired duration
            curve: Curves.easeInOut,
          );
        });
      });

      debugPrint("current index $currentIndex");
    } else {
      // end of list reached
      debugPrint("ziel erreicht");
      debugPrint("userDeck all false?: $userDeck");
      bool allSolved =
          await LocalStorageService.allSolved("pRaCtIcEmOde-$currentDeck");
      _showCustomPopupDialog(context, allSolved);
      // after popup always to position one
      Future.delayed(Duration(milliseconds: 20), () {
        // Add your animation here if needed
        setState(() {
          pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 10), // Set the desired duration
            curve: Curves.easeInOut,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("my current deck order: $userDeck");

    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Container(
            height: statusBarHeight,
            color: Colors.red,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${currentIndex + 1} / ${userDeck.length}',
                    style: TextStyle(
                      fontSize: 20, // Adjust the font size as needed
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: userDeck.isNotEmpty
                  ? GestureDetector(
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
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.4,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          showFrontSide
                                              ? userDeck[index]["translation"]
                                                  .keys
                                                  .first
                                              : userDeck[index]["translation"]
                                                  .values
                                                  .first
                                                  .toString(),
                                          style: TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 32, // Adjust the top position as needed
                                  right:
                                      32, // Adjust the right position as needed
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
                          );
                        },
                      ),
                    )
                  : Text("Add Cards to Deck first..."),
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
                            _showNextCard(true, context);
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
                          child: Text('I don\'t know'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle the button press.
                            _showNextCard(false, context);
                            //ceck if update worked
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
                          child: Text('I know'),
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

  void _showCustomPopupDialog(BuildContext context, bool allSolved) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Great job! You finished all your cards.',
            textAlign: TextAlign.center,
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!allSolved)
                ElevatedButton(
                  onPressed: () async {
                    // Add your logic for "Review Cards" here
                    await _fetchStoredData();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).indicatorColor,  // High emphasis button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Review Cards'),
                ),
              TextButton(
                onPressed: () async {
                  // Add your logic for "Restart Cards" here
                  await LocalStorageService.setPracticeCardsToLearnTrue(
                      "pRaCtIcEmOde-$currentDeck");
                  await _fetchStoredData();
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    color:
                        Theme.of(context).primaryColor, // Low emphasis button
                  ),
                  /*backgroundColor: Theme.of(context).primaryColor, // Custom button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),*/
                ),
                child: Text('Restart Cards'),
              ),
            ],
          ),
        );
      },
    );
  }
}
