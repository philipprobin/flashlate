import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Auth{

  static Future<UserCredential> signupWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    print(credential);

    print(credential.authorizationCode);
    final signInCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken!,
      accessToken: credential.authorizationCode,
    );
    final userCredential =
    await FirebaseAuth.instance.signInWithCredential(signInCredential);

    print(userCredential.user);
    return userCredential;
  }
}