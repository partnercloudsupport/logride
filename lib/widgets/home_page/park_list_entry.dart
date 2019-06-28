import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/widgets/shared/progress_bars.dart';
import 'package:log_ride/data/park_structures.dart';

enum ParkSlideActionType { faveAdd, faveRemove, delete }

/// ParkListEntry is a stateless widget that displays park information,
/// including name, location, and ride completion progress.
/// [parkData] - ParkListData that stores relevant park information
/// [onTap] - Function that will be called once the entry is tapped
class ParkListEntry extends StatelessWidget {
  const ParkListEntry(
      {Key key,
      this.parkData,
      this.onTap,
      this.slidableController,
      this.sliderActionCallback})
      : super(key: key);

  final FirebasePark parkData;
  final Function(FirebasePark data) onTap;
  final Function(ParkSlideActionType actionType, FirebasePark data)
      sliderActionCallback;

  final SlidableController
      slidableController; // Listen, Intellij, I know it's spelled wrong. But I'm matching the package's mistake, see?

  @override
  Widget build(BuildContext context) {
    // Avoid issues where null parks can possibly appear.
    if (parkData == null || parkData.parkID == null) {
      return Container();
    }

    Widget leftAction;
    Widget rightAction;

    // If the park is a favorite, we don't want the user to see that they can
    // add it again. Instead, we provide them the action to remove it from favorites
    leftAction = !parkData.favorite
        ? IconSlideAction(
            caption: "Favorite",
            color: Colors.green,
            icon: Icons.star_border,
            onTap: () =>
                sliderActionCallback(ParkSlideActionType.faveAdd, parkData),
          )
        : IconSlideAction(
            caption: "Remove",
            color: Colors.green,
            icon: Icons.star,
            onTap: () =>
                sliderActionCallback(ParkSlideActionType.faveRemove, parkData));

    rightAction = IconSlideAction(
      caption: "Delete Park",
      color: Colors.red,
      icon: Icons.delete,
      onTap: () => sliderActionCallback(ParkSlideActionType.delete, parkData),
    );

    Widget headerStar = Container();

    if (parkData.favorite) {
      headerStar = Icon(Icons.star,
          color: parkData.inFavorites ? PROGRESS_BAR_GOLD : PROGRESS_BAR_BACKING,
          size: Theme.of(context).textTheme.subhead.fontSize * 1.5);
      headerStar = Padding(
        child: headerStar,
        padding: const EdgeInsets.only(right: 8.0),
      );
    }

    return Slidable(
      key: ValueKey(parkData.parkID),
      actionPane: SlidableDrawerActionPane(),
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
                      Text(
                        parkData.name,
                        style: Theme.of(context).textTheme.subhead,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        parkData.location,
                        style: Theme.of(context).textTheme.subtitle,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                headerStar,
                ParkProgressListItem(
                    numRides: parkData.totalRides,
                    numRidden: parkData.ridesRidden)
              ],
            )),
        onTap: () {
          onTap(parkData);
        },
      ),
      actions: <Widget>[leftAction],
      secondaryActions: <Widget>[rightAction],
      controller: slidableController,
    );
  }
}
