import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/synchronize_service.dart';

class GoogleAccountButton extends StatefulWidget {
  GoogleAccountButton({Key? key}) : super(key: key);

  @override
  _GoogleAccountButtonState createState() => _GoogleAccountButtonState();
}

class _GoogleAccountButtonState extends State<GoogleAccountButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showAccountManagementDialog(context);
      },
      icon: Icon(

        Icons.person,
        key: Key("person_icon"),
        size: 36,
        color: Colors.black,
      ),
    );
  }

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

  Future<void> _showAccountManagementDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_auth.currentUser == null) // Show only if user is not signed in
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Sign In with Google'),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet
                    await checkAndSignIn();
                    setState(() {
                      SynchronizeService.writeDbToLocal();
                    });
                  },
                ),
              if (_auth.currentUser != null) // Show only if user is signed in
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet
                    await _auth.signOut(); // Sign out user
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete App Account'),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  // Add your logic here to delete the app account
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
