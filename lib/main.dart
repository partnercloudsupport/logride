import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'data/auth_manager.dart';
import 'ui/all_park_search.dart';
import 'ui/landing_page.dart';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'LogRide',
        routes: <String, WidgetBuilder>{
          "/all_search": (BuildContext context) => AllParkSearchPage(),
        },
        theme: ThemeData(
            primaryColor: new Color.fromARGB(255, 57, 164, 72),
            accentColor: new Color.fromARGB(255, 91, 220, 70),
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
        home: LandingPage(auth: Auth()));
  }
}

void main() {
  runApp(MyApp());
}
