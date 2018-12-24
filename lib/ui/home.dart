import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:math' as math;
import '../widgets/park_list_widget.dart';
import '../widgets/park_list_entry.dart';
import '../widgets/content_frame.dart';
import '../data/park_structures.dart';
import '../data/section_focus_model.dart';
import '../data/webfetcher.dart';
import '../animations/slide_up_transition.dart';
import 'standard_page_structure.dart';
import 'all_park_search.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

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

  SectionFocus focus = SectionFocus.balanced;

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
        return isFavorites ? screenHeight - titleBarHeight : titleBarHeight;
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

  void _handleSlidableCallback(ParkSlideActionType actionType, ParkData park) {
    switch (actionType) {
      case ParkSlideActionType.faveAdd:
        setState(() {
          park.favorite = true;
        });
        break;
      case ParkSlideActionType.faveRemove:
        setState(() {
          park.favorite = false;
        });
        break;
      case ParkSlideActionType.delete:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Delete Park Data?"),
                content: Text(
                    "This will permanately delete your progress for ${park.parkName}"),
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
                        park.reset();
                        Navigator.of(context).pop();
                      });
                    },
                  )
                ],
              );
            });
    }
  }

  void _handleEntryCallback(ParkData park) {
    print("THOMAS - Open up attraction list page for ${park.parkName}");
  }

  void _handleAddCallback(ParkData park) async {
    if (userParkData.contains(park)) return;

    userParkData.add(park);
    await populateParkData(park);
    if (mounted) {
      setState(() {});
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
            parksData: userParkData,
            favorites: true,
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
              parksData: userParkData,
              favorites: false,
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
          // Title Bar Buttons,
          content,
        ],
      ),
    );
  }
}
