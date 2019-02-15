import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/widgets/attraction_list_entry.dart';
import 'package:log_ride/widgets/experience_button.dart';
import 'package:log_ride/data/fbdb_manager.dart';

class AttractionFilter extends ValueNotifier<String> {
  AttractionFilter(String value) : super(value);
}

class FirebaseAttractionListView extends StatefulWidget {
  FirebaseAttractionListView(
      {this.attractionQuery,
      this.ignoreQuery,
      this.headedList,
      this.parentPark,
      this.ignoreCallback,
      this.experienceHandler,
      this.countHandler,
      this.dateHandler,
      this.db});

  final Query attractionQuery;
  final Query ignoreQuery;

  final List<dynamic> headedList;
  final FirebasePark parentPark;

  final Function(BluehostAttraction target, bool currentState) ignoreCallback;
  final Function(ExperienceAction, FirebaseAttraction) experienceHandler;
  final Function(List<FirebaseAttraction> userData, List<int> ignoreData)
      countHandler;
  final Function(DateTime, FirebaseAttraction, bool) dateHandler;

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
  ScrollController controller = ScrollController(initialScrollOffset: 71.0);

  FirebaseList _attractionList;
  FirebaseList _ignoreList;

  List<FirebaseAttraction> _builtAttractionList;
  List<int> _builtIgnoreList;

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
    Future.delayed(
        Duration(milliseconds: 450),
        () => setState(() {
              _delayOver = true;
            }));
  }

  void _filterUpdated() {
    setState(() {});
  }

  void _buildLists() {
    _builtAttractionList = List<FirebaseAttraction>();
    _attractionList.forEach((snap) {
      FirebaseAttraction parsed =
          FirebaseAttraction.fromMap(Map.from(snap.value));
      _builtAttractionList.add(parsed);
    });

    _builtIgnoreList = List<int>();
    _ignoreList.forEach((snap) {
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
  }

  Widget _entryBuilder(BuildContext context, int index) {
    if (index == 0) {
      // We need to return our text field
      return TextField(
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
          prefixIcon: Icon(Icons.search),
        ),
      );
    } else {
      index--;
    }
    if (widget.headedList[index] is String) {
      return Container(
        height: 22.0,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        color: SECTION_HEADER_BACKGROUND,
        child: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(widget.headedList[index]),
        ),
      );
    }

    BluehostAttraction target = widget.headedList[index] as BluehostAttraction;
    FirebaseAttraction attraction = getFirebaseAttractionFromList(
            _builtAttractionList, target.attractionID) ??
        FirebaseAttraction(rideID: target.attractionID);

    if (target.attractionName
            .toLowerCase()
            .contains(filter.value.toLowerCase()) ||
        target.typeLabel.toLowerCase().contains(filter.value.toLowerCase())) {
      return AttractionListEntry(
        attractionData: target,
        parentPark: widget.parentPark,
        experienceHandler: widget.experienceHandler,
        ignoreCallback: widget.ignoreCallback,
        slidableController: _slidableController,
        userData: attraction,
        timeChanged: widget.dateHandler,
        db: widget.db,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ignoreLoaded && _attractionLoaded && _delayOver) {
      _buildLists();
      widget.countHandler(_builtAttractionList, _builtIgnoreList);
      return ListView.builder(
        // +1 is for the search entry
        itemCount: widget.headedList.length + 1,
        itemBuilder: _entryBuilder,
        controller: controller,
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    _ignoreList.clear();
    _attractionList.clear();

    super.dispose();
  }
}
