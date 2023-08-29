import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map<String, dynamic>> storedData = []; // Store the fetched data here

  Future<void> _fetchStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('data') ?? '[]'; // Provide a default empty JSON array

    setState(() {
      Map<String, dynamic> dataList = json.decode(jsonData);
      for (var entry in dataList.entries) {
        Map<String, String> entryMap = {
          entry.key: entry.value,
        };
        storedData.add(entryMap);
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchStoredData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent.shade700,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: storedData.length,
        itemBuilder: (context, index) {
          String originalText = storedData[index].keys.first;
          String translatedText = storedData[index][originalText] ?? '';

          return ListTile(
            title: Text(originalText),
            subtitle: Text(translatedText),
          );
        },
      ),
    );
  }
}
