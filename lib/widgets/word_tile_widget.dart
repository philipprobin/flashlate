import 'package:flutter/material.dart';

class WordTileWidget extends StatelessWidget {
  final String word;
  final String translation;
  final bool hasDelete;
  final VoidCallback?
      onDelete; // Callback to be called when delete button is pressed

  WordTileWidget({
    required this.word,
    required this.translation,
    required this.hasDelete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // print hight of tile
      title: Text(word),
      subtitle: Text(translation),
      trailing: (!hasDelete)
          ? null
          : IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.black,
              ),
              onPressed:
                  onDelete, // Call onDelete callback when the delete button is pressed
            ),
    );
  }
}
