import 'package:flashlate/services/database_service.dart';
import 'package:flashlate/services/local_storage_service.dart';
import 'package:flashlate/widgets/word_tile_widget.dart';
import 'package:flutter/material.dart';

typedef DeleteDeckCallback = void Function(String deckName);

class CategoryTileWidget extends StatefulWidget {
  final String categoryName;
  final List<WordTileWidget> words;
  final DeleteDeckCallback onDeleteDeck;

  const CategoryTileWidget(this.categoryName, this.words, this.onDeleteDeck, {super.key});

  @override
  _CategoryTileState createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTileWidget> {
  bool _isExpanded = false;
  bool _isSelectedDeck = false;
  List<WordTileWidget> _currentWords = [];

  @override
  void initState() {
    super.initState();
    _currentWords = List.from(widget.words);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Color(0xFFf8f4f4),
              borderRadius: BorderRadius.circular(20.0)),
          child: customExpansionTile(
            title: widget.categoryName,
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (value) {
              setState(() {
                _isExpanded = value;
              });
            },
            onDeleteDeckChild: (title) {
              // Call onDeleteDeck here with the title of the tile
              print('Delete Deck: $title');
              widget.onDeleteDeck(title);

            },
            onLongPress: () {
              LocalStorageService.setCurrentDeck(widget.categoryName);
              setState(() {
                _isSelectedDeck = true;
              });
            },
            children: _currentWords.map((wordWidget) {
              return WordTileWidget(
                word: wordWidget.word,
                translation: wordWidget.translation,
                onDelete: () {
                  _removeWord(wordWidget);
                },
              );
            }).toList(),
          ),
        ),
        Container(
          height: 8,
        )
      ],
    );
  }

  Future<void> _removeWord(WordTileWidget wordWidget) async {
    setState(() {
      _currentWords.remove(wordWidget);
    });
    bool localResult = await LocalStorageService.deleteCardFromLocalDeck(
        widget.categoryName, {wordWidget.word: wordWidget.translation});
    debugPrint("local removal successfull $localResult");
    bool localPracticeResult =
        await LocalStorageService.deleteCardFromLocalDeck(
            "pRaCtIcEmOde-${widget.categoryName}",
            {wordWidget.word: wordWidget.translation});
    debugPrint("local Practice removal successfull $localPracticeResult");
    bool dbResult = await DatabaseService.deleteCard(
        widget.categoryName, {wordWidget.word: wordWidget.translation});
    debugPrint("database removal successfull $dbResult");

    // You can also add logic here to update your data source or perform any other necessary actions
  }
}
Widget customExpansionTile({
  required String title,
  required List<Widget> children,
  bool initiallyExpanded = false,
  Function(bool)? onExpansionChanged,
  Function()? onLongPress,
  Function(String)? onDeleteDeckChild,
}) {
  return GestureDetector(
    onLongPress: onLongPress,
    child: Column(
      children: <Widget>[
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Icon(
                    initiallyExpanded
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    color: Colors.black,
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'deleteDeck',
                      child: Container(
                        color: Colors.white,
                        child: Text('Delete Deck'),
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value == 'deleteDeck' && onDeleteDeckChild != null) {
                      onDeleteDeckChild(title); // Pass the title to the callback
                    }
                  },
                ),
              )
            ],
          ),
          onTap: () {
            if (onExpansionChanged != null) {
              onExpansionChanged(!initiallyExpanded);
            }
          },
        ),
        if (initiallyExpanded)
          Column(
            children: children,
          ),
      ],
    ),
  );
}

