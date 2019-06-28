import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong/latlong.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:log_ride/widgets/shared/spinning_iconbutton.dart';
import 'package:log_ride/widgets/stats_page/attraction_stats_list.dart';
import 'package:log_ride/widgets/shared/embedded_map_entry.dart';
import 'package:log_ride/widgets/shared/progress_bars.dart';
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
    calculator =
        StatsCalculator(db: widget.db, serverParks: widget.pm.allParksInfo);
    _refreshCalculation();

    _tabController = TabController(length: 2, vsync: this);

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
          _buildParksPage(context, userData),
          _buildAttractionsPage(context, userData)
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
            _PageHeader(text: "PARKS STATS"),
            _PageHeader(text: "ATTRACTIONS STATS")
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[Tab(text: "Parks"), Tab(text: "Attractions")],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: body,
      ),
    );
  }

  Widget _buildParksPage(BuildContext context, UserStats stats) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RefreshIndicator(
        onRefresh: _refreshCalculation,
        displacement: 20.0,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //_PageHeader(text: "PARKS STATS"),
                _SidedProgressBar(
                  left: stats.parksCompleted,
                  right: stats.totalParks,
                  leftText: "Completed",
                  rightText: "Saved",
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Divider(
                    height: 8.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _TopParkScores(
                    scores: stats.topParks,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Divider(
                    height: 8.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _CountriesBox(
                    countries: stats.countries,
                    mapData: stats.parkLocations,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttractionsPage(BuildContext context, UserStats stats) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RefreshIndicator(
        onRefresh: _refreshCalculation,
        displacement: 20.0,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: <Widget>[
                //_PageHeader(text: "ATTRACTION STATS"),
                _HeaderStat(
                    stat: stats.totalAttractionsChecked,
                    text: "CHECKED ATTRACTIONS"),
                _SummedProgressBar(
                  left: stats.activeAttractionsChecked,
                  right: stats.extinctAttractionsChecked,
                  leftText: "Active",
                  rightText: "Defunct",
                  shimmer: false,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Divider(
                    height: 8.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                _HeaderStat(
                    stat: stats.totalExperiences, text: "TOTAL EXPERIENCES"),
                _TopAttractionScores(
                  scores: stats.topAttractions,
                ),
                // Bottom padding is used so the user doesn't see it butting up right against the bottom
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Divider(
                    height: 8.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                _StatlessHeader(
                  text: "ATTRACTIONS OVERVIEW",
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AttractionStats(stats: stats),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  _PageHeader({this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 12.0, left: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  _HeaderStat({this.stat = 0, this.text});

  final num stat;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: <Widget>[
          Text(
            stat.toString(),
            style: TextStyle(
                fontSize: 32.0, textBaseline: TextBaseline.alphabetic),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 22.0, textBaseline: TextBaseline.alphabetic),
            ),
          )
        ],
      ),
    );
  }
}

class _StatlessHeader extends StatelessWidget {
  _StatlessHeader({this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
                fontSize: 22.0, textBaseline: TextBaseline.alphabetic),
          ),
        ],
      ),
    );
  }
}

class _TopScores extends StatelessWidget {
  _TopScores({this.title, this.unit, this.scores});

  final String title;
  final String unit;
  final LinkedHashMap<String, int> scores;

  final TextStyle entryStyle = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    Widget scoresDisplay = Container();
    List<Widget> scoresDisplayList = List<Widget>();

    if (scores.length <= 0) {
      scoresDisplay = Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text("No $unit"),
          ),
        ],
      );
    } else {
      scoresDisplayList = List<Widget>.generate(scores.length, (index) {
        // Build a row widget for each entry, append that to the column
        String key = scores.keys.elementAt(index);
        int score = scores[key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "${index + 1}.",
                    style: entryStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    key,
                    style: entryStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "$score $unit",
                    textAlign: TextAlign.right,
                    style: entryStyle,
                    maxLines: 1,
                  ),
                )
              ]),
        );
      });
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (scoresDisplayList.length > 0)
            ...scoresDisplayList
          else
            scoresDisplay
        ]));
  }
}

class _TopParkScores extends StatelessWidget {
  _TopParkScores({this.scores});

  final LinkedHashMap<BluehostPark, int> scores;

  @override
  Widget build(BuildContext context) {
    LinkedHashMap<String, int> displayScores = LinkedHashMap<String, int>();
    scores.keys.forEach((BluehostPark park) {
      displayScores[park.parkName] = scores[park];
    });

    return _TopScores(
      title: "TOP PARKS",
      unit: "check-ins",
      scores: displayScores,
    );
  }
}

class _TopAttractionScores extends StatelessWidget {
  _TopAttractionScores({this.scores});

  final LinkedHashMap<BluehostAttraction, int> scores;

  @override
  Widget build(BuildContext context) {
    LinkedHashMap<String, int> displayScores = LinkedHashMap<String, int>();
    scores.keys.forEach((BluehostAttraction attraction) {
      displayScores[attraction.attractionName] = scores[attraction];
    });

    return _TopScores(
      title: "TOP ATTRACTIONS",
      unit: "Exps.",
      scores: displayScores,
    );
  }
}

class _SidedProgressBar extends StatefulWidget {
  _SidedProgressBar(
      {this.left,
      this.right,
      this.shimmer = true,
      this.leftText,
      this.rightText});

  final int left;
  final int right;
  final bool shimmer;
  final String leftText;
  final String rightText;

  @override
  __SidedProgressBarState createState() => __SidedProgressBarState();
}

class __SidedProgressBarState extends State<_SidedProgressBar> {
  final TextStyle labelStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  // Used for smooth animation between states
  double oldRatio;

  // If our old state had a value, attempt to animate between that old one and the new one
  @override
  void didUpdateWidget(_SidedProgressBar oldWidget) {
    if (oldWidget.right != 0) {
      oldRatio = oldWidget.left / oldWidget.right;
    } else {
      if (widget.right != 0) {
        oldRatio = widget.left / widget.right;
      } else {
        oldRatio = 0.0;
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Calculating what value to animate from - if oldRatio is null, we have no animation
    if (oldRatio == null) {
      if (widget.right != 0) {
        oldRatio = widget.left / widget.right;
      } else {
        oldRatio = 0.0;
      }
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(widget.left.toString(), style: labelStyle),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  height: 10,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: PROGRESS_BAR_BACKING,
                      ),
                      AnimatedProgressBarManager(
                        oldRatio: oldRatio,
                        riddenCount: widget.left,
                        totalCount: widget.right,
                      ),
                    ],
                  ),
                ),
              ),
            )),
            Text(
              widget.right.toString(),
              style: labelStyle,
            )
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              widget.leftText,
              style: labelStyle,
            ),
            Expanded(
                child: Text(
              widget.rightText,
              textAlign: TextAlign.right,
              style: labelStyle,
            ))
          ],
        )
      ],
    );
  }
}

/// A progress bar, showing the balance between left and right
class _SummedProgressBar extends StatefulWidget {
  _SummedProgressBar(
      {this.left,
      this.right,
      this.shimmer = true,
      this.leftText,
      this.rightText});

  final int left;
  final int right;
  final bool shimmer;
  final String leftText;
  final String rightText;

  @override
  __SummedProgressBarState createState() => __SummedProgressBarState();
}

class __SummedProgressBarState extends State<_SummedProgressBar> {
  final TextStyle labelStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  // Used for smooth animation between states
  double oldRatio;

  // If our old state had a value, attempt to animate between that old one and the new one
  @override
  void didUpdateWidget(_SummedProgressBar oldWidget) {
    if (oldWidget.left + oldWidget.right != 0) {
      oldRatio = oldWidget.left / (oldWidget.left + oldWidget.right);
    } else {
      if (widget.left + widget.right != 0) {
        oldRatio = widget.left / (widget.left + widget.right);
      } else {
        oldRatio = 0.0;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Calculating what value to animate from - if oldRatio is null, we have no animation
    if (oldRatio == null) {
      if (widget.right + widget.left != 0) {
        oldRatio = widget.left / (widget.left + widget.right);
      } else {
        oldRatio = 0.0;
      }
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(widget.left.toString(), style: labelStyle),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  height: 10,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: PROGRESS_BAR_BACKING,
                      ),
                      AnimatedProgressBarManager(
                        oldRatio: oldRatio,
                        riddenCount: widget.left,
                        totalCount: widget.left + widget.right,
                        shimmer: widget.shimmer,
                      ),
                    ],
                  ),
                ),
              ),
            )),
            Text(
              widget.right.toString(),
              style: labelStyle,
            )
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              widget.leftText,
              style: labelStyle,
            ),
            Expanded(
                child: Text(
              widget.rightText,
              textAlign: TextAlign.right,
              style: labelStyle,
            ))
          ],
        )
      ],
    );
  }
}

class _CountriesBox extends StatelessWidget {
  _CountriesBox({this.mapData, this.countries});

  final Map<List<String>, LatLng> mapData;
  final num countries;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: <Widget>[
            Text(
              countries.toString(),
              style: TextStyle(
                  fontSize: 32, textBaseline: TextBaseline.alphabetic),
            ),
            Text(
              " VISITED COUNTRIES",
              textAlign: TextAlign.left,
              style: TextStyle(
                  textBaseline: TextBaseline.alphabetic,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300],
                    offset: Offset(0, 4),
                    blurRadius: 5)
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
                height: 200,
                child: TranslatedMapEntry(
                  center: LatLng(0, 0),
                  markers: mapData,
                  generateCenter: (mapData.length > 0),
                )),
          ),
        ),
      ],
    );
  }
}
