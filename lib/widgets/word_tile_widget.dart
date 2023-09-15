import 'package:flutter/material.dart';

class WordTileWidget extends StatelessWidget {
  final String word;
  final String translation;
  final VoidCallback onDelete; // Callback to be called when delete button is pressed

  WordTileWidget({
    required this.word,
    required this.translation,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(word),
      subtitle: Text(translation),
      trailing: IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.black,
        ),
        onPressed: onDelete, // Call onDelete callback when the delete button is pressed
      ),
    );
  }
}
