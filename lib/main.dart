import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashlate/screens/conjugation_page.dart';
import 'package:flashlate/screens/list_page.dart';
import 'package:flashlate/screens/main_page.dart';
import 'package:flashlate/screens/practice_page.dart';
import 'package:flashlate/services/authentification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'helpers/language_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "AvertaStd",
        primaryColor: const Color(0xFF00b894),
        secondaryHeaderColor: const Color(0xFFececed), //ButtonColor
        highlightColor: const Color(0xFF303434),
        indicatorColor: const Color(0xFFE17055),
        splashColor: const Color(0xFFFDCB6E),
        // Set the accent color
        scaffoldBackgroundColor: const Color(0xFFF8F7F8),
        // canvasColor: const Color(0xFF2d3436),
        appBarTheme: AppBarTheme(
          color: Colors.grey.shade300, // Set the app bar color
        ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.grey),

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
      ),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/main': (context) => MainPage(),
        '/practice': (context) => PracticePage(),
        '/list': (context) => ListPage(),
        '/auth': (context) => const AuthenticationService(),
        '/conjugation': (context) => ConjugationPage(),

      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 1;

  final List<String> _svgAssets = [
    'assets/brain.svg', // Customize with your SVG paths
    'assets/home.svg',
    'assets/list.svg',
  ];

  final List<String> _iconTitle = [
    'Practice', // Customize with your SVG paths
    'Home',
    'List',
  ];

  final List<Widget> _tabs = [
    PracticePage(),
    const AuthenticationService(),
    ListPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoubleBackToCloseApp(
        child: _tabs[_currentIndex],
        snackBar: const SnackBar(
          content: Text('Tap again to quit'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onTabTapped,
        items: [
          for (int i = 0; i < _svgAssets.length; i++)
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _svgAssets[i],
                width: 20, // Adjust width and height as needed
                height: 20,
                color: _currentIndex == i
                    ? Theme.of(context).primaryColor // Selected color
                    : Colors.white, // Default color
              ),
              label: _iconTitle[i],
            ),
        ],
      ),

    );
  }
}
