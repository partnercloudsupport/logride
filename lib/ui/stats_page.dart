import 'dart:async';
import 'dart:collection';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:log_ride/ui/standard_page_structure.dart';
import 'package:log_ride/widgets/attraction_stats_list.dart';
import 'package:log_ride/widgets/content_frame.dart';
import 'package:log_ride/widgets/embedded_map_entry.dart';
import 'package:log_ride/widgets/page_controller_slider_bar.dart';
import 'package:log_ride/widgets/progress_bars.dart';

class StatsPage extends StatefulWidget {
  StatsPage({this.serverParks, this.db});

  final List<BluehostPark> serverParks;
  final BaseDB db;

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsCalculator calculator;
  Future<UserStats> statsFuture;

  PageController _pageController = PageController(keepPage: true);
  Color _leftTextColor = Colors.white;
  Color _rightTextColor = Colors.black;

  void _pageChanged(index) {
    if (index == 0) {
      setState(() {
        _leftTextColor = Colors.white;
        _rightTextColor = Colors.black;
      });
    } else {
      setState(() {
        _leftTextColor = Colors.black;
        _rightTextColor = Colors.white;
      });
    }
  }

  @override
  void initState() {
    calculator =
        StatsCalculator(db: widget.db, serverParks: widget.serverParks);

    statsFuture = calculator.countStats();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.transparent,
      body: StandardPageStructure(
        iconFunction: () => Navigator.of(context).pop(),
        iconDecoration: FontAwesomeIcons.chartPie,
        content: <Widget>[
          ContentFrame(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: FutureBuilder<UserStats>(
                future: statsFuture,
                builder: (BuildContext context, AsyncSnapshot<UserStats> snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Text("Calculating Stats...")
                        ],
                      ),
                    );
                  } else {
                    UserStats stats = snap.data;
                    return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 32.0),
                            child: Container(),
                          ),
                          // Title
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: PageControllerSliderBar(
                              pageController: _pageController,
                              leftText: "Parks",
                              leftTextColor: _leftTextColor,
                              rightText: "Attractions",
                              rightTextColor: _rightTextColor,
                              width: 325,
                              height: 30,
                            ),
                          ),
                          // Pages
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: _pageChanged,
                              physics: PageScrollPhysics(),
                              //physics: NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                _buildParksPage(context, stats),
                                _buildAttractionsPage(context, stats)
                              ],
                            ),
                          )
                        ],
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildParksPage(BuildContext context, UserStats stats) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _PageHeader(text: "PARKS STATS"),
            _SidedProgressBar(
              left: stats.parksCompleted,
              right: stats.totalParks,
              leftText: "Completed",
              rightText: "Experienced",
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
    );
  }

  Widget _buildAttractionsPage(BuildContext context, UserStats stats) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: <Widget>[
            _PageHeader(text: "ATTRACTION STATS"),
            _HeaderStat(
              stat: stats.totalAttractionsChecked,
              text: "CHECKED ATTRACTIONS"
            ),
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
                stat: stats.totalExperiences,
                text: "TOTAL EXPERIENCES"
            ),
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
              child: AttractionStats(
                stats: stats
              ),
            )
          ],
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
      width: double.infinity,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w800
        ),
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
          Text(stat.toString(), style: TextStyle(
            fontSize: 32.0, textBaseline: TextBaseline.alphabetic
          ),),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(text, style: TextStyle(
              fontSize: 22.0, textBaseline: TextBaseline.alphabetic
            ),),
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
          Text(text, style: TextStyle(
                fontSize: 22.0, textBaseline: TextBaseline.alphabetic
            ),),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ]..addAll(List<Widget>.generate(scores.length, (index) {
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
          })),
      ),
    );
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

class _SidedProgressBar extends StatelessWidget {
  _SidedProgressBar({this.left, this.right, this.shimmer = true, this.leftText, this.rightText});

  final int left;
  final int right;
  final bool shimmer;
  final String leftText;
  final String rightText;

  final TextStyle labelStyle =
  TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(left.toString(), style: labelStyle),
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
                            oldRatio: 0.0,
                            riddenCount: left,
                            totalCount: right,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Text(
              right.toString(),
              style: labelStyle,
            )
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              leftText,
              style: labelStyle,
            ),
            Expanded(
                child: Text(
                  rightText,
                  textAlign: TextAlign.right,
                  style: labelStyle,
                ))
          ],
        )
      ],
    );
  }
}

class _SummedProgressBar extends StatelessWidget {
  _SummedProgressBar({this.left, this.right, this.shimmer = true, this.leftText, this.rightText});

  final int left;
  final int right;
  final bool shimmer;
  final String leftText;
  final String rightText;

  final TextStyle labelStyle =
  TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(left.toString(), style: labelStyle),
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
                            oldRatio: 0.0,
                            riddenCount: left,
                            totalCount: left + right,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Text(
              right.toString(),
              style: labelStyle,
            )
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              leftText,
              style: labelStyle,
            ),
            Expanded(
                child: Text(
                  rightText,
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
                markers: mapData,
                generateCenter: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
