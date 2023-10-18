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
  int cardsUnknown = 0;
  int cardsKnown = 0;
  Map<String, dynamic>? conjugationResult;
  String currentDeck = "";
  bool isReviewMode = false;

  @override
  void initState() {
    super.initState();
    _fetchStoredData();
  }

  Future<void> _setKnownCardsNumbers(int limitIndex) async {
    var cardsList = await LocalStorageService.fetchLocalDeck(isReviewMode ? "rEvIeWDeCk-$currentDeck" : "pRaCtIcEmOde-$currentDeck");
    int trueCount = 0;
    int falseCount = 0;

    for (int i = 0; i < limitIndex; i++) {
      bool toLearnValue = cardsList[i]["toLearn"];
      if (toLearnValue == true) {
        trueCount++;
      } else if (toLearnValue == false) {
        falseCount++;
      }
    }
    cardsUnknown = trueCount;
    cardsKnown = falseCount;
  }

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
    isReviewMode =
        await LocalStorageService.getReviewMode("rEvIeWmOde-$currentDeck");
    int fetchedIndex = await LocalStorageService.getIndex("iNdEx-$currentDeck");

    List<Map<String, dynamic>> cardsList = [];

    // get List<Map> with translate and toLearn, create if not exist
    cardsList = await LocalStorageService.createCardsDeck(currentDeck);

    if (isReviewMode) {
      cardsList =
          await LocalStorageService.fetchLocalDeck("rEvIeWDeCk-$currentDeck");
    }

    debugPrint("cardsList $cardsList");

    // check if all already solved:  all cards are titled with I KNOW, (allSolved)
    bool allSolved = await LocalStorageService.allSolved(
        isReviewMode ? "rEvIeWDeCk-$currentDeck" : "pRaCtIcEmOde-$currentDeck");
    if (cardsList.length > 0 && allSolved) {
      _showCustomPopupDialog(context, true);
    }

    setState(() {
      pageController = PageController(initialPage: fetchedIndex);
      userDeck = cardsList;
      debugPrint("list elements ${userDeck.length}");
      currentIndex = fetchedIndex;
      _setKnownCardsNumbers(currentIndex);
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
        isReviewMode ? "rEvIeWDeCk-$currentDeck" : "pRaCtIcEmOde-$currentDeck",
        oldCard,
        newCard);

    // to show updated knownCards for the last rating
    setState(() {
      _setKnownCardsNumbers(currentIndex+1);

    });

    if (currentIndex + 1 < userDeck.length) {
      Future.delayed(Duration(milliseconds: 20), () async {
        // Add your animation here if needed
        await LocalStorageService.setIndex(
            "iNdEx-$currentDeck", currentIndex += 1);
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
      bool allSolved = await LocalStorageService.allSolved(isReviewMode
          ? "rEvIeWDeCk-$currentDeck"
          : "pRaCtIcEmOde-$currentDeck");
      // only for showing how last card is rated
      /*setState(() {
        _setKnownCardsValues();
      });*/
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
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Align(
                          alignment: Alignment.center, // Center the text both horizontally and vertically
                          child: Text(
                            cardsUnknown.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                      Text(
                        '${currentIndex + 1} / ${userDeck.length}',
                        style: TextStyle(
                          fontSize: 20, // Adjust the font size as needed
                        ),
                      ),
                      Container(
                        width: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Align(
                          alignment: Alignment.center, // Center the text both horizontally and vertically
                          child: Text(
                            cardsKnown.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                    await LocalStorageService.setIndex("iNdEx-$currentDeck", 0);

                    bool isReviewMode = await LocalStorageService.getReviewMode(
                        "rEvIeWmOde-$currentDeck");
                    if (!isReviewMode) {
                      // old reviewDeck gets overwritten, after Falses get deleted
                      // if comes from practice deck, values can be copied to review deck and then deleted
                      await LocalStorageService.copyDeck(
                          "pRaCtIcEmOde-$currentDeck",
                          "rEvIeWDeCk-$currentDeck");
                    }

                    await LocalStorageService.deleteToLearnFalses(
                        "rEvIeWDeCk-$currentDeck");

                    var rEvIeWDeCk = await LocalStorageService.fetchLocalDeck(
                        "rEvIeWDeCk-$currentDeck");
                    debugPrint("rEvIeWDeCk are falses gone?: $rEvIeWDeCk");

                    await LocalStorageService.setReviewMode(
                        "rEvIeWmOde-$currentDeck", true);

                    await _fetchStoredData();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .indicatorColor, // High emphasis button
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
                  await LocalStorageService.setIndex("iNdEx-$currentDeck", 0);
                  await LocalStorageService.setReviewMode(
                      "rEvIeWmOde-$currentDeck", false);

                  await _fetchStoredData();
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    color:
                        Theme.of(context).primaryColor, // Low emphasis button
                  ),
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
