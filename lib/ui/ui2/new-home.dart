import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/check_in_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/ui/dialogs/park_search.dart';
import 'package:log_ride/ui/ui2/navigation/nav_bar.dart';
import 'package:log_ride/ui/ui2/navigation/tab_navigation.dart';
import 'package:log_ride/ui/ui2/pages/parks_home.dart';

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

  Map<Tabs, GlobalKey<NavigatorState>> navigatorKeys = {
    Tabs.NEWS: GlobalKey<NavigatorState>(),
    Tabs.STATS: GlobalKey<NavigatorState>(),
    Tabs.MY_PARKS: GlobalKey<NavigatorState>(),
    Tabs.LISTS: GlobalKey<NavigatorState>(),
    Tabs.SETTINGS: GlobalKey<NavigatorState>(),
  };

  Map<Tabs, Widget> rootWidgets;

  int _pageIndex = 2;

  WebFetcher _webFetcher;
  ParksManager _parksManager;
  Future<bool> initialized;
  CheckInManager _checkInManager;
  String userName;

  /// Pushes the parks search page to the top of the navigator stack
  void _handleParkAdditionUI() {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return AllParkSearchPage(
        allParks: _parksManager.allParksInfo,
        // There's two cases with which this'll be called: A multi-park add (long tap, then single taps)
        // and a single-park add. A single-park add will want to add the park, then immediately open the park.
        // a multi-park add just adds the park to the list and does not open it.
        tapBack: (BluehostPark p, bool open) => open ? _handleChainParkAdd(p.id) : _handleAddIDCallback(p.id),
        suggestPark: () => print("Suggestion"), // TODO: Proper suggestion
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

  @override
  void initState() {

    _dataInit();

    rootWidgets = <Tabs, Widget>{
      Tabs.NEWS: Center(child: Text("News")),
      Tabs.STATS: Center(child: Text("Stats")),
      Tabs.MY_PARKS: ParksHome(
        uid: widget.uid,
        auth: widget.auth,
        db: widget.db,
        parksManager: _parksManager,
        username: userName,
        webFetcher: _webFetcher,
        key: parksHomeKey
      ),
      Tabs.LISTS: Center(child: Text("Lists")),
      Tabs.SETTINGS: Center(child: Text("Settings"))
    };
    
    super.initState();
  }

  void _dataInit() {
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
    if(_pageIndex == index){
      // ... we DO want to open up the park addition page if we're already home
      if(index == 2) _handleParkAdditionUI();
      return;
    }

    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Capturing back keys and sending them to the appropriate navigators...
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[Tabs.values[_pageIndex]].currentState.maybePop(),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 54.0),
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
                  homeIndex: 2,
                  index: _pageIndex,
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
          )),
    );
  }

  Widget _buildOffstageNavigator(Tabs tab) {
    return Offstage(
      offstage: Tabs.values[_pageIndex] != tab,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tab],
        rootWidget: rootWidgets[tab],
      ),
    );
  }
}
