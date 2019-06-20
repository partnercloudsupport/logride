import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/scorecard_structures.dart';
import 'package:log_ride/ui/dialogs/single_value_dialog.dart';
import 'package:log_ride/widgets/attractions_page/experience_button.dart';
import 'package:log_ride/widgets/attractions_page/firebase_attraction_list.dart';
import 'package:log_ride/widgets/dialogs/set_experience_box.dart';

class AttractionsListView extends StatefulWidget {
  AttractionsListView(
      {this.sourceAttractions,
      this.db,
      this.pm,
      this.slidableController,
      this.parentPark,
      this.submissionCallback, this.userName});

  final List<BluehostAttraction> sourceAttractions;
  final BaseDB db;
  final ParksManager pm;
  final FirebasePark parentPark;
  final SlidableController slidableController;
  final Function(dynamic, bool) submissionCallback;

  final String userName;

  @override
  _AttractionsListViewState createState() => _AttractionsListViewState();
}

class _AttractionsListViewState extends State<AttractionsListView> {
  Map<String, List<BluehostAttraction>> headedList;

  void _buildPreparedList() {
    headedList = Map<String, List<BluehostAttraction>>();

    List<BluehostAttraction> activeList = List<BluehostAttraction>(),
        seasonalList = List<BluehostAttraction>(),
        defunctList = List<BluehostAttraction>();

    // Split each attraction into their separate lists
    for (int i = 0; i < widget.sourceAttractions.length; i++) {
      if (widget.sourceAttractions[i].active) {
        if (widget.sourceAttractions[i].seasonal) {
          seasonalList.add(widget.sourceAttractions[i]);
        } else {
          activeList.add(widget.sourceAttractions[i]);
        }
      } else {
        defunctList.add(widget.sourceAttractions[i]);
      }
    }

    int attractionComparator(BluehostAttraction b1, BluehostAttraction b2) {
      return b1.attractionName.compareTo(b2.attractionName);
    }

    activeList.sort(attractionComparator);
    seasonalList.sort(attractionComparator);
    defunctList.sort(attractionComparator);

    bool _hasActive = (activeList.length != 0);
    bool _hasSeasonal = (seasonalList.length != 0);
    bool _hasDefunct = (defunctList.length != 0);

    print("ActiveList => Data: $_hasActive | Length: ${activeList.length}");
    print(
        "SeasonalList => Data: $_hasSeasonal | Length: ${seasonalList.length}");
    print("DefunctList => Data: $_hasDefunct | Length: ${defunctList.length}");

    // Strings are used as headers for the list. These are checked for in the
    // Build functions for the listview.

    if (_hasActive) {
      headedList["Active"] = activeList;
    }

    if (_hasSeasonal) {
      headedList["Seasonal"] = seasonalList;
    }

    if (_hasDefunct) {
      headedList["Defunct"] = defunctList;
    }
  }

  /// Simple function that sets the value of the current state to the inverse of whatever it currently is for the user.
  void _ignoreCallbackHandler(
      BluehostAttraction attraction, bool currentIgnoreState) async {
    String targetKey = [
      widget.parentPark.parkID.toString(),
      attraction.attractionID.toString(),
      "rideID"
    ].join("/");
    // If we're ignored, we need to remove our self from the ignore list. If not, we add ourselves to it.
    if (currentIgnoreState) {
      widget.db.removeEntryFromPath(path: DatabasePath.IGNORE, key: targetKey);
    } else {
      widget.db.setEntryAtPath(
          path: DatabasePath.IGNORE,
          key: targetKey,
          payload: attraction.attractionID);
    }
  }

  void _updateCountHandler(
      List<FirebaseAttraction> userRides, List<int> userIgnored) {
    widget.pm.updateAttractionCount(widget.parentPark, userIgnored, userRides);
  }

  void _experienceCallbackHandler(
      ExperienceAction action, FirebaseAttraction data) async {
    switch (action) {
      case ExperienceAction.SET:
        // You can't set the value if it's just toggleable.
        if (!widget.parentPark.incrementorEnabled) return;

        // Storing this for comparison later
        int oldValue = data.numberOfTimesRidden ?? 0;

        int result = await showDialog(
            context: context,
            builder: (BuildContext context) =>
                SetExperienceDialogBox(data.numberOfTimesRidden ?? 0));

        // Don't do anything if there's no change or repsonse
        if (result == null) return;
        if (result == data.numberOfTimesRidden) return;

        data.numberOfTimesRidden = result;

        // If our new result isn't zero and we used to be zero, we're first-timers and need to set our first ride date.
        if (oldValue == 0 && result != 0) {
          data.firstRideDate = DateTime.now();
          // Now, we could go through and ask for scoreboard scores, but the likelihood is that a user setting a score will go back and add their own scores manually
        }

        // If we're resetting our progress for this attraction, we're resetting our first ride date and last ride date
        if (result == 0) {
          data.firstRideDate = DateTime.fromMillisecondsSinceEpoch(0);
          data.lastRideDate = DateTime.fromMillisecondsSinceEpoch(0);
        }

        widget.db.setEntryAtPath(
            path: DatabasePath.ATTRACTIONS,
            key: widget.parentPark.parkID.toString() +
                "/" +
                data.rideID.toString(),
            payload: data.toMap());
        break;

      case ExperienceAction.ADD:
        BluehostAttraction attr = getBluehostAttractionFromList(
            widget.sourceAttractions, data.rideID);

        // Use of a transaction here prevents any possible race conditions from occurring
        widget.db.performTransaction(
            path: DatabasePath.ATTRACTIONS,
            key: widget.parentPark.parkID.toString() +
                "/" +
                data.rideID.toString(),
            transactionHandler: (transaction) {
              // If there's currently no entry in the firebase for this attraction,
              // our value will be null. In this case, we're relying on our backup
              // local data.
              FirebaseAttraction attraction;
              if (transaction.value == null) {
                attraction = data;
              } else {
                attraction =
                    FirebaseAttraction.fromMap(Map.from(transaction.value));
              }

              // If we're not using the incrementor, we'll be toggling the number of times ridden.
              if (!widget.parentPark.incrementorEnabled) {
                bool notRiddenYet = (attraction.numberOfTimesRidden == 0);
                attraction.numberOfTimesRidden = notRiddenYet ? 1 : 0;

                if (notRiddenYet && attr.scoreCard) _collectScore(attraction);
              } else {
                attraction.numberOfTimesRidden =
                    attraction.numberOfTimesRidden + 1;

                if (attr.scoreCard) _collectScore(attraction);
              }

              attraction.lastRideDate = DateTime.now();
              if (attraction.firstRideDate ==
                  DateTime.fromMillisecondsSinceEpoch(0))
                attraction.firstRideDate = DateTime.now();

              // Return it back to the map/json form before giving it back to the transaction
              transaction.value = attraction.toMap();
              return transaction;
            });
        break;
      case ExperienceAction.REMOVE:

        // We don't want this going negative.
        if (data.numberOfTimesRidden < 1) {
          break;
        }

        widget.db.performTransaction(
            path: DatabasePath.ATTRACTIONS,
            key: widget.parentPark.parkID.toString() +
                "/" +
                data.rideID.toString(),
            transactionHandler: (transaction) {
              // If there's currently no entry in the firebase for this attraction,
              // our value will be null. In this case, we're relying on our backup
              // local data.
              FirebaseAttraction attraction;
              if (transaction.value == null) {
                attraction = data;
              } else {
                attraction =
                    FirebaseAttraction.fromMap(Map.from(transaction.value));
              }


              // If we're not using the incrementor, we'll be setting the number of time ridden to zero
              if (!widget.parentPark.incrementorEnabled) {
                attraction.numberOfTimesRidden = 0;
              } else {
                attraction.numberOfTimesRidden =
                    attraction.numberOfTimesRidden - 1;
              }

              // Return it back to the map/json form before giving it back to the transaction
              transaction.value = attraction.toMap();
              return transaction;
            });
        break;
    }
  }

  void _collectScore(FirebaseAttraction data) async {
    dynamic result = await showDialog(
        context: context,
        builder: (BuildContext context) => SingleValueDialog(
              type: SingleValueDialogType.NUMBER,
              submitText: "SUBMIT",
              title: "Submit Today's New Score",
            ));

    if (result == null) return;

    ScorecardEntry newScore = ScorecardEntry(
        time: DateTime.now(), score: result as num, rideID: data.rideID);

    widget.db.setEntryAtPath(
        path: DatabasePath.SCORECARD,
        key:
            "${widget.parentPark.parkID}/${data.rideID}/${newScore.time.millisecondsSinceEpoch ~/ 1000}",
        payload: newScore.toMap());
  }

  void _dateUpdateHandler(
      DateTime newDate, FirebaseAttraction data, bool first) async {
    if (first) {
      data.firstRideDate = newDate;
    } else {
      data.lastRideDate = newDate;
    }

    widget.db.setEntryAtPath(
        path: DatabasePath.ATTRACTIONS,
        key: widget.parentPark.parkID.toString() + "/" + data.rideID.toString(),
        payload: data.toMap());
  }

  // Load all
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _buildPreparedList();
    return ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
        child: FirebaseAttractionListView(
          parentPark: widget.parentPark,
          parentParkData: getBluehostParkByID(widget.pm.allParksInfo, widget.parentPark.parkID),
          headedList: headedList,
          userName: widget.userName,
          attractionQuery: widget.db.getQueryForUser(
              path: DatabasePath.ATTRACTIONS,
              key: widget.parentPark.parkID.toString()),
          ignoreQuery: widget.db.getQueryForUser(
              path: DatabasePath.IGNORE,
              key: widget.parentPark.parkID.toString()),
          experienceHandler: _experienceCallbackHandler,
          ignoreCallback: _ignoreCallbackHandler,
          submissionCallback: widget.submissionCallback,
          countHandler: _updateCountHandler,
          dateHandler: _dateUpdateHandler,
          db: widget.db,
        ));
  }
}
