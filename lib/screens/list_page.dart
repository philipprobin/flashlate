import 'package:flashlate/services/database/community_decks.dart';
import 'package:flashlate/utils/supported_languages.dart';
import 'package:flutter/material.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';
import 'package:puppeteer/protocol/page.dart';
import '../models/core/deck.dart';
import '../services/database/personal_decks.dart';
import '../services/local_storage_service.dart';
import '../widgets/anim_search_bar_widget.dart';
import '../widgets/category_tile_widget.dart';
import '../widgets/app_bar_list_widget.dart';
import '../widgets/community_deck_list_widget.dart';
import '../widgets/lang_drop_button_widget.dart';
import '../widgets/loading_list_item_widget.dart';
import '../widgets/personal_deck_list_widget.dart';
import '../widgets/word_tile_widget.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  LocalStorageService localStorageService = LocalStorageService();

  final databaseService = PersonalDecks();

  get communityLanguages => SupportedLanguages.communityLanguages;

  String currentTargetValueLang = "Español";
  String currentSourceValueLang = "Deutsch";

  List<CategoryTileWidget> fetchedCategoryWidgets = [];
  List<CategoryTileWidget> communityCategoryWidgets = [];

  TextEditingController searchTextController = TextEditingController();
  String newDeckName = '';
  String searchTerm = '';
  static const double cornerRadius = 20.0;

  PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0;

  TextEditingController searchTextEditingController = TextEditingController();

  List<CategoryTileWidget> allFetchedCategoryWidgets = [];

  Future<List<CategoryTileWidget>>? _cachedPersonalDecks;
  Future<List<CategoryTileWidget>>? _cachedCommunityDecks;

  @override
  void initState() {
    super.initState();
    /*_fetchLocalDecks().then((categoryWidgets) {
      setState(() {
        fetchedCategoryWidgets = categoryWidgets;
      });
    });*/
    _cacheDecks();
  }

  void _cacheDecks() {
    _cachedPersonalDecks = _fetchLocalDecks();
    _cachedCommunityDecks = _fetchCommunityDecks();
  }

  Future<void> loadDropdownLangValuesFromPreferences() async {
    var languages =
        await LocalStorageService.loadDropdownLangValuesFromPreferences(
            communityLanguages, true);
    setState(() {
      currentSourceValueLang = languages["sourceLang"]!;
      currentTargetValueLang = languages["targetLang"]!;
    });
  }

  Future<bool> _updateFetchedCategoryWidgets() async {
    List<CategoryTileWidget> categoryWidgets = allFetchedCategoryWidgets;
    setState(() {
      fetchedCategoryWidgets = categoryWidgets;
    });
    // dont fetch new if search gets altered
    refreshDeckData();
    return true;
  }

  Future<void> _handleSearchTextChange(String text) async {
    setState(() {
      searchTerm = text;
    });
    // refreshDeckData();
    await _updateFetchedCategoryWidgets();
  }

  Future<void> _deleteDeck(String deckToDelete) async {
    if (deckToDelete.isNotEmpty) {
      await LocalStorageService.deleteDeck(deckToDelete);
      bool result = await databaseService.deleteDeck(deckToDelete);
      debugPrint("deck deleted: $result");
      await _updateFetchedCategoryWidgets();
      // Refresh data after deletion
      refreshDeckData();
    }
  }

  Future<void> _downloadDeck(String deckToDownload) async {
    if (deckToDownload.isNotEmpty) {
      String updatedDeckToDownloadName =
          await LocalStorageService.addDeck(deckToDownload, false);
      debugPrint("deckName Updated?: $deckToDownload");
      // check if deckToDownload is in communityCategoryWidgets and add to local and upload

      communityCategoryWidgets.forEach((element) async {
        // find deck to download in fetched community decks
        if (element.categoryName == deckToDownload) {
          // in case deckToDownload is already in local decks set a new name (1)
          deckToDownload = updatedDeckToDownloadName;
          bool practiceDeckIsEmpty = await LocalStorageService.checkDeckIsEmpty(
              "pRaCtIcEmOde-$deckToDownload");
          // add every card to local deck and practice deck and upload
          element.words.forEach((element) async {
            String term = element.word;
            String translation = element.translation;
            LocalStorageService.addCardToLocalDeck(
                deckToDownload, {term: translation});
            if (!practiceDeckIsEmpty) {
              LocalStorageService.addCardToLocalDeck(
                  "pRaCtIcEmOde-$deckToDownload", {
                "translation": {term: translation},
                "toLearn": true
              });
            }
            // upload
            bool response = await databaseService.addCard(
                deckToDownload, term, translation);
            if (!response) {
              debugPrint('upload failed');
            }
            debugPrint("upload successful $term - $translation");
          });
        }
      });
    }
    // Refresh data after download
    refreshDeckData();
  }

  Future<void> _addNewDeck() async {
    if (newDeckName.isNotEmpty) {
      await LocalStorageService.setCurrentDeck(newDeckName);

      await LocalStorageService.addDeck(newDeckName, true);

      // Clear the input field after adding
      setState(() {
        newDeckName = '';
      });
      bool boolresult = await databaseService.addCard(newDeckName, "", "");
      debugPrint("ListPage boolresult $boolresult");
      // Refetch data and update UI
      await _updateFetchedCategoryWidgets();
      // Refresh data after adding a new deck
      refreshDeckData();
    }
  }

  Future<List<CategoryTileWidget>> _fetchCommunityDecks() async {
    if (_cachedCommunityDecks != null) {
      return _cachedCommunityDecks!;
    }

    String? sourceCode =
        SupportedLanguages.languageMap[currentSourceValueLang]; // de
    String? targetCode =
        SupportedLanguages.languageMap[currentTargetValueLang]; // es
    List<Deck> decks =
        await CommunityDecks().fetchCommunityDecks("$sourceCode-$targetCode");
    List<CategoryTileWidget> categoryWidgets = [];
    for (var deck in decks) {
      CategoryTileWidget categoryTileWidget = CategoryTileWidget(
        deck.deckName,
        deck.cards
            .map((card) => WordTileWidget(
                  word: card.term!,
                  translation: card.translation!,
                  onDelete: null,
                  hasDelete: false, // gets overwritten in WordTileWidget
                ))
            .toList(),
        null,
        false,
        true,
        handleDownloadDeck,
      );
      categoryWidgets.add(categoryTileWidget);
    }
    communityCategoryWidgets = categoryWidgets; // ready to download
    return categoryWidgets;
  }

  Future<List<CategoryTileWidget>> _fetchLocalDecks() async {
    // dowload

    /*Map<String, dynamic> userDeck = await databaseService.fetchUserDoc();
    debugPrint("decks mf $decks");*/
    if (_cachedPersonalDecks != null) {
      return _cachedPersonalDecks!;
    }
    //local
    Map<String, dynamic> userDeck =
        await LocalStorageService.createMapListMapLocalDecks("");

    List<CategoryTileWidget> categoryWidgets = [];

    userDeck.forEach((deckName, cards) {
      List<WordTileWidget> wordWidgets = [];

      for (Map<String, dynamic> card in cards) {
        var translation = card['translation'];
        String word = translation.keys.first;
        String translationText = translation.values.first;

        // Check if the searchTerm is empty or if it exists in either the word or translation
        if (searchTerm.isEmpty ||
            word.toLowerCase().contains(searchTerm.toLowerCase()) ||
            translationText.toLowerCase().contains(searchTerm.toLowerCase())) {
          wordWidgets.add(WordTileWidget(
            word: word,
            translation: translationText,
            onDelete: () {},
            hasDelete: true,
          ));
        }
      }

      // Only add the categoryWidget if wordWidgets is not empty
      // suche soll keine leeren decks anzeigen
      // nach adden soll leer angezeigt werden
      if (wordWidgets.isNotEmpty || searchTerm.isEmpty) {
        var categoryWidget = CategoryTileWidget(
          deckName,
          wordWidgets.reversed.toList(),
          handleDeleteDeck,
          true,
          false,
          handleDownloadDeck,
        );

        categoryWidgets.add(categoryWidget);
      }
    });

    /*if (categoryWidgets.isNotEmpty) {
      for (CategoryTileWidget cat in categoryWidgets) {
        for (WordTileWidget words in cat.words) {
          debugPrint("data:::: ${words.word}, ${words.translation}");
        }
      }
    }*/
    // After fetching, update allFetchedCategoryWidgets
    allFetchedCategoryWidgets = categoryWidgets; // Assuming 'categoryWidgets' holds the fetched data

    return categoryWidgets;
  }

  void handleDeleteDeck(String deckName) {
    // Implement deck deletion logic here using deckName.
    // This is where you delete the deck in the parent class.
    debugPrint('Deleting deck: $deckName');
    _deleteDeck(deckName);
  }

  void handleDownloadDeck(String deckName) {
    // Implement deck deletion logic here using deckName.
    // This is where you delete the deck in the parent class.
    debugPrint('Download deck: $deckName');
    _downloadDeck(deckName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarListWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.blue,
                ),
              ),
              Container(
                width: 12,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _pageController.animateToPage(0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: Text(
                  'Personal',
                  style: currentPage == 0
                      ? TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        )
                      : TextStyle(
                          color: Colors.black,
                        ),
                ),
              ),
              TextButton(
                onPressed: () => _pageController.animateToPage(1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: Text(
                  'Community',
                  style: currentPage == 1
                      ? TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        )
                      : TextStyle(
                          color: Colors.black,
                        ),
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: decksPadding, right: decksPadding, top: decksPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  (currentPage == 0)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Decks",
                              style: TextStyle(
                                fontSize: 24.0,
                              ),
                            ),
                            Spacer(),
                            AnimatedSearchBarWidget(
                              searchTextEditingController: searchTextController,
                              onTextChanged: (text) async {
                                // Handle text changes in the parent class

                                await _handleSearchTextChange(text);
                              },
                            ),
                          ],
                        )
                      : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            LangDropButtonWidget(
                              items: communityLanguages,
                              value: currentSourceValueLang,
                              onChanged: (String? newValue) {
                                // Handle the selected value here
                                setState(() {
                                  currentSourceValueLang = newValue!;
                                });
                              },
                            ),
                            Icon(Icons.arrow_forward_rounded),
                            LangDropButtonWidget(
                              items: communityLanguages,
                              value: currentTargetValueLang,
                              onChanged: (String? newValue) {
                                // Handle the selected value here
                                setState(() {
                                  currentTargetValueLang = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _cacheDecks();
                      currentPage = index;
                    });
                  },
                  children: [
                    PersonalDeckListWidget(fetchLocalDecks: _fetchLocalDecks),
                    CommunityDeckListWidget(
                        fetchCommunityDecks: _fetchCommunityDecks),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (currentPage == 0)
          ? FloatingActionButton(
              onPressed: _addNewDeckPopUp,
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  void refreshDeckData() {
    // Invalidate the cached data
    _cachedPersonalDecks = null;
    _cachedCommunityDecks = null;

    // Re-fetch and cache the data
    _cacheDecks();
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
                  newDeckName = value.trim();
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
                  refreshDeckData();
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
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
