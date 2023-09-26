import 'package:flutter/material.dart';

class AnimatedSearchBarWidget extends StatefulWidget {
  final TextEditingController searchTextEditingController;
  final ValueChanged<String> onTextChanged;

  AnimatedSearchBarWidget({
    required this.searchTextEditingController,
    required this.onTextChanged,
  });

  @override
  _AnimatedSearchBarWidgetState createState() => _AnimatedSearchBarWidgetState();
}

class _AnimatedSearchBarWidgetState extends State<AnimatedSearchBarWidget> {
  bool isSearching = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: isSearching ? 200.0 : 50.0, // Adjust width as needed

      child: Row(
        children: [
          Expanded(
            child: isSearching
                ? TextField(
                    controller: widget.searchTextEditingController,
                    onChanged: widget.onTextChanged,
                    focusNode: _focusNode, // Add FocusNode
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  )
                : Container(),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: isSearching
                ? GestureDetector(
                    key: Key("clear_icon"),
                    onTap: () {
                      widget.searchTextEditingController.clear();
                      widget.onTextChanged('');
                    },
                    child: Icon(
                      Icons.clear,
                      key: Key("clear_icon"),
                    ),
                  )
                : GestureDetector(
                    key: Key("search_icon"),
                    onTap: () {
                      setState(() {
                        isSearching = !isSearching;
                        // Request focus on the TextField widget.
                        _focusNode.requestFocus();
                        // Show the keyboard.
                      });
                    },
                    child: Icon(
                      Icons.search,
                      key: Key("search_icon"),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
