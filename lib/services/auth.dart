import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_chat/pages/login.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../pages/home.dart';
import 'database.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> getCurrentUser() async {
    return await _auth.currentUser;
  }

  // signInWithGoogle(BuildContext context) async {
  //   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //
  //   final GoogleSignInAccount? googleSignInAccount =
  //   await googleSignIn.signIn();
  //
  //   final GoogleSignInAuthentication? googleSignInAuthentication =
  //   await googleSignInAccount?.authentication;
  //
  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //       idToken: googleSignInAuthentication?.idToken,
  //       accessToken: googleSignInAuthentication?.accessToken);
  //
  //   UserCredential result = await firebaseAuth.signInWithCredential(credential);
  //
  //   User? userDetails = result.user;
  //
  //   if (result != null) {
  //     Map<String, dynamic> userInfoMap = {
  //       "email": userDetails!.email,
  //       "name": userDetails.displayName,
  //       "imgUrl": userDetails.photoURL,
  //       "id": userDetails.uid
  //     };
  //     await DatabaseMethods()
  //         .addUser(userDetails.uid, userInfoMap)
  //         .then((value) {
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => Home()));
  //     });
  //   }
  // }


  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final String? idToken = googleSignInAuthentication?.idToken;
        final String? accessToken = googleSignInAuthentication?.accessToken;

        if (idToken != null || accessToken != null) {
          final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: idToken,
            accessToken: accessToken,
          );

          UserCredential result = await firebaseAuth.signInWithCredential(credential);

          User? userDetails = result.user;

          if (result != null) {
            Map<String, dynamic> userInfoMap = {
              "email": userDetails!.email,
              "name": userDetails.displayName,
              "imgUrl": userDetails.photoURL,
              "id": userDetails.uid
            };
            await DatabaseMethods()
                .addUser(userDetails.uid, userInfoMap)
                .then((value) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            });
          }
        } else {
          // Handle the case where both idToken and accessToken are null
          print("Google sign-in failed: Both idToken and accessToken are null");
          // Show a snackbar or display an error message to the user
        }
      } else {
        // Handle the case where googleSignInAccount is null
        print("Google sign-in failed: googleSignInAccount is null");
        // Show a snackbar or display an error message to the user
      }
    } catch (e) {
      // Handle other exceptions that might occur during sign-in
      print("Error signing in with Google: $e");
      // Show a snackbar or display an error message to the user
    }
  }



  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LogIn())); // Navigate to login page after sign out
    } catch (e) {
      print("Error signing out: $e");
      // Handle error
    }
  }
}
