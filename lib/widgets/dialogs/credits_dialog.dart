import 'package:flutter/material.dart';

class CreditsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("LogRide Credits"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _CreditHeader("App Development"),
          _CreditEntry("Justin Lawrence (iOS)"),
          _CreditEntry("Mark Lawrence (iOS)"),
          _CreditEntry("Thomas Stoeckert (Android)"),
          _CreditHeader("Park / Attraction Research"),
          _CreditEntry("Cardin Menkemeller"),
          _CreditEntry("Daniel Fischman"),
          _CreditEntry("Mario Brajevich"),
          _CreditHeader("Social Media"),
          _CreditEntry("Michael Brenkan")
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}

class _CreditHeader extends StatelessWidget {
  _CreditHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CreditEntry extends StatelessWidget {
  _CreditEntry(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 16.0),
    );
  }
}
