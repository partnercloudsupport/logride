import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/widgets/attractions_page/experience_button.dart';
import 'package:log_ride/ui/details_page.dart';

class AttractionListEntry extends StatefulWidget {
  AttractionListEntry(
      {this.attractionData,
      this.userData,
      this.slidableController,
      this.ignoreCallback,
      this.experienceHandler,
      this.parentPark,
      this.timeChanged,
      this.db,
      this.submissionCallback});

  final BluehostAttraction attractionData;
  final FirebaseAttraction userData;
  final FirebasePark parentPark;
  final SlidableController slidableController;
  final Function(BluehostAttraction, bool) ignoreCallback;
  final Function(ExperienceAction, FirebaseAttraction) experienceHandler;
  final Function(DateTime, FirebaseAttraction, bool) timeChanged;
  final Function(dynamic) submissionCallback;
  final BaseDB db;

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
                  Text(
                    widget.attractionData.attractionName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Text( widget.attractionData.upcoming
                      ? "Opening Soon"
                      : widget.attractionData.typeLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle
                          .apply(color: Colors.grey[700]))
                ],
              )),
              // If the button's not there for any reason, just show an empty container instead. Prevents null errors.
              ExperienceButton(
                interactHandler: widget.experienceHandler,
                parentPark: widget.parentPark,
                ignored: (widget.attractionData.seasonal || !widget.attractionData.active) ? false : (ignored ?? false),
                upcoming: widget.attractionData.upcoming,
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
    if (!widget.attractionData.active || widget.attractionData.seasonal || widget.attractionData.upcoming)
      slideAction =
          null; // Already ignored thanks to defunct, no point in ignoring it more
    if (widget.attractionData.active && !widget.attractionData.seasonal && !widget.attractionData.upcoming) {
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
    Navigator.push(
        context,
        SlideInRoute(
            direction: SlideInDirection.UP,
            dialogStyle: true,
            widget: DetailsPage(
              data: widget.attractionData,
              db: widget.db,
              userData: widget.userData,
              submissionCallback: widget.submissionCallback,
              dateChangeHandler: (first, newTime) =>
                  widget.timeChanged(newTime, widget.userData, first),
            )));
  }
}
