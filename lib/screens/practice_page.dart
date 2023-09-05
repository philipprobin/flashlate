import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_app_bar_widget.dart';

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
      backgroundColor: Theme.of(context).primaryColor,
      appBar: CustomAppBarWidget(),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _handleCardTap,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: userDeck.length,
                  itemBuilder: (context, index) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          key: ValueKey<int>(index),
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            showFrontSide
                                ? userDeck[index].keys.first
                                : userDeck[index].values.first,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle the red button press (not specified in the original question).
                    _moveAndAnimate((userDeck.length * 0.25).toInt());
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Bad'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle the yellow button press.
                    _moveAndAnimate(
                        userDeck.length ~/ 2); // Move to the middle.
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  child: Text('Well'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle the green button press.
                    _moveAndAnimate(userDeck.length - 1);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Nice!'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
