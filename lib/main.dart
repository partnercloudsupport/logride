import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'ui/home.dart';
import 'widgets/attraction_status_button.dart';

class TestAttractionStatusScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(child: Text("Ooh ride")),
                  AttractionButton(enabled: true, count: 0)
                ]),
                Row(children: <Widget>[
                  Expanded(child: Text("Ooh ride")),
                  AttractionButton(enabled: true, count: 25)
                ]),
                Row(children: <Widget>[
                  Expanded(child: Text("Ooh ride")),
                  AttractionButton(enabled: false, count: 0)
                ]),
                Row(children: <Widget>[
                  Expanded(child: Text("Ooh ride")),
                  AttractionButton(enabled: false, count: 25)
                ]),
              ],
            )),
            color: Theme.of(context).primaryColor));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'LogRide',
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
        home: HomePage());
  }
}

void main() {
  runApp(MyApp());
}
