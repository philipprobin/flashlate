import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flashlate/widgets/anim_search_bar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/categorie_tile_widget.dart';
import '../widgets/top_bar_without_toggle_widget.dart';
import '../widgets/word_tile_widget.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  LocalStorageService localStorageService = LocalStorageService();
  final databaseService = DatabaseService();

  List<CategoryTileWidget> fetchedCategoryWidgets = [];

  String newDeckName = '';
  static const double cornerRadius = 20.0;


  TextEditingController searchTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData("").then((categoryWidgets) {
      setState(() {
        fetchedCategoryWidgets = categoryWidgets;
      });
    });
  }

  Future<void> _deleteDeck(String deckToDelete) async {
    if (deckToDelete.isNotEmpty) {
      LocalStorageService.deleteDeck(deckToDelete);
      bool result = await databaseService.deleteDeck(deckToDelete);
      debugPrint("deck deleted: $result");

      _fetchData("").then((categoryWidgets) {
        setState(() {
          fetchedCategoryWidgets = categoryWidgets;
        });
      });
    }
  }

  Future<void> _addNewDeck() async {
    if (newDeckName.isNotEmpty) {
      LocalStorageService.setCurrentDeck(newDeckName);

      LocalStorageService.addDeck(newDeckName, true);

      // Clear the input field after adding
      setState(() {
        newDeckName = '';
      });
      bool boolresult = await databaseService.addCard(newDeckName, "", "");
      debugPrint("ListPage boolresult $boolresult");
      // Refetch data and update UI
      _fetchData("").then((categoryWidgets) {
        setState(() {
          fetchedCategoryWidgets = categoryWidgets;
        });
      });
    }
  }

  Future<List<CategoryTileWidget>> _fetchData(String searchTerm) async {
    // dowload

    /*Map<String, dynamic> userDeck = await databaseService.fetchUserDoc();
    debugPrint("decks mf $decks");*/

    //local
    Map<String, dynamic> userDeck =
        await LocalStorageService.createMapListMapLocalDecks("");

    List<CategoryTileWidget> categoryWidgets = [];

    userDeck.forEach((deckName, cards) {
      List<WordTileWidget> wordWidgets = [];
      for (Map<String, dynamic> card in cards) {
        //String time = card['time'];
        Map<String, dynamic> translation = card['translation'];
        wordWidgets.add(WordTileWidget(
          word: translation.keys.first,
          translation: translation.values.first.toString(),
          onDelete: () {},
        ));
      }
      var categoryWidget = CategoryTileWidget(
          deckName, wordWidgets.reversed.toList(), handleDeleteDeck);
      categoryWidgets.add(categoryWidget);
    });
    return categoryWidgets;
    /*userDeck.forEach((deckName, cards) {
      List<WordTileWidget> wordWidgets = [];

      for (Map<String, dynamic> card in cards) {
        Map<String, dynamic> translation = card['translation'];
        String word = translation.keys.first;
        String translationText = translation.values.first.toString();

        // Check if the searchTerm is empty or if it exists in either the word or translation
        if (searchTerm.isEmpty ||
            deckName.toLowerCase().contains(searchTerm.toLowerCase()) ||
            word.toLowerCase().contains(searchTerm.toLowerCase()) ||
            translationText.toLowerCase().contains(searchTerm.toLowerCase())) {
          wordWidgets.add(WordTileWidget(
            word: word,
            translation: translationText,
            onDelete: () {},
          ));
        }
      }

      // Only add the categoryWidget if wordWidgets is not empty
      if (wordWidgets.isNotEmpty) {
        var categoryWidget = CategoryTileWidget(
          deckName,
          wordWidgets.reversed.toList(),
          handleDeleteDeck,
        );
        debugPrint("wordWidgets word: ${wordWidgets.first.word}");

        categoryWidgets.add(categoryWidget);
      }

    });

    return categoryWidgets;*/
  }

  void handleDeleteDeck(String deckName) {
    // Implement deck deletion logic here using deckName.
    // This is where you delete the deck in the parent class.
    debugPrint('Deleting deck: $deckName');
    _deleteDeck(deckName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 19.0),
            child: TopBarWithoutToggleWidget(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _addNewDeckPopUp, //then add new deck
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Create new deck',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              Container(
                width: 12,
              ),
              /*ElevatedButton(
                onPressed: _deleteDeck,
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('-', style: TextStyle(color: Colors.white)),
              ),*/
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Decks",
                        style: TextStyle(
                          fontSize: 24.0,
                        ),
                      ),
                      /*Spacer(),
                      AnimSearchBarWidget(
                        boxShadow: false,
                        width: MediaQuery.of(context).size.width * 0.6,
                        rtl: false,
                        textController: searchTextEditingController,
                        onSuffixTap: () {
                          setState(() {
                            searchTextEditingController.clear();
                            _fetchData("").then((categoryWidgets) {
                              setState(() {
                                fetchedCategoryWidgets = categoryWidgets;
                              });
                            });
                          });
                        }, onSubmitted: (String value) {
                          debugPrint("state changed $value");

                          _fetchData(value).then((categoryWidgets) {
                            setState(() {
                              fetchedCategoryWidgets = categoryWidgets;
                            });
                          });
                      },
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cornerRadius),
                topRight: Radius.circular(cornerRadius),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              // doesnt need scrollview!!!!
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ListView(
                  children: fetchedCategoryWidgets.reversed.toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewDeckPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'New Deckname',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 12,
                textAlign: TextAlign.center,

                onChanged: (value) {
                  setState(() {
                    newDeckName = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter a deck name',
                  border: InputBorder.none,
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Handle the deck creation logic here
                  print('Creating deck: $newDeckName');
                  _addNewDeck();
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Create'),
              ),
            ],
          ),
        );
      },
    );
  }
}
