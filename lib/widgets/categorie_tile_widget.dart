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

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: GestureDetector(
        onLongPress: () {
          LocalStorageService.setCurrentDeck(
              widget.categoryName); // Call setCurrentDeck on long press
          setState(() {
            _isSelectedDeck = true;
          });
          // Handle long press action here
          // For example, call a function or update a state
        },
        child: Text(
          widget.categoryName,
          style: _isSelectedDeck
              ? TextStyle(fontWeight: FontWeight.bold) // Bold if selected deck
              : null,
        ),
      ),
      children: widget.words,
      onExpansionChanged: (value) {
        setState(() {
          _isExpanded = value;
        });
      },
    );
  }
}
