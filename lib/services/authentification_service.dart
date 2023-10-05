
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashlate/services/synchronize_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/main_page..dart';

class AuthenticationService extends StatefulWidget {
  const AuthenticationService({Key? key}) : super(key: key);

  @override
  _AuthenticationServiceState createState() => _AuthenticationServiceState();
}

class _AuthenticationServiceState extends State<AuthenticationService> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool isFirstRun = true; // Flag to track if it's the first run


  @override
  void initState() {
    super.initState();
    _checkFirstRunAndSignIn(); // Check and sign in user when the widget is initialized
  }

  Future<void> _checkFirstRunAndSignIn() async {
    // Load the flag from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstRun = prefs.getBool('firstRun') ?? true;

    if (isFirstRun) {
      // This is the first run, call checkAndSignIn
      await checkAndSignIn();

      // Set the flag to false so that it won't run again
      await prefs.setBool('firstRun', false);
    }
  }

  Future<void> checkAndSignIn() async {
    User? user = _auth.currentUser;

    if (user == null) {
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final UserCredential userCredential = await _auth.signInWithCredential(credential);
          debugPrint('Signed in with Google: ${userCredential.user!.displayName}');

          // Add user's UID as a document in the "flashcards" collection if not already exists
          final CollectionReference flashcardsCollection = FirebaseFirestore.instance.collection('flashcards');
          final DocumentSnapshot userDoc = await flashcardsCollection.doc(userCredential.user!.uid).get();
          if (!userDoc.exists) {
            await flashcardsCollection.doc(userCredential.user!.uid).set({
              'Deck': [],
              // Add more fields if needed
            });
            debugPrint('User document added to flashcards collection.');
          }
        }
      } catch (e) {
        debugPrint('Google Sign-In Error: $e');
      }
    }
    setState(() {
      SynchronizeService.writeDbToLocal();
    }); // Update the widget's state after checking and signing in
  }

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}