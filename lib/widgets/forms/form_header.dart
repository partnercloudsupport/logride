import 'package:flutter/material.dart';

class FormHeader extends StatelessWidget {
  FormHeader({this.text, this.subtext});

  final String text;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                text,
                style: Theme.of(context).textTheme.title.apply(
                    fontSizeDelta: 6.0,
                    fontWeightDelta: 2,
                    color: Colors.white),
              ),
            ),
            (subtext == null)
                ? Container()
                : Text(
                    subtext,
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .apply(color: Colors.white),
                  )
          ],
        ),
      ),
    );
  }
}
