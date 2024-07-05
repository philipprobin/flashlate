import 'package:flutter/material.dart';
import 'package:flashlate/services/local_storage_service.dart';
import 'package:flashlate/services/database/personal_decks.dart';

class AddToCardDeckButton extends StatefulWidget {
  final TextEditingController sourceTextEditingController;
  final TextEditingController targetTextEditingController;
  final double cornerRadius;
  final double addBoxPadding;
  final Color addBoxColor;
  final VoidCallback onSuccess;

  const AddToCardDeckButton({
    Key? key,
    required this.sourceTextEditingController,
    required this.targetTextEditingController,
    required this.cornerRadius,
    required this.addBoxPadding,
    required this.addBoxColor,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _AddToCardDeckButtonState createState() => _AddToCardDeckButtonState();
}

class _AddToCardDeckButtonState extends State<AddToCardDeckButton> {
  bool uploadSuccess = false;

  Future<void> _addToCardDeck() async {
    final databaseService = PersonalDecks();
    String deckName = await LocalStorageService.getCurrentDeck();

    String source = widget.sourceTextEditingController.text.trim();
    String target = widget.targetTextEditingController.text.trim();

    LocalStorageService.addCardToLocalDeck(deckName, {source: target});
    bool practiceDeckIsEmpty =
    await LocalStorageService.checkDeckIsEmpty("pRaCtIcEmOde-$deckName");

    if (!practiceDeckIsEmpty) {
      LocalStorageService.addCardToLocalDeck(
          "pRaCtIcEmOde-$deckName", {
        "translation": {source: target},
        "toLearn": true,
      });
    }

    bool response = await databaseService.addCard(deckName, source, target);
    if (!response) {
      debugPrint('upload failed');
    } else {
      setState(() {
        uploadSuccess = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          uploadSuccess = false;
        });
      });
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (widget.sourceTextEditingController.text.isNotEmpty &&
          widget.targetTextEditingController.text.isNotEmpty)
          ? _addToCardDeck
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.addBoxColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(widget.cornerRadius),
            bottomLeft: Radius.circular(widget.cornerRadius),
          ),
        ),
      ),
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width - 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(widget.addBoxPadding),
                child: Text(
                  "Add Card To Deck",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
