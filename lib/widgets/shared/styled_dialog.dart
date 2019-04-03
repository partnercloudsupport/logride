import 'package:flutter/material.dart';

class StyledDialog extends StatelessWidget {
  StyledDialog({this.title, this.body, this.actionText});

  final String title;
  final String body;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        FlatButton(
          child: Text(actionText),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}
