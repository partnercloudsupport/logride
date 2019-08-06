import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:log_ride/data/units.dart';
import 'package:log_ride/widgets/stats/coaster_superlative.dart';
import 'package:log_ride/widgets/stats/generic_stats_list.dart';
import 'package:log_ride/widgets/stats/generic_superlative.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
import 'package:log_ride/widgets/stats/user_superlative.dart';
import 'package:preferences/preferences.dart';

class CoasterStatsPage extends StatefulWidget {
  CoasterStatsPage({this.stats, this.refreshCallback});

  final UserStats stats;
  final Function refreshCallback;

  @override
  _CoasterStatsPageState createState() => _CoasterStatsPageState();
}

class _CoasterStatsPageState extends State<CoasterStatsPage> {
  @override
  void initState() {
    PrefService.onNotify(preferencesKeyMap[PREFERENCE_KEYS.USE_METRIC],
        () => (mounted) ? setState(() {}) : null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool useMetric =
        PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.USE_METRIC]);

    String speedUnits = useMetric ? "kph" : "mph";

    List<String> tallestDisplay = formatDistance(
        widget.stats.coasterStats.tallest?.bluehost?.height ?? 0, useMetric);
    String fastestDisplay = formatSpeed(
        widget.stats.coasterStats.fastest?.bluehost?.maxSpeed ?? 0, useMetric);
    List<String> longestLengthDisplay = formatDistance(
        widget.stats.coasterStats.lengthLongest?.bluehost?.length ?? 0,
        useMetric);
    List<String> traversedDisplay =
        formatDistance(widget.stats.coasterStats.totalLength ?? 0, useMetric);

    return Container(
        width: MediaQuery.of(context).size.width,
        child: RefreshIndicator(
            onRefresh: widget.refreshCallback,
            displacement: 20.0,
            child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: <Widget>[
                        HeaderStat(
                          stat: widget.stats.coasterStats.coasterCount,
                          text: "COASTERS COUNTED",
                          emphasis: 1.2,
                          bold: true,
                        ),
                        HeaderStat(
                          stat: widget.stats.coasterStats.experienceCount,
                          text: "COASTER EXPERIENCES: ",
                          padding: EdgeInsets.only(right: 16.0),
                          emphasis: 0.8,
                          leftAlign: false,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: StatlessHeader(
                            text: "COASTER SUPERLATIVES",
                          ),
                        ),
                        CoasterSuperlative(
                          label: "Tallest Coaster",
                          icon: FontAwesomeIcons.rulerVertical,
                          coaster: widget.stats.coasterStats.tallest,
                          alignment: CoasterSuperlativeAlignment.left,
                          superlative: tallestDisplay[0],
                          superlativeUnit: tallestDisplay[1],
                        ),
                        CoasterSuperlative(
                          label: "Fastest Coaster",
                          icon: FontAwesomeIcons.stopwatch,
                          coaster: widget.stats.coasterStats.fastest,
                          alignment: CoasterSuperlativeAlignment.left,
                          superlative: fastestDisplay,
                          superlativeUnit: speedUnits,
                        ),
                        CoasterSuperlative(
                          label: "Longest Coaster (By Track Length)",
                          icon: FontAwesomeIcons.rulerHorizontal,
                          coaster: widget.stats.coasterStats.lengthLongest,
                          alignment: CoasterSuperlativeAlignment.left,
                          superlative: longestLengthDisplay[0],
                          superlativeUnit: longestLengthDisplay[1],
                        ),
                        CoasterSuperlative(
                          label: "Longest Coaster (By Duration)",
                          icon: FontAwesomeIcons.clock,
                          coaster: widget.stats.coasterStats.timeLongest,
                          alignment: CoasterSuperlativeAlignment.left,
                          superlative: formatTime(widget.stats.coasterStats
                                  .timeLongest?.bluehost?.attractionDuration ??
                              0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: StatlessHeader(
                            text: "YOUR STATS",
                          ),
                        ),
                        UserSuperlative(
                          label: "Length of Track Traversed",
                          icon: FontAwesomeIcons.route,
                          superlativeUnit: traversedDisplay[1],
                          superlative: traversedDisplay[0],
                        ),
                        UserSuperlative(
                          label: "Time Spent on Coasters",
                          icon: FontAwesomeIcons.clock,
                          superlative: formatTime(
                              widget.stats.coasterStats.totalTime ?? 0),
                        ),
                        ManufacturerStatsSuperlative(
                          label: "TOP MANUFACTURER",
                          list: widget.stats.coasterManufacturerStats.values
                              .toList(),
                          persistKey: "coasterManufacturerStatsSort",
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ManufacturerStatsTable(
                            widget.stats.coasterManufacturerStats.values
                                .toList(),
                            persistKey: "coasterManufacturerTableSort",
                            alone: true,
                          ),
                        )
                      ],
                    )))));
  }

  /// Function that formats the numerical distance into a form that we find
  /// appropriate for our stats page. Index 0 is the distance, Index 2 is the unit.
  List<String> formatDistance(num distance, bool useMetric) {
    num newDist =
        useMetric ? convertUnit(distance, Unit.foot, Unit.meter) : distance;
    String unit = useMetric ? "meters" : "feet";

    num cutoffDist = useMetric ? 1000 : 5280;
    if (newDist > cutoffDist) {
      newDist = newDist / cutoffDist;
      unit = useMetric ? "kilometers" : "miles";
    }

    return [roundUnit(newDist, precision: 1).toString(), unit];
  }

  String formatSpeed(num speed, bool useMetric) {
    num newSpeed = useMetric ? convertUnit(speed, Unit.mph, Unit.kph) : speed;

    return roundUnit(newSpeed, precision: 1).toString();
  }

  String formatTime(num seconds) {
    // This will give us how many seconds to display
    num displaySeconds = seconds % 60;
    // All digits must be padded left
    String stringSeconds = displaySeconds.toString().padLeft(2, '0');

    // This will give us how many minutes to display
    num displayMinutes = (seconds ~/ 60) % 60;
    String stringMinutes = displayMinutes.toString().padLeft(2, '0');

    // This will give us how many hours to display
    num displayHours = ((seconds ~/ 60) % 60) ~/ 60;
    // Just kidding, hours don't get displays like that

    return "$displayHours:$stringMinutes:$stringSeconds";
  }
}
