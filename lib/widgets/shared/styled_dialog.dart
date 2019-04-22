import 'package:flutter/material.dart';

class StyledDialog extends StatelessWidget {
  StyledDialog({this.title, this.body, this.actionText, this.additionalAction});

  final String title;
  final String body;
  final String actionText;
  final Widget additionalAction;

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = List<Widget>();
    buttons.add(
        FlatButton(
          child: Text(actionText),
          onPressed: () => Navigator.of(context).pop()
    ));

    if(additionalAction != null){
      buttons.add(additionalAction);
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text(title),
      content: Text(body),
      actions: buttons,
    );
  }
}
