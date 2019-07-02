import 'package:flutter/material.dart';
import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/ui/auth_page.dart';
import 'package:log_ride/ui/home.dart';

enum AuthStatus { notLoggedIn, loggedIn, notDetermined }

class LandingPage extends StatefulWidget {
  LandingPage({this.auth, this.db});

  final BaseAuth auth;
  final BaseDB db;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  AuthStatus status = AuthStatus.notDetermined;
  String userID = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          userID = user?.uid;
        }
        status =
            user?.uid == null ? AuthStatus.notLoggedIn : AuthStatus.loggedIn;
      });
    });
  }

  void _onLoggedIn() {
    setState(() {
      status = AuthStatus.loggedIn;
      widget.auth.getCurrentUser().then((user) {
        userID = user.uid.toString();
        widget.db.storeUserID(userID);
      });
    });
  }

  void _onSignedOut() {
    setState(() {
      status = AuthStatus.notLoggedIn;
      userID = "";
      widget.db.clearUserID();
    });
  }

  Widget _buildWaitingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
          alignment: Alignment.center, child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AuthStatus.notDetermined:
        return _buildWaitingScreen(context);
        break;
      case AuthStatus.notLoggedIn:
        return AuthPage(auth: widget.auth, onSignedIn: _onLoggedIn);
        break;
      case AuthStatus.loggedIn:
        if (userID.length > 0 && userID != null) {
          return Home(
            db: widget.db,
            auth: widget.auth,
            onSignedOut: _onSignedOut,
            uid: userID,
          );
        } else {
          return _buildWaitingScreen(context);
        }
        break;
      default:
        return _buildWaitingScreen(context);
    }
  }
}
