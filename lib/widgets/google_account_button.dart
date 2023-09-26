import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAccountButton extends StatelessWidget {
  GoogleAccountButton({Key? key}) : super(key: key);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

    Future<void> checkAndSignIn() async {
      User? user = _auth.currentUser;

      if (user == null) {
        try {
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser != null) {
            final GoogleSignInAuthentication googleAuth =
                await googleUser.authentication;
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            final UserCredential userCredential =
                await _auth.signInWithCredential(credential);
            debugPrint(
                'Signed in with Google: ${userCredential.user!.displayName}');
          }
        } catch (e) {
          debugPrint('Google Sign-In Error: $e');
        }
      } else {
        // Sign out user
        await _auth.signOut();
        // Switch accounts
        await checkAndSignIn();
      }
    }

    return IconButton(
      onPressed: () {
        checkAndSignIn();
      },
      icon: Icon(
        Icons.person,
        key: Key("person_icon"),
      ),
    );
  }
}
