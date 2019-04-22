import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/check_in_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/ui/stats_page.dart';
import 'package:log_ride/ui/dialogs/park_search.dart';
import 'package:log_ride/ui/attractions_list_page.dart';
import 'package:log_ride/ui/app_info_page.dart';
import 'package:log_ride/ui/submission/submit_attraction_page.dart';
import 'package:log_ride/ui/submission/submit_park_page.dart';
import 'package:log_ride/widgets/shared/home_icon.dart';
import 'package:log_ride/widgets/home_page/check_in_widget.dart';
import 'package:log_ride/widgets/parks_page/park_list_widget.dart';
import 'package:log_ride/widgets/parks_page/park_list_entry.dart';
import 'package:log_ride/widgets/shared/content_frame.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';

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
  final SlidableController _slidableController = SlidableController();

  // Variables relating to the focus effect
  SectionFocus focus = SectionFocus.balanced;
  double _favesHeight;
  Matrix4 _favesArrowRotation;
  Matrix4 _allArrowRotation;

  // Used for debugging and future features
  String userName = "";
  String email = "";

  // Data management
  ParksManager _parksManager = ParksManager();
  WebFetcher _webFetcher = WebFetcher();
  Future<bool> initialized;

  // Check-in Variables
  CheckInManager _checkInManager;
  bool isInPark = false;
  int inParkID = -1;

  double _calculateFavoritesSectionHeight(SectionFocus focus) {
    // Get our total possible height
    double screenHeight = MediaQuery.of(context).size.height;
    // Remove the menu-bar padding
    screenHeight -= MediaQuery.of(context).padding.top;
    screenHeight -= 16.0; // Remove the padding from our padding widget
    screenHeight -= 50.0; // Remove the floating icon's padding
    // We now have our total height to play with
    double titleBarHeight = 61.0;
    double allParksTitleBarHeight =
        82.0; // AllParks is slightly bigger thanks to the icon for the search
    // If we're not in focus, fall back to the titlebarheight
    switch (focus) {
      case SectionFocus.balanced:
        // We split the screen 2:3 if both are in focus
        return screenHeight * (2 / 5);
      case SectionFocus.all:
        // The favorites section is only the header, the other is the rest
        return titleBarHeight;
      case SectionFocus.favorites:
        // Opposite of favorites
        return screenHeight - allParksTitleBarHeight;
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

  void _handleSlidableCallback(
      ParkSlideActionType actionType, FirebasePark park) {
    switch (actionType) {
      case ParkSlideActionType.faveAdd:
        _parksManager.addParkToFavorites(park.parkID);
        break;
      case ParkSlideActionType.faveRemove:
        _parksManager.removeParkFromFavorites(park.parkID);
        break;
      case ParkSlideActionType.delete:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
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
                        _parksManager.removeParkFromUserData(park.parkID);
                        Navigator.of(context).pop();
                        setState(() {});
                      });
                    },
                  )
                ],
              );
            });
    }
  }

  void _handleEntryCallback(FirebasePark park) {
    print("Opening id: ${park.parkID} park: ${park.name}");
    BluehostPark serverPark =
        getBluehostParkByID(_parksManager.allParksInfo, park.parkID);
    print("Found bh id: ${serverPark.id} park: ${serverPark.parkName}");

    // This should only happen on the rare occasion that the user opens the app
    // then immediately taps on a park tile. Making it so that nothing happens
    // means the user will think they missed, hopefully giving us enough time to
    // actually load park data.
    if (serverPark.attractions == null) {
      print("User is attempting to open a page that doesn't have data yet.");
      return;
    }

    Navigator.push(
        context,
        SlideInRoute(
            direction: SlideInDirection.UP,
            dialogStyle: true,
            widget: AttractionsPage(
              pm: _parksManager,
              db: widget.db,
              userName: userName,
              serverParkData: serverPark,
              submissionCallback: (a, n) => _handleAttractionSubmissionCallback(
                  a, serverPark,
                  isNewAttraction: n),
            )));
  }

  void _handleAddCallback(BluehostPark park) {
    _parksManager.addParkToUser(park.id);
  }

  Future<bool> _handleAddIDCallback(int id) async {
    await _parksManager.addParkToUser(id);
    return true;
  }

  // This function adds the park to the current user's parks (if it isn't already) and opens it
  void _handleCheckInCallback(int parkID) async {
    BluehostPark serverPark =
        getBluehostParkByID(_parksManager.allParksInfo, parkID);

    Navigator.push(
        context,
        SlideInRoute(
            direction: SlideInDirection.UP,
            dialogStyle: true,
            widget: AttractionsPage(
                pm: _parksManager,
                db: widget.db,
                serverParkData: serverPark,
                submissionCallback: (a, n) =>
                    _handleAttractionSubmissionCallback(a, serverPark,
                        isNewAttraction: n))));
  }

  void _handleAttractionSubmissionCallback(
      BluehostAttraction attr, BluehostPark parent,
      {bool isNewAttraction = false}) async {
    isNewAttraction ? print("New Attraction") : print("Modified Attraction");

    dynamic result = await Navigator.push(
        context,
        SlideInRoute(
            widget: SubmitAttractionPage(
                attractionTypes: _parksManager.attractionTypes,
                existingData: attr,
                parentPark: parent),
            dialogStyle: true,
            direction: SlideInDirection.RIGHT));

    if (result == null) return;

    BluehostAttraction newAttraction = result as BluehostAttraction;
    _webFetcher.submitAttractionData(newAttraction, parent,
        username: userName, uid: widget.uid, isNewAttraction: isNewAttraction);
    showDialog(context: context, builder:(BuildContext context) {
      return StyledDialog(
        title: "Attraction Under Review",
        body: "Thanks for submitting! Your attraction is now under review.",
        actionText: "Ok",
      );
    });
  }

  void _handleParkSubmissionCallback() async {
    dynamic result = await Navigator.push(
        context,
        SlideInRoute(
            widget: SubmitParkPage(),
            dialogStyle: true,
            direction: SlideInDirection.RIGHT));

    if (result == null) return;

    BluehostPark newPark = result as BluehostPark;
    _webFetcher.submitParkData(newPark, username: userName, uid: widget.uid);
    showDialog(context: context, builder:(BuildContext context) {
      return StyledDialog(
        title: "Park Under Review",
        body: "Thanks for submitting! Your park is now under review.",
        actionText: "Ok",
      );
    });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      //widget.db.clearUserID();
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
    //widget.db.storeUserID(widget.uid);

    widget.db.storeUserID(widget.uid);

    _webFetcher = WebFetcher();
    _parksManager = ParksManager(db: widget.db, wf: _webFetcher);
    initialized = _parksManager.init();

    initialized.then((_) {
      _checkInManager = CheckInManager(
          db: widget.db,
          serverParks: _parksManager.allParksInfo,
          addPark: _handleAddIDCallback);
    });

    widget.auth.getCurrentUserName().then((name) {
      userName = name;
    });

    widget.auth.getCurrentUserEmail().then((email) {
      email = email;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.db.storeUserID(widget.uid);

    _favesHeight = _calculateFavoritesSectionHeight(focus);

    Widget arrowIcon = Transform(
        transform: Matrix4.translationValues(-10, -10, 0.0),
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
        ));

    Duration animationDuration = const Duration(milliseconds: 400);

    Widget content = FutureBuilder(
      future: initialized,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: Container(
            width: MediaQuery.of(context).size.width * 2 / 5,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Loading Park Information...",
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          ));
        } else if (snapshot.data) {
          // Since data is a bool, if it's true, we'll do this thing
          return ContentFrame(
              child: Container(
                  child: Column(
            children: <Widget>[
              AnimatedContainer(
                curve: Curves.linear,
                duration: animationDuration,
                height: _favesHeight,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: ParkListView(
                    parksData: widget.db.getFilteredQuery(
                        path: DatabasePath.PARKS, key: "favorite", value: true),
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
                          alignment: Alignment(0.0, 30.0),
                          child: arrowIcon),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: ParkListView(
                    parksData: widget.db
                        .getQueryForUser(path: DatabasePath.PARKS, key: ""),
                    favorites: false,
                    showSearch: true,
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
                    ),
                  ),
                ),
              )
            ],
          )));
        }
      },
    );

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
          if (!_parksManager.searchInitialized) {
            print(
                "Search hasn't been initialized yet. Preventing user from viewing search page.");
            return;
          }

          Navigator.push(
              context,
              SlideInRoute(
                  dialogStyle: true,
                  direction: SlideInDirection.UP,
                  widget: AllParkSearchPage(
                    allParks: _parksManager.allParksInfo,
                    tapBack: _handleAddCallback,
                    suggestPark: _handleParkSubmissionCallback,
                  )));
        },
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
          child: Center(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              _buildMenuBar(context),
              content,
              FutureBuilder<bool>(
                future: initialized,
                builder: (BuildContext context, AsyncSnapshot<bool> snap) {
                  if (!snap.hasData) {
                    return HomeIconButton();
                  } else {
                    return CheckInWidget(
                      manager: _checkInManager,
                      onTap: _handleCheckInCallback,
                    );
                  }
                },
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildMenuBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  SlideInRoute(
                      direction: SlideInDirection.LEFT,
                      widget: AppInfoPage(
                        signOut: _signOut,
                        username: userName,
                      ))),
              child: _buildMenuIcon(FontAwesomeIcons.cog),
            ),
            Row(
              children: <Widget>[
                InkWell(
                    onTap: () => Navigator.push(
                        context,
                        SlideInRoute(
                            direction: SlideInDirection.UP,
                            dialogStyle: true,
                            widget: StatsPage(
                              db: widget.db,
                              serverParks: _parksManager.allParksInfo,
                            ))),
                    child: _buildMenuIcon(Entypo.getIconData("pie-chart")))
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
