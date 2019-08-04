import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/search_comparators.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:log_ride/widgets/attractions_page/attraction_list_entry.dart';
import 'package:log_ride/widgets/attractions_page/experience_button.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

class AttractionFilter extends ValueNotifier<String> {
  AttractionFilter(String value) : super(value);
}

class FirebaseAttractionListView extends StatefulWidget {
  FirebaseAttractionListView(
      {this.attractionQuery,
      this.ignoreQuery,
      this.headedList,
      this.parentPark,
      this.parentParkData,
      this.ignoreCallback,
      this.experienceHandler,
      this.countHandler,
      this.dateHandler,
      this.db,
      this.submissionCallback});

  final Query attractionQuery;
  final Query ignoreQuery;

  final Map<String, List<BluehostAttraction>> headedList;
  final FirebasePark parentPark;
  final BluehostPark parentParkData;

  final Function(BluehostAttraction target, bool currentState) ignoreCallback;
  final Function(ExperienceAction, FirebaseAttraction) experienceHandler;
  final Function(List<FirebaseAttraction> userData, List<int> ignoreData)
      countHandler;
  final Function(DateTime, FirebaseAttraction, bool) dateHandler;
  final Function(dynamic, bool, LogRideUser) submissionCallback;

  final BaseDB db;

  @override
  _FirebaseAttractionListViewState createState() =>
      _FirebaseAttractionListViewState();
}

class _FirebaseAttractionListViewState
    extends State<FirebaseAttractionListView> {
  AttractionFilter filter = AttractionFilter("");

  bool _delayOver = false;

  // This allows us to hide the search entry until the user pulls down to access it.
  ScrollController controller = ScrollController(initialScrollOffset: 67.0);
  TextEditingController _searchController = TextEditingController();

  FirebaseList _attractionList;
  FirebaseList _ignoreList;

  List<FirebaseAttraction> _builtAttractionList;
  List<int> _builtIgnoreList;
  List<dynamic> _builtDisplayList;

  bool _ignoreLoaded = false;
  bool _attractionLoaded = false;

  final SlidableController _slidableController = SlidableController();

  void _onAttractionAdded(int index, DataSnapshot snap) {
    if (!_attractionLoaded) return;
    if (mounted) setState(() {});
  }

  void _onAttractionRemoved(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onAttractionChanged(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onAttractionValue(DataSnapshot snap) {
    if (mounted)
      setState(() {
        _attractionLoaded = true;
      });
  }

  void _onIgnoreAdded(int index, DataSnapshot snap) {
    if (!_ignoreLoaded) return;
    if (mounted) setState(() {});
  }

  void _onIgnoreRemoved(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onIgnoreChanged(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onIgnoreValue(DataSnapshot snap) {
    if (mounted)
      setState(() {
        _ignoreLoaded = true;
      });
  }

  @override
  void initState() {
    super.initState();
    _attractionList = FirebaseList(
        query: widget.attractionQuery,
        onChildAdded: _onAttractionAdded,
        onChildChanged: _onAttractionChanged,
        onChildRemoved: _onAttractionRemoved,
        onValue: _onAttractionValue);
    _ignoreList = FirebaseList(
        query: widget.ignoreQuery,
        onChildAdded: _onIgnoreAdded,
        onChildChanged: _onIgnoreChanged,
        onChildRemoved: _onIgnoreRemoved,
        onValue: _onIgnoreValue);
    filter.addListener(_filterUpdated);

    // We delay the building of the UI until any possible transition has completed. This way any animation part of the transition isn't slowed.
    Future.delayed(Duration(milliseconds: 450), () {
      if (mounted) {
        setState(() {
          _delayOver = true;
        });
      }
    });

    PrefService.onNotify(
        preferencesKeyMap[PREFERENCE_KEYS.HIDE_IGNORED], () => _prefsUpdate());
  }

  void _prefsUpdate() {
    setState(() {});
  }

  void _filterUpdated() {
    setState(() {});
  }

  void _buildLists() {
    // Handle the parsing of all attractions from our firebase attraction list.
    _builtAttractionList = List<FirebaseAttraction>();
    _attractionList.forEach((snap) {
      FirebaseAttraction parsed =
          FirebaseAttraction.fromMap(Map.from(snap.value));
      _builtAttractionList.add(parsed);
    });

    // Handle the parsing of all ignore data from our firebase ignore list.
    _builtIgnoreList = List<int>();
    _ignoreList.forEach((snap) {
      // This one is a bit more complicated - an attraction can be ignored without
      // ever having a firebase entry. So, we have to create an empty firebase entry
      // without any information except for the fact that it is empty for LogRide
      // to handle it properly.
      bool newEntry = false;

      int targetID = snap.value["rideID"];
      FirebaseAttraction target = _builtAttractionList
          .firstWhere((testPark) => testPark.rideID == targetID, orElse: () {
        // This only occurs when a park is ignored and has no other data for it.
        // We need to create this data ourselves, and know to append it to the rest of the data.
        newEntry = true;
        return FirebaseAttraction(rideID: targetID);
      });

      target.ignored = true;
      if (newEntry) _builtAttractionList.add(target);
      _builtIgnoreList.add(targetID);
    });

    // Our list is passed to us as a map of attractions for each category.
    // We need to convert this into something our listview builder can handle
    // all while following the specific display rules we know.
    _builtDisplayList = List<dynamic>();
    widget.headedList.keys.forEach((String key) {
      // Get our attractions for this section.
      List<BluehostAttraction> attractions = widget.headedList[key];
      List<BluehostAttraction> displayList = List<BluehostAttraction>();

      // We only want to display the header for a section if there exists data under that header.
      // This keeps track of the number of elements under that header.
      int numToDisplay = 0;

      // We've got certain logic for each header. Let's do this.
      attractions.forEach((BluehostAttraction attr) {
        if (!isBluehostAttractionInSearch(attr, filter.value)) {
          return;
        }

        // All active entries are always displayed. No fancy logic required here.
        if (key == "Active") {
          numToDisplay++;
          displayList.add(attr);
          return;
        }

        // Seasonal and defunct attractions will display if either the display of them is enabled or
        // the attraction has existing user ride number data. So we need to know our user data for this attraction.
        FirebaseAttraction target = getFirebaseAttractionFromList(
            _builtAttractionList, attr.attractionID);
        if (key == "Seasonal") {
          // We don't have to check to see if the attraction is seasonal or not because if it is in
          // this list, we can be certain that it is.
          if (widget.parentPark.showSeasonal ||
              filter.value.isNotEmpty ||
              (target?.numberOfTimesRidden ?? 0) >= 1) {
            numToDisplay++;
            displayList.add(attr);
            return;
          }
        }

        if (key == "Defunct") {
          if (widget.parentPark.showDefunct ||
              !widget.parentParkData.active ||
              filter.value.isNotEmpty ||
              (target?.numberOfTimesRidden ?? 0) >= 1) {
            numToDisplay++;
            displayList.add(attr);
            return;
          }
        }
      });

      // Again, display header (and insert attractions) if attractions are here.
      if (numToDisplay >= 1) {
        _builtDisplayList.add(key);
        _builtDisplayList.addAll(displayList);
      }
    });
  }

  Widget _entryBuilder(BuildContext context, int index) {
    // Logic for handling the insertion of the search bar - it takes up index 0,
    // and as such the index needs to be adjusted afterwards for regular use.
    if (index == 0) {
      // We need to return our text field
      return TextField(
        controller: _searchController,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              if (filter.value != value) {
                filter.value = value;
              }
            });
          }
        },
        decoration: InputDecoration(
            labelText: "Search",
            hintText: "Search",
            prefixIcon: Icon(FontAwesomeIcons.search),
            suffixIcon: IconButton(
              icon: Icon(FontAwesomeIcons.times),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    filter.value = "";
                    _searchController.clear();
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                }
              },
            )),
      );
    } else {
      index--;
    }

    // Handling of headers
    if (_builtDisplayList[index] is String) {
      return Container(
        height: 22.0,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        color: SECTION_HEADER_BACKGROUND,
        child: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(_builtDisplayList[index]),
        ),
      );
    }

    BluehostAttraction target = _builtDisplayList[index] as BluehostAttraction;
    FirebaseAttraction attraction = getFirebaseAttractionFromList(
            _builtAttractionList, target.attractionID) ??
        FirebaseAttraction(rideID: target.attractionID);

    String search = filter.value;

    // If we're hiding ignored attractions, and this is an ignored attraction, hide it.
    if (attraction.ignored &&
        PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.HIDE_IGNORED]))
      return Container();

    if (isBluehostAttractionInSearch(target, search)) {
      Widget entry = AttractionListEntry(
        attractionData: target,
        parentPark: widget.parentPark,
        experienceHandler: widget.experienceHandler,
        ignoreCallback: widget.ignoreCallback,
        slidableController: _slidableController,
        submissionCallback: (b) => widget.submissionCallback(
            b, false, Provider.of<LogRideUser>(context)),
        userData: attraction,
        timeChanged: widget.dateHandler,
        db: widget.db,
      );

      return entry;
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("$_ignoreLoaded $_attractionLoaded $_delayOver");
    if (_ignoreLoaded && _attractionLoaded && _delayOver) {
      _buildLists();
      widget.countHandler(_builtAttractionList, _builtIgnoreList);
      return ListView.builder(
        // +1 is for the search entry
        itemCount: _builtDisplayList.length + 1,
        itemBuilder: _entryBuilder,
        controller: controller,
        //physics: ClampingScrollPhysics(),
        //physics: AlwaysScrollableScrollPhysics(),
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(0.0),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    _ignoreList.clear();
    _attractionList.clear();

    PrefService.onNotifyRemove(preferencesKeyMap[PREFERENCE_KEYS.HIDE_IGNORED]);

    super.dispose();
  }
}
