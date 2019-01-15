import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/attraction_structures.dart';
import '../data/park_structures.dart';
import '../widgets/experience_button.dart';

class AttractionListEntry extends StatefulWidget {
  AttractionListEntry(
      {this.attractionData,
      this.userData,
      this.slidableController,
      this.ignoreCallback,
      this.experienceHandler,
      this.parentPark});

  final BluehostAttraction attractionData;
  final FirebaseAttraction userData;
  final FirebasePark parentPark;
  final SlidableController slidableController;
  final Function(BluehostAttraction, bool) ignoreCallback;
  final Function(ExperienceAction, FirebaseAttraction) experienceHandler;

  @override
  State<StatefulWidget> createState() => AttractionListState();
}

class AttractionListState extends State<AttractionListEntry> {
  @override
  Widget build(BuildContext context) {
    Widget built;

    bool ignored = widget.userData.ignored;

    Color tileColor = ignored || !widget.attractionData.active
        ? Theme.of(context).disabledColor
        : Colors.white;

    // Core layout of the row / list item.
    built = Material(
      color: tileColor,
      child: InkWell(
        onTap: _onInfoTap,
        child: Container(
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
                    widget.attractionData.attractionName,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  AutoSizeText(widget.attractionData.typeLabel,
                      maxLines: 1, style: Theme.of(context).textTheme.subtitle)
                ],
              )),
              // If the button's not there for any reason, just show an empty container instead. Prevents null errors.
              ExperienceButton(
                interactHandler: widget.experienceHandler,
                parentPark: widget.parentPark,
                ignored: ignored ?? false,
                data: widget.userData ??
                    FirebaseAttraction(
                        rideID: widget.attractionData.attractionID),
              )
            ],
          ),
        ),
      ),
    );

    // Logic for selecting whether or not there are any slide interactions with
    // this list entry.
    Widget slideAction;
    if (!widget.attractionData.active)
      slideAction =
          null; // Already ignored thanks to defunct, no point in ignoring it more
    if (widget.attractionData.active) {
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
            controller: widget.slidableController,
          );
  }

  Widget _buildIgnoreSlideAction() {
    return IconSlideAction(
      icon: FontAwesomeIcons.ban,
      color: Color.fromARGB(255, 221, 222, 224),
      caption: "Ignore",
      onTap: () =>
          widget.ignoreCallback(widget.attractionData, widget.userData.ignored),
    );
  }

  Widget _buildIncludeSlideAction() {
    return IconSlideAction(
      icon: FontAwesomeIcons.check,
      color: Color.fromARGB(255, 135, 207, 129),
      caption: "Include",
      onTap: () =>
          widget.ignoreCallback(widget.attractionData, widget.userData.ignored),
    );
  }

  void _onInfoTap() {
    print(
        "NOT YET IMPLEMENTED: Thomas, open an attraction panel for ${widget.attractionData.attractionName}");
  }
}
