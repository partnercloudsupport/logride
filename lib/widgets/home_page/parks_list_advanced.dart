import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      this.bottomEntryPadding = false,
      this.shrinkWrap = false,
      this.physics});

  final Query allParksQuery;
  final Query favsQuery;

  final Function(FirebasePark park) parkTapCallback;
  final Function(ParkSlideActionType slide, FirebasePark park)
      sliderActionCallback;

  final ParksFilter filter;

  final bool bottomEntryPadding;
  final bool shrinkWrap;

  final ScrollPhysics physics;

  @override
  _FirebaseParkListViewState createState() => _FirebaseParkListViewState();
}

class _FirebaseParkListViewState extends State<FirebaseParkListView> {
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  final SlidableController _slidableController = SlidableController();
  final ScrollController _scrollController = ScrollController();

  String _emptyHint =
      "You don't have any parks! Tap the \"+\" button below to add your first park";

  List<FirebasePark> _builtList;
  List<FirebasePark> _favesForAnimation = List<FirebasePark>();

  FirebaseList _allList;
  FirebaseList _favsList;

  bool _allLoaded = false;
  bool _favsLoaded = false;
  bool _initialBuild = true;

  void _onParkAdded(int index, DataSnapshot snap) {
    if (!_allLoaded) return;

    _buildList();
    print(_builtList);

    FirebasePark park = FirebasePark.fromMap(Map.from(snap.value));
    int testIndex = getFirebaseParkIndex(_builtList, park.parkID);
    print("Adding park ${park.name} at index $testIndex");

    // Sometimes _allLoaded triggers when there's no animated key state. Returning.
    if(_animatedListKey.currentState == null) return;

    _animatedListKey.currentState.insertItem(testIndex);
  }

  void _onParkRemoved(int index, DataSnapshot snap) {
    FirebasePark park = FirebasePark.fromMap(Map.from(snap.value));

    int removalIndex = getFirebaseParkIndex(_builtList, park.parkID);
    print("Attempting to remove park ${park.name} at index: $removalIndex");
    _animatedListKey.currentState.removeItem(removalIndex,
        (BuildContext context, Animation<double> anim) {
      return _entryBuilder(context, removalIndex, anim, overridePark: park);
    });

    _buildList();

    if (_builtList.length == 0) _allLoaded = false;
  }

  void _onParkChanged(int index, DataSnapshot snap) {
    _buildList();
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

    _buildList();

    int position = getFirebaseParkIndex(_builtList, park.parkID);

    _animatedListKey.currentState.insertItem(position);
  }

  void _onFavRemoved(int index, DataSnapshot snap) {
    FirebasePark toRemove = FirebasePark.fromMap(Map.from(snap.value));
    toRemove.inFavorites = true;

    int position = getFirebaseParkIndex(_builtList, toRemove.parkID);

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
    _scrollController.jumpTo(0.0);
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
      if (index + 1 == _builtList.length && widget.bottomEntryPadding) {
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
    // Only display content if our content is actually loaded
    Widget content = Container();
    if (!_allLoaded || !_favsLoaded) {
      print("User's data hasn't loaded yet, spinning");
      content = Center(child: CircularProgressIndicator());
    }

    if (_allLoaded && _favsLoaded) {
      print("User's data has been recieved");
      if (_builtList == null) _buildList();

      if (_builtList.length == 0) {
        print("User has no data, displaying a welcome / tutorial page");
        content = Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  _emptyHint,
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
                Icon(
                  FontAwesomeIcons.arrowDown,
                  color: Theme.of(context).primaryColor,
                  size: 60,
                )
              ],
            ));
      } else {
        print("User's data has been loaded, displaying");
        content = AnimatedList(
          key: _animatedListKey,
          initialItemCount: _builtList.length,
          controller: _scrollController,
          itemBuilder: _entryBuilder,
          physics: widget.physics,
          padding: const EdgeInsets.only(top: 8.0),
        );
      }
    }

    return AnimatedSwitcher(
      child: content,
      duration: const Duration(milliseconds: 500),
    );
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
