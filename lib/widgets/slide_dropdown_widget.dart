import 'package:flutter/material.dart';

class SlideDropdownWidget extends StatefulWidget {
  final List<String> entries;

  SlideDropdownWidget({required this.entries});

  @override
  _SlideDropdownWidgetState createState() => _SlideDropdownWidgetState();
}

class _SlideDropdownWidgetState extends State<SlideDropdownWidget> {
  String selectedEntry = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 200,
              child: ListView.builder(
                itemCount: widget.entries.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(widget.entries[index]),
                    onTap: () {
                      setState(() {
                        selectedEntry = widget.entries[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedEntry.isNotEmpty ? selectedEntry : 'Select an entry'),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
