import 'package:flashlate/widgets/custom_app_bar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/categorie_tile_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchData().then((categoryWidgets) {
      setState(() {
        fetchedCategoryWidgets = categoryWidgets;
      });
    });
  }

  Future<void> _deleteDeck() async {
    if (newDeckName.isNotEmpty) {
      LocalStorageService.deleteDeck(newDeckName);
      bool result = await databaseService.deleteDeck(newDeckName);
      debugPrint("deck deleted: $result");


      _fetchData().then((categoryWidgets) {
        setState(() {
          newDeckName = '';
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
      _fetchData().then((categoryWidgets) {
        setState(() {
          fetchedCategoryWidgets = categoryWidgets;
        });
      });
    }
  }

  Future<List<CategoryTileWidget>> _fetchData() async {
    // dowload

    /*Map<String, dynamic> userDeck = await databaseService.fetchUserDoc();
    debugPrint("decks mf $decks");*/

    //local
    Map<String, dynamic> userDeck = await LocalStorageService.createMapListMapLocalDecks("");

    List<CategoryTileWidget> categoryWidgets = [];

    userDeck.forEach((deckName, cards) {
      List<WordTileWidget> wordWidgets = [];
      for (Map<String, dynamic> card in cards) {
        //String time = card['time'];
        Map<String, dynamic> translation = card['translation'];
        wordWidgets.add(WordTileWidget(
            word: translation.keys.first, translation: translation.values.first.toString(), onDelete: () {  },));
      }
      var categoryWidget =
          CategoryTileWidget(deckName, wordWidgets.reversed.toList());
      categoryWidgets.add(categoryWidget);
    });
    return categoryWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[200],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              newDeckName = value.trim();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter a deck name',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addNewDeck,
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('+',
                        style: TextStyle(color: Colors.white)),
                  ),
                  Container(
                    width: 12,
                  ),
                  ElevatedButton(
                    onPressed: _deleteDeck,
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('-',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: fetchedCategoryWidgets.reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }
}
