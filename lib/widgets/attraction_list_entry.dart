import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/attraction_structures.dart';

class AttractionListEntry extends StatelessWidget {
  AttractionListEntry(
      {this.attractionData,
      this.buttonWidget,
      this.ignored,
      this.slidableController,
      this.ignoreCallback});

  final BluehostAttraction attractionData;
  final Widget buttonWidget;
  final bool ignored;
  final SlidableController slidableController;
  final Function(BluehostAttraction, bool) ignoreCallback;

  @override
  Widget build(BuildContext context) {
    Widget built;

    Color tileColor = ignored || !attractionData.active
        ? Theme.of(context).disabledColor
        : Colors.white;


    // Core layout of the row / list item.
    built = Container(
      color: tileColor,
      constraints: BoxConstraints.expand(height: 58.0),
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // The text should take up as much space as possible, but not overflow under the button
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AutoSizeText(
                attractionData.attractionName,
                maxLines: 1,
                style: Theme.of(context).textTheme.subhead,
              ),
              AutoSizeText(attractionData.typeLabel,
                  maxLines: 1, style: Theme.of(context).textTheme.subtitle)
            ],
          )),
          // If the button's not there for any reason, just show an empty container instead. Prevents null errors.
          buttonWidget ?? Container()
        ],
      ),
    );

    // Logic for selecting whether or not there are any slide interactions with
    // this list entry.
    Widget slideAction;
    if (!attractionData.active) slideAction = null; // Already ignored thanks to defunct, no point in ignoring it more
    if (attractionData.active) {
      // If we're ignored, show the include slide. If we're included, show the ignore slide.
      slideAction =
          ignored ? _buildIncludeSlideAction() : _buildIgnoreSlideAction();
    }

    // This is kinda ugly, but if there's no action that happens on slide,
    // we simply don't make the row a slidable row.
    return slideAction == null
        ? built
        : Slidable(
            delegate: SlidableDrawerDelegate(),
            actionExtentRatio: 0.25,
            child: built,
            actions: <Widget>[slideAction],
            controller: slidableController,
            // TODO: Insert unique key if needed.
          );
  }

  Widget _buildIgnoreSlideAction() {
    return IconSlideAction(
      icon: FontAwesomeIcons.ban,
      color: Color.fromARGB(255, 221, 222, 224),
      caption: "Ignore",
      onTap: () => ignoreCallback(this.attractionData, ignored),
    );
  }

  Widget _buildIncludeSlideAction() {
    return IconSlideAction(
      icon: FontAwesomeIcons.check,
      color: Color.fromARGB(255, 135, 207, 129),
      caption: "Include",
      onTap: () => ignoreCallback(this.attractionData, ignored),
    );
  }

  void _onInfoTap() {
    //TODO: Open attraction info panel
    print(
        "NOT YET IMPLEMENTED: Thomas, open an attraction panel for ${this.attractionData.attractionName}");
  }
}
