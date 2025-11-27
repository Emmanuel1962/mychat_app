// ignore_for_file: unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychat_app/helper/helper_functions.dart';
import 'package:mychat_app/service/database_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//login
  Future loginUserWithEmailandPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      // "!=" means not equal to
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // this returning is incase of any error in "e"
    }
  }

//register
  Future registerUserwithEmailandPassword(
      String username, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      // "!=" means not equal to
      if (user != null) {
        // call our database  service to update our user data
        await DatabaseService(uid: user.uid).savingUserData(username, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // this returning is incase of any error in "e"
    }
  }

//signout
  Future signout() async {
    try {
      await HelperFuctions.userLoggedInStatus(false);
      await HelperFuctions.emailLoggedInStatus("");
      await HelperFuctions.usernameLoggedInStatus("");
      firebaseAuth
          .signOut(); // This means that once you  sign out , you have to login in with your details again
    } catch (e) {
      return null;
    }
  }
}
