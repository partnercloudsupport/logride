import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:log_ride/ui/pages/stats/attractions.dart';
import 'package:log_ride/ui/pages/stats/coaster.dart';
import 'package:log_ride/ui/pages/stats/parks.dart';
import 'package:log_ride/widgets/shared/spinning_iconbutton.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
import 'package:toast/toast.dart';

enum CalculationState {
  CALCULATING,
  REQUESTING_CALCULATION,
  ERROR_CALCULATING,
  CALCULATED
}

class StatsPage extends StatefulWidget {
  StatsPage({this.pm, this.db});

  final ParksManager pm;
  final BaseDB db;

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  StatsCalculator calculator;

  TabController _tabController;
  ScrollController _scrollController = ScrollController();

  CalculationState _calculationState = CalculationState.REQUESTING_CALCULATION;
  UserStats userData;

  @override
  void initState() {
    calculator = StatsCalculator(
        db: widget.db,
        serverParks: widget.pm.allParksInfo,
        rideTypes: widget.pm.attractionTypes);
    _refreshCalculation();

    _tabController = TabController(length: 3, vsync: this);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _tabController.animation.addListener(() {
      _scrollController.jumpTo(
          _tabController.animation.value * MediaQuery.of(context).size.width);
    });
    super.didChangeDependencies();
  }

  Future<void> _refreshCalculation() async {
    _calculationState = CalculationState.REQUESTING_CALCULATION;
    Future<UserStats> newCalculation = calculator.countStats();
    setState(() {
      _calculationState = CalculationState.CALCULATING;
    });

    await newCalculation.then((UserStats value) {
      setState(() {
        userData = value;
        _calculationState = CalculationState.CALCULATED;
      });
      return;
    }, onError: (e) {
      setState(() {
        _calculationState = CalculationState.ERROR_CALCULATING;
      });
      Toast.show("Error Calculating Statistics", context,
          duration: Toast.LENGTH_SHORT);
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Container();
    if (userData == null) {
      List<Widget> content = <Widget>[];
      Function onTap = () {};
      if (_calculationState == CalculationState.ERROR_CALCULATING) {
        content = [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(FontAwesomeIcons.exclamation),
          ),
          Text("Error calculation Statistics - tap to try again.")
        ];
        onTap = _refreshCalculation;
      } else {
        content = [CircularProgressIndicator(), Text("Calculating Stats...")];
      }

      body = GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: content,
            ),
          ),
          onTap: onTap);
    } else {
      body = TabBarView(
        controller: _tabController,
        physics: PageScrollPhysics(),
        key: ValueKey(userData.hashCode),
        children: <Widget>[
          ParksStatsPage(stats: userData, refreshCallback: _refreshCalculation),
          AttractionsStatsPage(
              stats: userData, refreshCallback: _refreshCalculation),
          CoasterStatsPage(
            stats: userData,
            refreshCallback: _refreshCalculation,
          )
        ],
      );
    }

    SpinningIconButtonState spinState = SpinningIconButtonState.STOPPED;
    if (_calculationState == CalculationState.CALCULATING)
      spinState = SpinningIconButtonState.SPINNING;
    if (_calculationState == CalculationState.CALCULATED ||
        _calculationState == CalculationState.ERROR_CALCULATING)
      spinState = SpinningIconButtonState.STOPPED;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SpinningIconButton(
              icon: Icon(FontAwesomeIcons.sync),
              spinState: spinState,
              onTap: () {
                _refreshCalculation();
              },
            ),
          )
        ],
        title: ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            PageHeader(text: "PARKS STATS"),
            PageHeader(text: "ATTRACTIONS STATS"),
            PageHeader(text: "COASTERS")
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              text: "PARKS",
            ),
            Tab(text: "ATTRACTIONS"),
            Tab(text: "COASTERS"),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: body,
      ),
    );
  }
}
