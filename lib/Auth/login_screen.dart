import 'dart:developer';

import 'package:chat_app/Screens/homepage_screen.dart';
import 'package:chat_app/helper/Dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Apis/apis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleBtnClick() {
    // Showing Progress Bar
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      // closing progress bar
      Navigator.pop(context);
      if (user != null) {
        log('\nuser: ${user.credential}');
        log('\nAdditionalInfouser: ${user.additionalUserInfo}');

        if (await APIs.userExists()) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: ((context) => const HomePage())));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: ((context) => const HomePage())));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\nsignInWithGoogle: $e');
      Dialogs.showSnackBar(
          context, "Something went wrong!, check internet connection");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
            onPressed: () {
              _handleGoogleBtnClick();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                shape: const StadiumBorder()),
            icon: Image.asset(
              'Assets/Images/google.png',
              height: 40,
            ),
            label: RichText(
                text: const TextSpan(children: [
              TextSpan(text: 'Login with '),
              TextSpan(
                  text: 'Google', style: TextStyle(fontWeight: FontWeight.bold))
            ]))),
      ),
    );
  }
}
