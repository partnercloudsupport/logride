import 'package:flutter/material.dart';

class StyledDialog extends StatelessWidget {
  StyledDialog({this.title, this.body, this.actionText, this.action, this.additionalAction});

  final String title;
  final String body;
  final String actionText;
  final VoidCallback action;
  final Widget additionalAction;

  @override
  Widget build(BuildContext context) {


    List<Widget> buttons = List<Widget>();
    buttons.add(
        FlatButton(
          child: Text(actionText),
          onPressed: action != null ? action : () => Navigator.of(context).pop()
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

class StyledConfirmDialog extends StatelessWidget {
  StyledConfirmDialog({this.title, this.body, this.confirmButtonText, this.denyButtonText});

  final String title;
  final String body;
  final String confirmButtonText;
  final String denyButtonText;

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: title,
      body: body,
      actionText: denyButtonText,
      action: () => Navigator.of(context).pop(false),
      additionalAction: FlatButton(
        child: Text(confirmButtonText),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
