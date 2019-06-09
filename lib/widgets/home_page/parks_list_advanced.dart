import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/search_comparators.dart';
import 'package:log_ride/widgets/home_page/park_list_entry.dart';

class ParksFilter extends ValueNotifier<String> {
  ParksFilter(String value) : super(value);
}

class FirebaseParkListView extends StatefulWidget {
  FirebaseParkListView(
      {this.allParksQuery,
      this.favsQuery,
      this.parkTapCallback,
      this.sliderActionCallback,
      this.filter,
      this.bottomPadding = false,
      this.shrinkWrap = false,
      this.physics});

  final Query allParksQuery;
  final Query favsQuery;

  final Function(FirebasePark park) parkTapCallback;
  final Function(ParkSlideActionType slide, FirebasePark park)
      sliderActionCallback;

  final ParksFilter filter;

  final bool bottomPadding;
  final bool shrinkWrap;

  final ScrollPhysics physics;

  @override
  _FirebaseParkListViewState createState() => _FirebaseParkListViewState();
}

class _FirebaseParkListViewState extends State<FirebaseParkListView> {
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  final SlidableController _slidableController = SlidableController();
  String _emptyHint =
      "You haven't checked into any parks! Tap the \"+\" button to add a park";

  List<FirebasePark> _builtList;
  List<FirebasePark> _favesForAnimation = List<FirebasePark>();

  FirebaseList _allList;
  FirebaseList _favsList;

  bool _allLoaded = false;
  bool _favsLoaded = false;
  bool _initialBuild = true;

  void _onParkAdded(int index, DataSnapshot snap) {
    if (!_allLoaded) return;
    if (mounted) setState(() {});
  }

  void _onParkRemoved(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onParkChanged(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onParkValue(DataSnapshot snap) {
    if (mounted)
      setState(() {
        _allLoaded = true;
      });
  }

  void _onFavAdded(int index, DataSnapshot snap) {
    if (!_favsLoaded) return;

    FirebasePark park = FirebasePark.fromMap(Map.from(snap.value));

    park.inFavorites = true;
    _favesForAnimation.add(park);
    _favesForAnimation.sort((a, b) => a.name.compareTo(b.name));

    int position = _favesForAnimation.indexOf(park);

    _animatedListKey.currentState.insertItem(position);
  }

  void _onFavRemoved(int index, DataSnapshot snap) {
    FirebasePark toRemove = FirebasePark.fromMap(Map.from(snap.value));
    toRemove.inFavorites = true;

    print(_favesForAnimation);
    int position = getFirebaseParkIndex(_favesForAnimation, toRemove.parkID);
    _favesForAnimation.removeAt(position);
    print(_favesForAnimation);

    _animatedListKey.currentState.removeItem(position,
        (BuildContext context, Animation<double> animation) {
      return _entryBuilder(context, position, animation,
          overridePark: toRemove);
    });
  }

  void _onFavChanged(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onFavValue(DataSnapshot snap) {
    if (mounted)
      setState(() {
        _favsLoaded = true;
      });
  }

  void _filterUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _allList = FirebaseList(
        query: widget.allParksQuery,
        onChildAdded: _onParkAdded,
        onChildRemoved: _onParkRemoved,
        onChildChanged: _onParkChanged,
        onValue: _onParkValue);

    _favsList = FirebaseList(
        query: widget.favsQuery,
        onChildAdded: _onFavAdded,
        onChildRemoved: _onFavRemoved,
        onChildChanged: _onFavChanged,
        onValue: _onFavValue);

    if (widget.filter != null) widget.filter.addListener(_filterUpdated);
  }

  /// Builds a list used to display all the parks
  void _buildList() {
    _builtList = List<FirebasePark>();

    // First list - at the top of the list is favorites
    List<FirebasePark> buffer = List<FirebasePark>();

    _favsList.forEach((snap) {
      FirebasePark parsed = FirebasePark.fromMap(Map.from(snap.value));
      if (parsed.parkID == null || parsed.name == null) return;
      parsed.inFavorites = true;
      buffer.add(parsed);
      if (_initialBuild) {
        _favesForAnimation.add(parsed);
      }
    });

    _initialBuild = false;

    buffer.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    _builtList.addAll(buffer);

    // Add our null - presents as a divider
    if (_builtList.length > 0) _builtList.add(null);

    // Second list - the bottom of the list is the rest of the parks
    buffer = List<FirebasePark>();

    _allList.forEach((snap) {
      FirebasePark parsed = FirebasePark.fromMap(Map.from(snap.value));
      if (parsed.parkID == null || parsed.name == null) return;
      buffer.add(parsed);
    });

    buffer.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    _builtList.addAll(buffer);
  }

  Widget _entryBuilder(BuildContext context, int index, Animation<double> anim,
      {FirebasePark overridePark}) {
    String search = widget.filter?.value ?? "";

    if (overridePark != null) {
      return FadeTransition(
        opacity: anim,
        child: ParkListEntry(
          onTap: (_) {},
          sliderActionCallback: (_, __) {},
          parkData: overridePark,
          slidableController: _slidableController,
        ),
      );
    }

    if (index >= _builtList.length) return Container();

    FirebasePark park = _builtList[index];

    if (park == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Divider(
          height: 8.0,
          color: Colors.black38,
        ),
      );
    }

    if (isFirebaseParkInSearch(park, search)) {
      Widget builtWidget = ParkListEntry(
        onTap: widget.parkTapCallback,
        sliderActionCallback: widget.sliderActionCallback,
        parkData: _builtList[index],
        slidableController: _slidableController,
      );
      if (index + 1 == _builtList.length && widget.bottomPadding) {
        builtWidget = Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: builtWidget,
        );
      }
      return FadeTransition(opacity: anim, child: builtWidget);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_allLoaded && _favsLoaded) {
      _buildList();
      if (_builtList.length == 0) {
        return Padding(
            padding: EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
            child: Column(
              children: <Widget>[
                Text(
                  _emptyHint,
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 52.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/swoosh.png"),
                    ),
                  ),
                )
              ],
            ));
      }
      return AnimatedList(
        key: _animatedListKey,
        initialItemCount: _builtList.length,
        itemBuilder: _entryBuilder,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: const EdgeInsets.only(top: 8.0),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    _allList.clear();
    _favsList.clear();

    widget.filter.removeListener(_filterUpdated);
    widget.filter.dispose();

    super.dispose();
  }
}
