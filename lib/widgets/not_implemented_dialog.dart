import 'package:flutter/material.dart';

class NotImplementedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text("Not Implemented"),
      content: Text("This feature has not been implemented for the alpha. Please stay tuned for future changes!"),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}
