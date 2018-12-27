import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import '../widgets/park_list_widget.dart';
import '../widgets/park_list_entry.dart';
import '../widgets/content_frame.dart';
import '../data/park_structures.dart';
import '../data/webfetcher.dart';
import '../data/auth_manager.dart';
import '../data/fbdb_manager.dart';
import '../animations/slide_up_transition.dart';
import '../ui/standard_page_structure.dart';
import '../ui/all_park_search.dart';

enum SectionFocus { favorites, all, balanced }

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.db, this.uid, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final BaseDB db;
  final Function onSignedOut;
  final String uid;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ParkData> allParks;
  List<ParkData> userParkData;

  double _favesHeight;
  double _allHeight;

  Matrix4 _favesArrowRotation;
  Matrix4 _allArrowRotation;

  bool _favesHasContent = false;
  bool _allHasContent = false;

  SectionFocus focus = SectionFocus.balanced;

  String userID;

  final SlidableController _slidableController = SlidableController();

  double _calculateSectionHeight(bool isFavorites, SectionFocus focus) {
    // Get our total possible height
    double screenHeight = MediaQuery.of(context).size.height;
    // Remove the menu-bar padding
    screenHeight -= MediaQuery.of(context).padding.top;
    screenHeight -= 16.0; // Remove the padding from our padding widget
    screenHeight -= 50.0; // Remove the floating icon's padding
    // We now have our total height to play with
    double titleBarHeight = 61.0;
    double allParksTtileBarHeight =
        82.0; // AllParks is slightly bigger thanks to the icon for the search
    // If we're not in focus, fall back to the titlebarheight
    switch (focus) {
      case SectionFocus.balanced:
        // We split the screen 2:3 if both are in focus
        return isFavorites ? screenHeight * (2 / 5) : screenHeight * (3 / 5);
      case SectionFocus.all:
        // The favorites section is only the header, the other is the rest
        return isFavorites ? titleBarHeight : screenHeight - titleBarHeight;
      case SectionFocus.favorites:
        // Opposite of favorites
        return isFavorites
            ? screenHeight - allParksTtileBarHeight
            : allParksTtileBarHeight;
    }
    print("Error - calculateSectionHeight was given an improper focus");
    return 0.0;
  }

  void _handleHeaderCallback(bool isFavorites) {
    double downRadians = math.pi * 0.5;

    setState(() {
      if (isFavorites && focus == SectionFocus.favorites) {
        focus = SectionFocus.balanced;
        _favesArrowRotation = _allArrowRotation = Matrix4.rotationZ(0.0);
      } else if (!isFavorites && focus == SectionFocus.all) {
        focus = SectionFocus.balanced;
        _favesArrowRotation = _allArrowRotation = Matrix4.rotationZ(0.0);
      } else {
        focus = isFavorites ? SectionFocus.favorites : SectionFocus.all;
        _favesArrowRotation = isFavorites
            ? Matrix4.rotationZ(downRadians)
            : Matrix4.rotationZ(0.0);
        _allArrowRotation = isFavorites
            ? Matrix4.rotationZ(0.0)
            : Matrix4.rotationZ(downRadians);
      }
    });
  }

  void _handleSlidableCallback(ParkSlideActionType actionType, BasicPark park) {
    switch (actionType) {
      case ParkSlideActionType.faveAdd:
        widget.db.addEntryToPath(
            path: DatabasePath.FAVORITES,
            userID: widget.uid,
            key: park.parkID.toString(),
            payload: park.toMap());
        widget.db.setEntryAtPath(
            path: DatabasePath.PARKS,
            userID: widget.uid,
            key: park.parkID.toString() + "/favorite",
            payload: true);

        break;
      case ParkSlideActionType.faveRemove:
        widget.db.removeEntryFromPath(
            path: DatabasePath.FAVORITES,
            userID: widget.uid,
            key: park.parkID.toString());
        widget.db.setEntryAtPath(
            path: DatabasePath.PARKS,
            userID: widget.uid,
            key: park.parkID.toString() + "/favorite",
            payload: false);
        break;
      case ParkSlideActionType.delete:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Delete Park Data?"),
                content: Text(
                    "This will permanately delete your progress for ${park.name}"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Delete"),
                    onPressed: () {
                      setState(() {
                        userParkData.remove(park);
                        if (park.favorite) {
                          widget.db.removeEntryFromPath(
                              path: DatabasePath.FAVORITES,
                              userID: widget.uid,
                              key: park.parkID.toString());
                        }
                        widget.db.removeEntryFromPath(
                            path: DatabasePath.PARKS,
                            userID: widget.uid,
                            key: park.parkID.toString());
                        Navigator.of(context).pop();
                        _calculateHasContent();
                      });
                    },
                  )
                ],
              );
            });
    }
    // Used to trigger a recalculation of (has-content)
    setState(() {
      _calculateHasContent();
    });
  }

  void _handleEntryCallback(BasicPark park) {
    print("THOMAS - Open up attraction list page for ${park.name}");
  }

  void _handleAddCallback(ParkData park) async {
    bool doesExist = await widget.db.doesEntryExistAtPath(
        path: DatabasePath.PARKS,
        userID: widget.uid,
        key: park.parkID.toString());
    if (doesExist) {
      print("It does exist!");
      return;
    }

    BasicPark newPark = BasicPark(parkID: park.parkID);
    newPark.name = park.parkName;
    newPark.location = park.parkCity;

    newPark.totalRides = 0;
    newPark.numberOfCheckIns = 0;
    newPark.lastDayVisited = DateTime.fromMillisecondsSinceEpoch(0);
    newPark.ridesRidden = 0;
    newPark.incrementorEnabled = false;
    newPark.favorite = false;
    newPark.checkedInToday = false;
    newPark.showDefunct = false;

    // TODO: Implement better attraction counting
    await populateParkData(park);

    newPark.totalRides = park.numAttractions;

    widget.db.addEntryToPath(
        path: DatabasePath.PARKS,
        userID: widget.uid,
        key: newPark.parkID.toString(),
        payload: newPark.toMap());
    setState(() {
      _calculateHasContent();
    });
  }

  void _calculateHasContent() {
    widget.db
        .doesEntryExistAtPath(
            path: DatabasePath.FAVORITES, userID: widget.uid, key: "")
        .then((result) {
      setState(() {
        _favesHasContent = result;
      });
    });

    widget.db
        .doesEntryExistAtPath(
            path: DatabasePath.PARKS, userID: widget.uid, key: "")
        .then((result) {
      setState(() {
        _allHasContent = result;
      });
    });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // When this state is initialized, it needs to do the following steps
    // Fetch global parks list
    // Fetch user information
    // Build specific parks from user information & parks list
    fetchInitialWebData().then((Map<String, dynamic> returnedMap) {
      setState(() {
        allParks = returnedMap["global"];
        userParkData = returnedMap["visited"];
      });
    });

    _calculateHasContent();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _favesHeight = _calculateSectionHeight(true, focus);
    _allHeight = _calculateSectionHeight(false, focus);

    Widget arrowIcon = Transform(
        transform: Matrix4.translationValues(-10, -10, 0.0),
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
        ));

    Duration animationDuration = const Duration(milliseconds: 400);

    Widget content = ContentFrame(
        child: Container(
            child: Column(
      children: <Widget>[
        AnimatedContainer(
          curve: Curves.linear,
          duration: animationDuration,
          height: _favesHeight,
          child: ParkListView(
            parksData: widget.db.getSortedQueryForUser(
                path: DatabasePath.FAVORITES, userID: widget.uid, key: "name"),
            favorites: true,
            hasContent: _favesHasContent,
            slidableController: _slidableController,
            sliderActionCallback: _handleSlidableCallback,
            headerCallback: _handleHeaderCallback,
            onTap: _handleEntryCallback,
            arrowWidget: Transform(
              transform: Matrix4.translationValues(10, 10, 0.0),
              child: AnimatedContainer(
                  curve: Curves.linear,
                  duration: animationDuration,
                  transform: _favesArrowRotation,
                  child: arrowIcon),
            ),
          ),
        ),
        AnimatedContainer(
          curve: Curves.linear,
          duration: animationDuration,
          height: _allHeight,
          child: ParkListView(
              parksData: widget.db.getSortedQueryForUser(
                  path: DatabasePath.PARKS, userID: widget.uid, key: "name"),
              favorites: false,
              hasContent: _allHasContent,
              slidableController: _slidableController,
              headerCallback: _handleHeaderCallback,
              onTap: _handleEntryCallback,
              sliderActionCallback: _handleSlidableCallback,
              arrowWidget: Transform(
                transform: Matrix4.translationValues(10, 10, 0.0),
                child: AnimatedContainer(
                    curve: Curves.linear,
                    duration: animationDuration,
                    transform: _allArrowRotation,
                    alignment: Alignment(0.0, 30.0),
                    child: arrowIcon),
              )),
        )
      ],
    )));

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomPadding: false,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 38,
        ),
        onPressed: () {
          Navigator.push(
              context,
              SlideUpRoute(
                  widget: AllParkSearchPage(
                allParks: allParks,
                tapBack: _handleAddCallback,
              )));
          setState(
              () {}); // We update our state so any changes done by the search page work
        },
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StandardPageStructure(
        content: <Widget>[
          _buildMenuBar(context),
          content,
        ],
      ),
    );
  }

  Widget _buildMenuBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
                onTap: _signOut,
                child: _buildMenuIcon(FontAwesomeIcons.userAlt)),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 28.0),
                  child: _buildMenuIcon(FontAwesomeIcons.trophy),
                ),
                _buildMenuIcon(FontAwesomeIcons.cog)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon) {
    return Icon(icon, color: Colors.white);
  }
}
