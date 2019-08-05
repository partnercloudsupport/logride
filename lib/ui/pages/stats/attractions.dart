import 'package:flutter/material.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
import 'package:log_ride/widgets/stats/summed_progress_bar.dart';
import 'package:log_ride/widgets/stats/top_scores.dart';
import 'package:log_ride/widgets/stats/attraction_stats_list.dart';

class AttractionsStatsPage extends StatelessWidget {
  AttractionsStatsPage({this.stats, this.refreshCallback});

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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: <Widget>[
                //_PageHeader(text: "ATTRACTION STATS"),
                HeaderStat(
                    stat: stats.totalAttractionsChecked,
                    text: "CHECKED ATTRACTIONS"),
                SummedProgressBar(
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
                HeaderStat(
                    stat: stats.totalExperiences, text: "TOTAL EXPERIENCES"),
                TopAttractionScores(
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
                StatlessHeader(
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
