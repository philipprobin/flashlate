import 'package:flashlate/widgets/practice/proficiency_button.dart';
import 'package:flutter/material.dart';
import '../services/database/personal_decks.dart';
import '../services/local_storage_service.dart';
import '../services/translation_service.dart';
import '../widgets/practice/counter_row.dart';

class PracticePage extends StatefulWidget {
  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  List<Map<String, dynamic>> userDeck = [];
  final databaseService = PersonalDecks();
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  bool showFrontSide = true;
  int cardsUnknown = 0;
  int cardsKnown = 0;
  Map<String, dynamic>? conjugationResult;
  String currentDeck = "";
  bool isReviewMode = false;

  bool speakSlowSource = false;

  @override
  void initState() {
    super.initState();
    _fetchStoredData();
  }

  Future<void> _setKnownCardsNumbers(int limitIndex) async {
    var cardsList = await LocalStorageService.fetchLocalDeck(
        isReviewMode ? "rEvIeWDeCk-$currentDeck" : "pRaCtIcEmOde-$currentDeck");
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
    debugPrint("isReviewMode: $isReviewMode");
    // get List<Map> with translate and toLearn, create if not exist
    cardsList = await LocalStorageService.getPracticeDeck(currentDeck);

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
      if (fetchedIndex < 0) {
        fetchedIndex = 0;
      }
      pageController = PageController(initialPage: fetchedIndex);
      userDeck = cardsList;
      debugPrint("list elements ${userDeck.length}");
      currentIndex = fetchedIndex;
      _setKnownCardsNumbers(currentIndex);
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
      _setKnownCardsNumbers(currentIndex + 1);

      /// todo: show front side when swiping
      showFrontSide = true;
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
          ),
          CounterRow(
            currentIndex: currentIndex,
            userDeckLength: userDeck.length,
            cardsUnknown: cardsUnknown,
            cardsKnown: cardsKnown,
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.volume_up, color: Colors.black45),
                                        onPressed: () {
                                          setState(() {
                                            // Assuming TranslationService and speakText are accessible
                                            // You might need to adapt this part to your actual data handling and services
                                            TranslationService().speakText(
                                                userDeck[index]["translation"].values.first.toString(),
                                                "Français",
                                            );
                                          });
                                        },
                                      ),
                                      Text(
                                        showFrontSide
                                            ? userDeck[index]["translation"].keys.first
                                            : userDeck[index]["translation"].values.first.toString(),
                                        style: TextStyle(fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
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
                    // Assuming this is in a build method or another widget.
                    ProficiencyButton(
                      text: "I don't know",
                      color: Color(0xFFe15055), // Adjust this color as needed.
                      onPressed: () {
                        _showNextCard(true, context); // Adjust this function as needed.
                      },
                    ),
                    ProficiencyButton(
                      text: "I know",
                      color: Theme.of(context).primaryColor, // Using the theme's primary color.
                      onPressed: () {
                        _showNextCard(false, context); // Adjust this function as needed.
                      },
                    )

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
          backgroundColor: Colors.white,
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
                  child: Text('Review Cards', style: TextStyle(
                    color:
                    Colors.white, // Low emphasis button
                  ),),
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
                        Colors.white, // Low emphasis button
                  ),
                ),
                child: Text('Restart Cards', style: TextStyle(color: Theme.of(context).indicatorColor),),
              ),
            ],
          ),
        );
      },
    );
  }
}
