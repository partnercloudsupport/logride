import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../data/attraction_structures.dart';
import '../data/park_structures.dart';
import '../widgets/attraction_list_entry.dart';

class FirebaseAttractionListView extends StatefulWidget {
  FirebaseAttractionListView(
      {this.attractionQuery,
      this.ignoreQuery,
      this.headedList,
      this.parentPark,
      this.ignoreCallback,
      this.interactHandler});

  final Query attractionQuery;
  final Query ignoreQuery;

  final List<dynamic> headedList;
  final FirebasePark parentPark;

  final Function ignoreCallback;
  final Function interactHandler;

  @override
  _FirebaseAttractionListViewState createState() =>
      _FirebaseAttractionListViewState();
}

class _FirebaseAttractionListViewState
    extends State<FirebaseAttractionListView> {
  FirebaseList _attractionList;
  FirebaseList _ignoreList;

  List<FirebaseAttraction> _builtAttractionList;

  bool _ignoreLoaded = false;
  bool _attractionLoaded = false;

  final SlidableController _slidableController = SlidableController();

  void _onAttractionAdded(int index, DataSnapshot snap) {
    if (!_attractionLoaded) return;
    print("AttractionAdded Callback index: $index");
    if (mounted) setState(() {});
  }

  void _onAttractionRemoved(int index, DataSnapshot snap) {
    print("AttractionRemoved Callback index: $index");
    if (mounted) setState(() {});
  }

  void _onAttractionChanged(int index, DataSnapshot snap) {
    print("AttractionChanged Callback index: $index");
    if (mounted) setState(() {});
  }

  void _onAttractionValue(DataSnapshot snap) {
    print("AttractionValue");
    if (mounted)
      setState(() {
        _attractionLoaded = true;
      });
  }

  void _onIgnoreAdded(int index, DataSnapshot snap) {
    if (!_ignoreLoaded) return;
    print("IgnoreAdded index: $index");
    print("IgnoreAdded data: ${snap.value["rideID"]}");
    if (mounted) setState(() {});
  }

  void _onIgnoreRemoved(int index, DataSnapshot snap) {
    print("Ignore removed index: $index");
    if (mounted) setState(() {});
  }

  void _onIgnoreChanged(int index, DataSnapshot snap) {
    print("Ignore changed index: $index");
    if (mounted) setState(() {});
  }

  void _onIgnoreValue(DataSnapshot snap) {
    print("Ignore value");
    if (mounted)
      setState(() {
        _ignoreLoaded = true;
      });
  }

  @override
  void initState() {
    print("List initialized");
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
  }

  void _buildLists() {
    _builtAttractionList = List<FirebaseAttraction>();
    _attractionList.forEach((snap) {
      FirebaseAttraction parsed =
          FirebaseAttraction.fromMap(Map.from(snap.value));

      _builtAttractionList.add(parsed);
    });

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
    });
  }

  Widget _entryBuilder(BuildContext context, int index) {
    if (widget.headedList[index] is String) {
      return Container(
        height: 20.0,
        width: double.infinity,
        color: Colors.grey[200],
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

    return AttractionListEntry(
      attractionData: target,
      parentPark: widget.parentPark,
      interactHandler: widget.interactHandler,
      ignoreCallback: widget.ignoreCallback,
      slidableController: _slidableController,
      userData: attraction,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_ignoreLoaded && _attractionLoaded) {
      _buildLists();
      print("Rebuilding");
      return ListView.builder(
        itemCount: widget.headedList.length,
        itemBuilder: _entryBuilder,
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
