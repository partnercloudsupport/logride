import 'package:flutter/material.dart';

class AttractionButton extends StatelessWidget {
  AttractionButton({this.enabled, this.count, this.onTap});

  final bool enabled;
  final num count;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List<Widget>();
    Widget buttonWidget;
    Container textDisplay;

    // We only want the text to display if there exists a count on the button
    if(count > 0){
      textDisplay = Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(count.toString(),
            textAlign: TextAlign.right,
            textScaleFactor: 1.3),
        )
      );
      children.add(textDisplay);
    }

    IconData buttonIcon;
    Color buttonColor;

    // Text will display regardless of enabled. Our button, however, does differ

    if(enabled){
      buttonColor = Theme.of(context).primaryColor;
      if(count > 0){
        // Plus button is displayed when there's at least one count
        buttonIcon = Icons.add_circle;
      } else {
        // Standard button is displayed when there's no count
        buttonIcon = Icons.arrow_drop_down_circle;
      }
    } else {
      // X-button is displayed when the ride is defunct/disabled
      buttonIcon = Icons.remove_circle;
      buttonColor = Colors.grey;
    }


    buttonWidget = Container(
        child: Icon(buttonIcon, color: buttonColor)
    );

    children.add(buttonWidget);

    return Container(
      constraints: BoxConstraints(
        maxHeight: 44,
        minHeight: 44.0,
        minWidth: 32.0
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: children,
          ),
        ),
      ),
    );
  }
}