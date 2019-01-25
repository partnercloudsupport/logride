import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'data/auth_manager.dart';
import 'data/fbdb_manager.dart';
import 'ui/park_search.dart';
import 'ui/landing_page.dart';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    BaseDB db = DatabaseManager();
    db.init();

    return MaterialApp(
        title: 'LogRide',
        routes: <String, WidgetBuilder>{
          "/all_search": (BuildContext context) => AllParkSearchPage(),
        },
        theme: ThemeData(
            primaryColor: new Color.fromARGB(255, 57, 164, 72),
            accentColor: new Color.fromARGB(255, 91, 220, 70),
            buttonColor: new Color.fromARGB(255, 57, 164, 72),
            disabledColor: new Color.fromARGB(255, 204, 204, 204),
            textTheme: TextTheme(
                subhead:
                    TextStyle(fontSize: 22.0, fontWeight: FontWeight.normal),
                subtitle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey),
                headline: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold
                ))),
        home: LandingPage(auth: Auth(), db: db,));
  }
}

void main() {
  runApp(MyApp());
}
