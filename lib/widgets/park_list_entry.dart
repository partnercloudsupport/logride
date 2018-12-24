import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:after_layout/after_layout.dart';
import 'park_progress.dart';
import '../data/park_structures.dart';

enum ParkSlideActionType { faveAdd, faveRemove, delete }

class ParkListEntry extends StatefulWidget {
  const ParkListEntry(
      {Key key,
        this.parkData,
      this.onTap,
      this.inFavorites,
      this.slidableController,
      this.sliderActionCallback}) : super(key: key);

  final ParkData parkData;
  final bool inFavorites;
  final Function(ParkData data) onTap;
  final Function(ParkSlideActionType actionType, ParkData data)
      sliderActionCallback;

  final SlidableController
      slidableController; // Listen, Intellij, I know it's spelled wrong. But I'm matching the package's mistake, see?

  @override
  _ParkListState createState() => _ParkListState();
}

/// ParkListEntry is a stateless widget that displays park information,
/// including name, location, and ride completion progress.
/// [parkData] - ParkListData that stores relevant park information
/// [onTap] - Function that will be called once the entry is tapped
class _ParkListState extends State<ParkListEntry> with AfterLayoutMixin<ParkListEntry> {
  double _opacity = 0.0;

  @override
  void afterFirstLayout(BuildContext context){
    setState((){
      _opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget leftAction;
    Widget rightAction;

    if (widget.inFavorites) {
      leftAction = IconSlideAction(
        caption: "Remove",
        color: Colors.green,
        icon: Icons.star,
        onTap: () =>
            widget.sliderActionCallback(ParkSlideActionType.faveRemove, widget.parkData),
      );
      rightAction = IconSlideAction(
        caption: "Remove",
        color: Colors.green,
        icon: Icons.star,
        onTap: () =>
            widget.sliderActionCallback(ParkSlideActionType.faveRemove, widget.parkData),
      );
    } else {
      // If the park is a favorite, we don't want the user to see that they can
      // add it again. Instead, we provide them the action to remove it from favorites
      leftAction = !widget.parkData.favorite
          ? IconSlideAction(
              caption: "Favorite",
              color: Colors.green,
              icon: Icons.star_border,
              onTap: () =>
                  widget.sliderActionCallback(ParkSlideActionType.faveAdd, widget.parkData),
            )
          : IconSlideAction(
              caption: "Remove",
              color: Colors.green,
              icon: Icons.star,
              onTap: () => widget.sliderActionCallback(
                  ParkSlideActionType.faveRemove, widget.parkData));
      rightAction = IconSlideAction(
        caption: "Delete Stats",
        color: Colors.red,
        icon: Icons.delete,
        onTap: () => widget.sliderActionCallback(ParkSlideActionType.delete, widget.parkData),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: _opacity,
      child: Slidable(
          delegate: SlidableDrawerDelegate(),
          actionExtentRatio: 0.25,
          child: InkWell(
            child: Container(
                // Vertical padding is added to bump the content down below the button
                constraints: BoxConstraints.expand(height: 58),
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // AutoSizeText is used to avoid overflow, since park names
                          // and locations may have unknown lengths.
                          AutoSizeText(
                            widget.parkData.parkName,
                            style: Theme.of(context).textTheme.subhead,
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            widget.parkData.parkCity,
                            style: Theme.of(context).textTheme.subtitle,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                    ParkProgress(
                        numRides: widget.parkData.numAttractions - widget.parkData.numDefunct,
                        numRidden: 0)
                  ],
                )),
            onTap: () {
              widget.onTap(widget.parkData);
            },
            //behavior: HitTestBehavior.opaque,
          ),
          actions: <Widget>[leftAction],
          secondaryActions: <Widget>[rightAction],
          controller: widget.slidableController,
          key: Key(widget.parkData.parkName + widget.inFavorites.toString())),
    );
  }

  @override
  // TODO: implement mounted
  bool get mounted => super.mounted;
}
