import 'package:flashlate/services/database_service.dart';
import 'package:flashlate/services/local_storage_service.dart';
import 'package:flashlate/widgets/word_tile_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryTileWidget extends StatefulWidget {
  final String categoryName;
  final List<WordTileWidget> words;

  const CategoryTileWidget(this.categoryName, this.words, {super.key});

  @override
  _CategoryTileState createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTileWidget> {
  bool _isExpanded = false;
  bool _isSelectedDeck = false;
  List<WordTileWidget> _currentWords =[];

  @override
  void initState() {
    super.initState();
    _currentWords = List.from(widget.words);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: GestureDetector(
        onLongPress: () {
          LocalStorageService.setCurrentDeck(widget.categoryName);
          setState(() {
            _isSelectedDeck = true;
          });
        },
        child: Text(
          widget.categoryName,
          style: _isSelectedDeck
              ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
              : const TextStyle(fontSize: 20),
        ),
      ),
      children: _currentWords.map((wordWidget) {
        return WordTileWidget(
          word: wordWidget.word,
          translation: wordWidget.translation,
          onDelete: () {
            _removeWord(wordWidget);
          },
        );
      }).toList(),
      onExpansionChanged: (value) {
        setState(() {
          _isExpanded = value;
        });
      },
    );
  }

  Future<void> _removeWord(WordTileWidget wordWidget) async {
    setState(() {
      _currentWords.remove(wordWidget);
    });
    bool localResult = await LocalStorageService.deleteCardFromLocalDeck(widget.categoryName, {wordWidget.word: wordWidget.translation});
    debugPrint("local removal successfull $localResult");
    bool localPracticeResult = await LocalStorageService.deleteCardFromLocalDeck("pRaCtIcEmOde-${widget.categoryName}", {wordWidget.word: wordWidget.translation});
    debugPrint("local Practice removal successfull $localPracticeResult");
    bool dbResult = await DatabaseService.deleteCard(widget.categoryName, {wordWidget.word: wordWidget.translation});
    debugPrint("database removal successfull $dbResult");

    // You can also add logic here to update your data source or perform any other necessary actions
  }
}
