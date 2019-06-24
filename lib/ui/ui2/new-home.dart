import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/check_in_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/loading_strings.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/ui/dialogs/park_search.dart';
import 'package:log_ride/ui/loading_page.dart';
import 'package:log_ride/ui/stats_page.dart';
import 'package:log_ride/ui/submission/submit_attraction_page.dart';
import 'package:log_ride/ui/submission/submit_park_page.dart';
import 'package:log_ride/ui/ui2/navigation/nav_bar.dart';
import 'package:log_ride/ui/ui2/navigation/tab_navigation.dart';
import 'package:log_ride/ui/ui2/pages/parks_home.dart';
import 'package:log_ride/widgets/shared/offstage_crossfade.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';

enum Tabs { NEWS, STATS, MY_PARKS, LISTS, SETTINGS }

class Home extends StatefulWidget {
  Home({this.auth, this.db, this.onSignedOut, this.uid});

  final BaseAuth auth;
  final BaseDB db;
  final Function onSignedOut;
  final String uid;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ParksHomeState> parksHomeKey = GlobalKey<ParksHomeState>();

  FirebaseAnalytics analytics = FirebaseAnalytics();

  Map<Tabs, GlobalKey<NavigatorState>> navigatorKeys = {
    Tabs.NEWS: GlobalKey<NavigatorState>(),
    Tabs.STATS: GlobalKey<NavigatorState>(),
    Tabs.MY_PARKS: GlobalKey<NavigatorState>(),
    Tabs.LISTS: GlobalKey<NavigatorState>(),
    Tabs.SETTINGS: GlobalKey<NavigatorState>(),
  };

  Map<Tabs, Widget> rootWidgets;

  static const int homeIndex = 2;
  int _pageIndex = homeIndex;

  WebFetcher _webFetcher;
  ParksManager _parksManager;
  Future<bool> initialized;
  StreamSubscription subscription;
  CheckInManager _checkInManager;
  String userName;

  ParksHomeFocus _parksHomeFocus = ParksHomeFocus(true);

  bool dataLoaded = false;

  bool _needsBasePadding = true;

  Stopwatch stopwatch = Stopwatch();

  void _handleNewParkSubmission() async {
    dynamic result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SubmitParkPage();
    }));

    if (result == null) return;

    BluehostPark newPark = result as BluehostPark;
    int response = await _webFetcher.submitParkData(newPark,
        username: userName, uid: widget.uid);

    if (response == 200) {
      analytics.logEvent(name: "new_park_sugggested");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StyledDialog(
              title: "Park Under Review",
              body: "Thanks for submitting! Your park is now under review.",
              actionText: "Ok",
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StyledDialog(
              title: "Error during Submission",
              body:
                  "Something happened during the park submission process. Error: $response",
              actionText: "Ok",
            );
          });
    }
  }

  /// Pushes the parks search page to the top of the navigator stack
  void _handleParkAdditionUI() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return AllParkSearchPage(
        allParks: _parksManager.allParksInfo,
        // There's two cases with which this'll be called: A multi-park add (long tap, then single taps)
        // and a single-park add. A single-park add will want to add the park, then immediately open the park.
        // a multi-park add just adds the park to the list and does not open it.
        tapBack: (BluehostPark p, bool open) =>
            open ? _handleChainParkAdd(p.id) : _handleAddIDCallback(p.id),
        suggestPark: _handleNewParkSubmission, // TODO: Proper suggestion
      );
    }));
  }

  /// Tells the parksManager to add park of parkID to a user's account.
  /// Returns a future, which returns true upon a park being successfully added
  Future<bool> _handleAddIDCallback(int parkID) async {
    await _parksManager.addParkToUser(parkID);
    return true;
  }

  /// Adds the park, then opens the park once it is ready
  void _handleChainParkAdd(int parkID) async {
    await _handleAddIDCallback(parkID);
    parksHomeKey.currentState.openParkWithID(parkID);
  }

  void _handleHomeFocusChanged() {
    setState(() {});
  }

  @override
  void initState() {

    stopwatch.start();

    _preInit();

    KeyboardVisibilityNotification().addNewListener(onChange: (bool visible) {
      setState(() {
        _needsBasePadding = !visible;
      });
    });

    super.initState();
  }

  void _preInit() {
    widget.db.storeUserID(widget.uid);

    _webFetcher = WebFetcher();
    _parksManager = ParksManager(db: widget.db, wf: _webFetcher);
    _parksManager.init();
    subscription =
        _parksManager.parksManagerStream.listen(_parksManagerListener);

    return;
  }

  void _parksManagerListener(ParksManagerEvent event) {
    switch (event.type) {
      case ParksManagerEventType.INITIALIZED:
        print("Initialized");
        subscription.cancel();
        break;
      case ParksManagerEventType.PARKS_FETCHED:
        print("Parks have been fetched.");
        break;
      case ParksManagerEventType.ATTRACTIONS_FETCHED:
        print("Attractions have been fetched");
        _dataInit();
        break;
      case ParksManagerEventType.INITIALIZING:
        print("Initializing of Park Manager has begun");
        break;
      case ParksManagerEventType.ERROR:
        print("Parks Manager has had an error in initialization");
        break;
      case ParksManagerEventType.UNINITIALIZED:
        break;
    }
  }

  Future<bool> _dataInit() async {
    _checkInManager = CheckInManager(
        db: widget.db,
        serverParks: _parksManager.allParksInfo,
        addPark: _handleAddIDCallback);

    await widget.auth.getCurrentUserName().then((name) {
      print(name);
      userName = name;
    });

    await widget.auth.getCurrentUserEmail().then((email) {
      email = email;
    });

    rootWidgets = <Tabs, Widget>{
      Tabs.NEWS: Center(child: Text("News")),
      Tabs.STATS: StatsPage(
        db: widget.db,
        pm: _parksManager,
      ),
      Tabs.MY_PARKS: ParksHome(
        uid: widget.uid,
        auth: widget.auth,
        db: widget.db,
        parksManager: _parksManager,
        username: userName,
        webFetcher: _webFetcher,
        key: parksHomeKey,
        parksHomeFocus: _parksHomeFocus,
      ),
      Tabs.LISTS: Center(child: Text("Lists")),
      Tabs.SETTINGS: Center(child: Text("Settings"))
    };

    _parksHomeFocus.addListener(_handleHomeFocusChanged);

    setState((){
      dataLoaded = true;
    });

    print("Boot took ${stopwatch.elapsed} seconds");
    stopwatch.stop();

    return true;
  }

  void _onMenuBarItemTapped(int index) {
    if (!mounted) return;

    // Handle any possible out-of-bounds issues
    if (Tabs.values.length <= index || index < 0) {
      print(
          "Error: Page was set at $index in a 0...${Tabs.values.length} range array");
      return;
    }

    // We don't want to rebuild if we're already on that page, but...
    if (_pageIndex == index) {
      // ... we DO want to open up the park addition page if we're already home
      if (index == homeIndex) {
        if (_parksHomeFocus.value == true) {
          _handleParkAdditionUI();
        } else {
          navigatorKeys[Tabs.values[_pageIndex]].currentState.maybePop();
        }
      }
      return;
    }

    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Capturing back keys and sending them to the appropriate navigators...

    if (!dataLoaded) return LoadingPage();

    return WillPopScope(
        onWillPop: () async => !await navigatorKeys[Tabs.values[_pageIndex]]
            .currentState
            .maybePop(),
        child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: <Widget>[
                Padding(
                    padding: (_needsBasePadding)
                        ? EdgeInsets.only(bottom: 54.0)
                        : EdgeInsets.zero,
                    child: Stack(
                      children: <Widget>[
                        _buildOffstageNavigator(Tabs.NEWS),
                        _buildOffstageNavigator(Tabs.STATS),
                        _buildOffstageNavigator(Tabs.MY_PARKS),
                        _buildOffstageNavigator(Tabs.LISTS),
                        _buildOffstageNavigator(Tabs.SETTINGS),
                      ],
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ContextNavBar(
                    menuTap: _onMenuBarItemTapped,
                    homeIndex: homeIndex,
                    index: _pageIndex,
                    homeFocus: _parksHomeFocus.value,
                    items: [
                      ContextNavBarItem(
                          label: "News",
                          iconData: FontAwesomeIcons.solidNewspaper),
                      ContextNavBarItem(
                          label: "Stats", iconData: FontAwesomeIcons.chartPie),
                      ContextNavBarItem(
                          label: "Lists", iconData: FontAwesomeIcons.list),
                      ContextNavBarItem(
                          label: "Settings", iconData: FontAwesomeIcons.cog)
                    ],
                  ),
                )
              ],
            )));
  }

  Widget _buildOffstageNavigator(Tabs tab) {
    return OffstageCrossFade(
      offStageState: Tabs.values[_pageIndex] != tab,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tab],
        rootWidget: rootWidgets[tab],
      ),
    );
  }
}
