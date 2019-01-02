import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../data/attraction_structures.dart';
import '../data/park_structures.dart';
import '../data/fbdb_manager.dart';
import '../widgets/attraction_list_entry.dart';
import '../widgets/experience_button.dart';

class AttractionsListView extends StatefulWidget {
  AttractionsListView({this.sourceAttractions, this.db, this.parentPark});

  final List<BluehostAttraction> sourceAttractions;
  final BaseDB db;
  final FirebasePark parentPark;

  @override
  _AttractionsListViewState createState() => _AttractionsListViewState();
}

class _AttractionsListViewState extends State<AttractionsListView> {
  Map<String, List<BluehostAttraction>> displayLists;
  Stream<Event> _attractionsStream;
  SlidableController _slidableController;

  bool _hasActive = false;
  bool _hasDefunct = false;

  Map<String, List<BluehostAttraction>> _buildPreparedList() {
    List<BluehostAttraction> activeList = List<BluehostAttraction>(),
        seasonalList = List<BluehostAttraction>(),
        defunctList = List<BluehostAttraction>(),
        ignoredList = List<BluehostAttraction>();
    // Split each attraction into their separate lists (NOTE: SEASONAL IS NOT IMPLEMENTED YET)
    // TODO: Seasonal, once data is in place
    // TODO: Ignored, once database is integrated
    for (int i = 0; i < widget.sourceAttractions.length; i++) {
      if (widget.sourceAttractions[i].active == true) {
        activeList.add(widget.sourceAttractions[i]);
      } else {
        defunctList.add(widget.sourceAttractions[i]);
      }
    }

    int attractionComparator(BluehostAttraction b1, BluehostAttraction b2) {
      return b1.attractionName.compareTo(b2.attractionName);
    }

    activeList.sort(attractionComparator);
    defunctList.sort(attractionComparator);

    _hasActive = (activeList.length != 0);
    _hasDefunct = (defunctList.length != 0);

    print("ActiveList => Data: $_hasActive | Length: ${activeList.length}");
    print("DefunctList => Data: $_hasDefunct | Length: ${defunctList.length}");

    Map<String, List<BluehostAttraction>> returnMap = Map();

    if (_hasActive) returnMap["Active"] = activeList;
    if (_hasDefunct) returnMap["Defunct"] = defunctList;

    // Strings are used as headers for the list. These are checked for in the
    // Build functions for the listview.
    return returnMap;
  }

  // Load all
  @override
  void initState() {
    displayLists = _buildPreparedList();
    _attractionsStream = widget.db.getLiveEntryAtPath(
        path: DatabasePath.ATTRACTIONS,
        key: widget.parentPark.parkID.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _attractionsStream,
      builder: (context, AsyncSnapshot<Event> snap) {
        print(snap.data?.snapshot?.value ??
            "User data for this park hasn't loaded yet");

        //  We're attempting to convert the event into the appropriate user data.
        // If the data doesn't exist, we'll just have an empty list. If the data doesn't
        // exist for a park, we'll pass null to the button. Simple.
        List<FirebaseAttraction> userData = List<FirebaseAttraction>();
        (snap.data?.snapshot?.value as Map)?.forEach((key, value) {
          return userData.add(FirebaseAttraction.fromMap(Map.from(value)));
        });

        return ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
            child: ListView.builder(
                itemCount: displayLists.keys.length,
                itemBuilder: (BuildContext context, int index) {
                  String key = displayLists.keys.elementAt(index);
                  return StickyHeader(
                      header: _listHeader(context, key),
                      content: _sectionContent(
                          context, displayLists[key], userData));
                }));
      },
    );
  }

  Widget _listHeader(BuildContext context, String text) {
    return Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(text),
        ),
        height: 20,
        color: Colors.grey[200]);
  }

  Widget _sectionContent(BuildContext context,
      List<BluehostAttraction> attractions, List<FirebaseAttraction> userData) {
    return Column(
        children: List.generate(attractions.length, (int index) {
          BluehostAttraction serverData = attractions[index];
          FirebaseAttraction entryData = getFirebaseAttractionFromList(userData, serverData.attractionID) ?? FirebaseAttraction(rideID: serverData.attractionID);
      return AttractionListEntry(
        attractionData: serverData,
        slidableController: _slidableController,
        ignoreCallback: (attraction) => print("ignored"),
        ignored: false,
        buttonWidget: ExperienceButton(
          data: entryData,
          enabled: serverData.active,
        ),
      );
    }));
  }
}
