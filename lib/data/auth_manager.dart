import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:log_ride/data/verify_username.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String username, String email, String password);
  Future<FirebaseUser> getCurrentUser();
  Future<String> getCurrentUserID();
  Future<String> getCurrentUserName();
  Future<String> getCurrentUserEmail();
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<String> signUp(String username, String email, String password) async {
    bool unique = await isNewUsername(username);
    if (!unique) throw PlatformException(code: "ERROR_DUPLICATE_USERNAME");

    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    DatabaseReference reference =
        _firebaseDatabase.reference().child("users/details");
    reference.child(user.uid).set({"userID": user.uid, "userName": username});
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<String> getCurrentUserID() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }

  Future<String> getCurrentUserName() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    DatabaseReference location = _firebaseDatabase
        .reference()
        .child("users/details/${user.uid}/userName/");
    return await location.once().then((snap) => snap.value);
  }

  Future<String> getCurrentUserEmail() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.email;
  }
}
