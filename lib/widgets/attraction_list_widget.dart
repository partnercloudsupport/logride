import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../data/attraction_structures.dart';
import '../data/park_structures.dart';
import '../data/parks_manager.dart';
import '../data/fbdb_manager.dart';
import '../widgets/experience_button.dart';
import '../widgets/firebase_attraction_list.dart';
import '../widgets/set_experience_box.dart';

class AttractionsListView extends StatefulWidget {
  AttractionsListView(
      {this.sourceAttractions,
      this.db,
      this.pm,
      this.slidableController,
      this.parentPark});

  final List<BluehostAttraction> sourceAttractions;
  final BaseDB db;
  final ParksManager pm;
  final FirebasePark parentPark;
  final SlidableController slidableController;

  @override
  _AttractionsListViewState createState() => _AttractionsListViewState();
}

class _AttractionsListViewState extends State<AttractionsListView> {
  Map<String, List<BluehostAttraction>> displayLists;
  List<int> ignoreList;

  List<FirebaseAttraction> fullList;

  List<dynamic> headedList;

  Map<String, List<BluehostAttraction>> _buildPreparedList() {
    headedList = List<dynamic>();

    List<BluehostAttraction> activeList = List<BluehostAttraction>(),
        seasonalList = List<BluehostAttraction>(),
        defunctList = List<BluehostAttraction>();

    // Split each attraction into their separate lists
    for (int i = 0; i < widget.sourceAttractions.length; i++) {
      if (widget.sourceAttractions[i].active) {
        if(widget.sourceAttractions[i].seasonal) {
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
    print("SeasonalList => Data: $_hasSeasonal | Length: ${seasonalList.length}");
    print("DefunctList => Data: $_hasDefunct | Length: ${defunctList.length}");

    Map<String, List<BluehostAttraction>> returnMap = Map();

    if (_hasActive) returnMap["Active"] = activeList;
    if (_hasSeasonal) returnMap["Seasonal"] = seasonalList;
    if (_hasDefunct) returnMap["Defunct"] = defunctList;

    // Strings are used as headers for the list. These are checked for in the
    // Build functions for the listview.

    if (_hasActive) {
      headedList.add("Active");
      headedList.addAll(activeList);
    }

    if (_hasSeasonal) {
      headedList.add("Seasonal");
      headedList.addAll(seasonalList);
    }

    if (_hasDefunct) {
      headedList.add("Defunct");
      headedList.addAll(defunctList);
    }


    return returnMap;
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

  // Load all
  @override
  void initState() {
    super.initState();

    displayLists = _buildPreparedList();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
        child: FirebaseAttractionListView(
          parentPark: widget.parentPark,
          headedList: headedList,
          attractionQuery: widget.db.getQueryForUser(
              path: DatabasePath.ATTRACTIONS,
              key: widget.parentPark.parkID.toString()),
          ignoreQuery: widget.db.getQueryForUser(
              path: DatabasePath.IGNORE,
              key: widget.parentPark.parkID.toString()),
          interactHandler: experienceCallbackHandler,
          ignoreCallback: _ignoreCallbackHandler,
        ));
  }

  void experienceCallbackHandler(
      ExperienceAction action, FirebaseAttraction data) async {
    print("Callback triggered");
    switch (action) {
      case ExperienceAction.SET:

        // You can't set the value if it's just toggleable.
        if (!widget.parentPark.incrementorEnabled) return;

        int result = await showDialog(
            context: context,
            builder: (BuildContext context) =>
                SetExperienceDialogBox(data.numberOfTimesRidden ?? 0));

        if (result == null) return;
        if (result == data.numberOfTimesRidden) return;

        data.numberOfTimesRidden = result;

        widget.db.setEntryAtPath(
            path: DatabasePath.ATTRACTIONS,
            key: widget.parentPark.parkID.toString() +
                "/" +
                data.rideID.toString(),
            payload: data.toMap());
        break;

      case ExperienceAction.ADD:

        // Use of a transaction here prevents any possible race conditions from occurring
        widget.db.performTransaction(path: DatabasePath.ATTRACTIONS, key: widget.parentPark.parkID.toString()+"/"+data.rideID.toString(), transactionHandler: (transaction) {

          // If there's currently no entry in the firebase for this attraction,
          // our value will be null. In this case, we're relying on our backup
          // local data.
          FirebaseAttraction attraction;
          if(transaction.value == null){
            attraction = data;
          } else {
            attraction = FirebaseAttraction.fromMap(Map.from(transaction.value));
          }

          // If we're not using the incrementor, we'll be toggling the number of times ridden.
          if(!widget.parentPark.incrementorEnabled){
            attraction.numberOfTimesRidden = (attraction.numberOfTimesRidden== 0) ? 1 : 0;
          } else {
            attraction.numberOfTimesRidden = attraction.numberOfTimesRidden + 1;
          }

          // Return it back to the map/json form before giving it back to the transaction
          transaction.value = attraction.toMap();
          return transaction;
        });
        break;

      case ExperienceAction.REMOVE:
        // TODO - Improve speed of interaction
        // We don't want this going negative.
        if (data.numberOfTimesRidden > 0) {
          data.numberOfTimesRidden--;
          widget.db.setEntryAtPath(
              path: DatabasePath.ATTRACTIONS,
              key: widget.parentPark.parkID.toString() +
                  "/" +
                  data.rideID.toString(),
              payload: data.toMap());
        }
        break;
    }
  }
}
