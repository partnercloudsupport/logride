import 'package:flutter/material.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:log_ride/widgets/stats/countries_box.dart';
import 'package:log_ride/widgets/stats/sided_progress_bar.dart';
import 'package:log_ride/widgets/stats/top_scores.dart';

class ParksStatsPage extends StatelessWidget {
  ParksStatsPage({this.stats, this.refreshCallback});

  final UserStats stats;
  final Function refreshCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RefreshIndicator(
        onRefresh: refreshCallback,
        displacement: 20.0,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SidedProgressBar(
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
                  child: TopParkScores(
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
                  child: CountriesBox(
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
}
