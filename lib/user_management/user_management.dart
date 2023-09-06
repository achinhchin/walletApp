import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserManagement {
  static Future<int> login() async {
    final GoogleSignInAccount? user = await GoogleSignIn().signIn();
    if (user == null) {
      return 0;
    }else if (user.email.substring(user.email.length - 16) != '@samsenwit.ac.th') {
      GoogleSignIn().signOut();
      return -1;
    }

    final GoogleSignInAuthentication userAuth = await user.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: userAuth.accessToken,
      idToken: userAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    return 1;
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    return;
  }
}
