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

  Future<void> _addNewDeck() async {
    if (newDeckName.isNotEmpty) {
      localStorageService.addDeck(newDeckName);

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

    Map<String, dynamic> decks = await databaseService.fetchAllCards();
    debugPrint("decks $decks");

    List<CategoryTileWidget> categoryWidgets = [];

    for (var categoryEntry in decks.entries) {
      var categoryName = categoryEntry.key;
      var wordMap = categoryEntry.value;

      List<WordTileWidget> wordWidgets = [];
      for (var wordEntry in wordMap.entries) {
        var word = wordEntry.key;
        var translation = wordEntry.value;
        wordWidgets.add(WordTileWidget(word, translation));
      }

      var categoryWidget = CategoryTileWidget(categoryName, wordWidgets);
      categoryWidgets.add(categoryWidget);
    }

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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[200],
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              newDeckName = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter a new deck name',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addNewDeck,
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Add Deck',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: fetchedCategoryWidgets,
            ),
          ),
        ],
      ),
    );
  }
}
