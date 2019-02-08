import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/park_structures.dart';

enum ExperienceAction { ADD, REMOVE, SET }

class ExperienceButton extends StatelessWidget {
  ExperienceButton(
      {this.parentPark, this.data, this.ignored, this.interactHandler});

  final FirebasePark parentPark;
  final FirebaseAttraction data;
  final bool ignored;
  final Function(ExperienceAction, FirebaseAttraction) interactHandler;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List<Widget>();
    Widget buttonWidget;
    Container textDisplay;

    /// Experience buttons are built as a list of widgets inside a card.

    /// First module - text display. Only used when the user has it set and
    /// when there's text to display

    // We only want the text to display if there exists a count on the button
    if (data.numberOfTimesRidden > 0 && parentPark.incrementorEnabled) {
      textDisplay = Container(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(data.numberOfTimesRidden.toString(),
            textAlign: TextAlign.right, textScaleFactor: 1.3),
      ));
      children.add(textDisplay);
    }

    /// Establishing button style - used for showing the user exactly what's going on

    Color buttonColor;
    Widget iconWidget;

    // Text will display regardless of enabled. Our button, however, does differ

    if (!ignored) {
      buttonColor = Theme.of(context).primaryColor;
      if (data.numberOfTimesRidden > 0) {
        // Plus button is displayed when there's at least one count and incrementor isn't on
        iconWidget = Icon(
          parentPark.incrementorEnabled
              ? FontAwesomeIcons.plusCircle
              : FontAwesomeIcons.solidCheckCircle,
          color: buttonColor,
          size: 32.0,
        );
      } else {
        // iOS has a circle with a border. I can't do that easily with icons,
        // so I just stacked two appropriate ones on top of each other.
        // The padding inset of 2 is used to mimic the other normal icons appropriately.
        iconWidget = Padding(
          padding: EdgeInsets.all(2.0),
          child: Stack(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.solidCircle,
                color: Color.fromARGB(255, 135, 207, 129),
                size: 32.0,
              ),
              Icon(FontAwesomeIcons.circle, color: buttonColor, size: 32.0)
            ],
          ),
        );
      }
    } else {
      // X-button is displayed when the ride is ignored
      iconWidget = Icon(
        FontAwesomeIcons.solidTimesCircle,
        color: Colors.grey,
        size: 32.0,
      );
    }

    buttonWidget = AspectRatio(
      aspectRatio: 1.0,
      child: iconWidget,
    );

    children.add(buttonWidget);

    /// Note about latency
    /// With any gesturedetector (as an inkwell is), behavior varies depending on
    /// whether or not logic for doubletap is present. If it is, there'll be a
    /// delay before onTap is called so it can check if the onTap is satisfied.
    ///
    /// This is unfortunate, as it makes onTap feel slow

    return Container(
      constraints:
          BoxConstraints(maxHeight: 44, minHeight: 44.0, minWidth: 32.0),
      child: Card(
        child: InkWell(
          child: Row(
            children: children,
          ),
          onTap: () => interactHandler(ExperienceAction.ADD, data),
          //onDoubleTap: () => interactHandler(ExperienceAction.SET, data),
          onLongPress: () => interactHandler(ExperienceAction.SET,
              data), // If a user wants to remove a value, they have to set it. I doubt they use the single remove often.
        ),
      ),
    );
  }
}
