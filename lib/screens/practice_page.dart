import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PracticePage extends StatefulWidget {
  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  List<Map<String, String>> storedData = [];
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  bool showFrontSide = true;

  @override
  void initState() {
    super.initState();
    _fetchStoredData();
  }

  Future<void> _fetchStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('data') ?? '[]';

    setState(() {
      Map<String, dynamic> dataList = json.decode(jsonData);
      for (var entry in dataList.entries) {
        Map<String, String> entryMap = {
          entry.key: entry.value,
        };
        storedData.add(entryMap);
      }

      debugPrint("list elements ${storedData.length}");
      currentIndex = 0;
      showFrontSide = true;
    });
  }

  void _handleCardTap() {
    setState(() {
      showFrontSide = !showFrontSide;
    });
  }

  // Update _swipeCard method as follows
  void _swipeCard(int delta) {
    int newIndex = currentIndex + delta;
    if (newIndex >= 0 && newIndex < storedData.length) {
      setState(() {
        currentIndex = newIndex;
        pageController.animateToPage(
          currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        showFrontSide = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.amberAccent.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: GestureDetector(
          onTap: _handleCardTap,
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx < 0) {
              _swipeCard(1); // Swipe to the left
            } else if (details.velocity.pixelsPerSecond.dx > 0) {
              _swipeCard(-1); // Swipe to the right
            }
          },
          child: PageView.builder(
            controller: pageController,
            itemCount: storedData.length,
            itemBuilder: (context, index) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    key: ValueKey<int>(index),
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      showFrontSide
                          ? storedData[index].keys.first
                          : storedData[index].values.first,
                      style: TextStyle(fontSize: 20,),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
