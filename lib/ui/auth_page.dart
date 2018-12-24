import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'standard_page_structure.dart';
import '../widgets/content_frame.dart';

class AuthPage extends StatefulWidget {

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn() async {
    // TODO: THIS
    print("THOMAS FIX THIS NOW");
    FirebaseUser user = await _auth.signInWithEmailAndPassword(email: null, password: null);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return StandardPageStructure(
      content: <Widget>[
        ContentFrame(child: Column(children: <Widget>[
          // Titlebar
          // Switch for sign-up/sign-in
          // Cards/pages for sign-up/sign-in
          // Submit button
        ],),)
      ],
    );
  }
}
