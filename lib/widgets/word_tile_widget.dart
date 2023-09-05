import 'package:flutter/material.dart';

class WordTileWidget extends StatelessWidget {
  final String word;
  final String translation;
  final VoidCallback onDelete; // Callback to be called when swiped left

  WordTileWidget({
    required this.word,
    required this.translation,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(word), // Unique key for the Dismissible widget
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onDismissed: (direction) {
        onDelete(); // Trigger the onDelete callback when swiped left
      },
      child: ListTile(
        title: Text(word),
        subtitle: Text(translation),
      ),
    );
  }
}
