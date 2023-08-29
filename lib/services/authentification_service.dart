
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/main_page..dart';

class AuthenticationService extends StatefulWidget {
  const AuthenticationService({Key? key}) : super(key: key);

  @override
  _AuthenticationServiceState createState() => _AuthenticationServiceState();
}

class _AuthenticationServiceState extends State<AuthenticationService> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();
    checkAndSignIn(); // Check and sign in user when the widget is initialized
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
        }
      } catch (e) {
        debugPrint('Google Sign-In Error: $e');
      }
    }
    setState(() {}); // Update the widget's state after checking and signing in
  }

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}