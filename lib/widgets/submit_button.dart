import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  SubmitButton({this.text, this.onTap});

  final String text;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 0.1,
                  blurRadius: 4,
                  offset: Offset(0, 2))
            ]),
        child: MaterialButton(
          onPressed: onTap,
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).accentColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 42),
            child: Text(text.toUpperCase(), style: TextStyle(
              color: Colors.white,
              fontSize: 25.0
            ),),
          ),
        ));
  }
}
