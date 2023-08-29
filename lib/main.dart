import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashlate/screens/list_page.dart';
import 'package:flashlate/screens/main_page..dart';
import 'package:flashlate/screens/practice_page.dart';
import 'package:flashlate/services/authentification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  static const  MaterialColor customBlue = MaterialColor(
    0xFFE1F0FF, // Primary color value
      <int, Color>{
        50: Color(0xFFE1F0FF), // Lightest shade
        100: Color(0xFFB3D1FF),
        200: Color(0xFF80ABFF),
        300: Color(0xFF4D85FF),
        400: Color(0xFF266CFF),
        500: Color(0xFF0077FF), // Default shade
        600: Color(0xFF006EFF),
        700: Color(0xFF0065FF),
        800: Color(0xFF005BFF),
        900: Color(0xFF004AFF), // Darkest shade
      },
  );



      // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[300],

        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hind'),
        ),
      ),


      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.green
      ),
      home: AuthenticationService(),

      routes: {
        '/main': (context) => MainPage(),
        '/practice': (context) => PracticePage(),
        '/list': (context) => ListPage(),
      },
    );
  }
}


