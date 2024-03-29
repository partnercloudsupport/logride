import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shimmer/shimmer.dart';
import 'package:log_ride/data/color_constants.dart';

/// [ParkProgessListItem] is a small progressbar overlaid with text, documenting how many
/// [numRides] a park has and comparing that to the user's [numRidden]
/// [numRides] - a number representing how many rides are in a park
/// [numRidden] - a number representing how many rides the user has ridden at
///   least once in the park
class ParkProgressListItem extends StatelessWidget {
  ParkProgressListItem({this.numRides, this.numRidden, this.barColor});

  final num numRides;
  final num numRidden;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    double ratio = 0.0;
    if (numRides != 0.0) ratio = numRidden / numRides;

    return Container(
        // Hard-coding the size of the box in dp. This may change later.
        constraints: BoxConstraints.loose(Size(62.0, 32.0)),
        // Stack contains two elements, the clipped bar and the text on top
        child: Stack(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      color: PROGRESS_BAR_BACKING,
                      constraints: BoxConstraints.expand(),
                    ),
                    FractionBar(
                        ratio: ratio,
                        barColor: barColor ?? Colors.green)
                  ],
                )),
            Center(
                child: AutoSizeText(
              "$numRidden/$numRides",
              textScaleFactor: 1.4,
              style: Theme.of(context).textTheme.body2,
            )),
          ],
        ));
  }
}

class FullParkProgressBar extends StatelessWidget {
  FullParkProgressBar(
      {this.showDefunct,
      this.showSeasonal,
      this.totalCount,
      this.riddenCount,
      this.defunctCount,
      this.seasonalCount,
      this.oldRatio,
      this.barColor});
  final bool showDefunct, showSeasonal;
  final int totalCount, riddenCount, defunctCount, seasonalCount;
  final double oldRatio;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      child: Stack(
        children: <Widget>[
          _buildProgressBar(context),
          // Background bar, full width
          // Text overlay - Progress
          _buildProgressLabel(context),
          showDefunct && (defunctCount != 0)
              ? _buildDefunctLabel(context)
              : Container(),
          showSeasonal && (seasonalCount != 0)
              ? _buildSeasonalLabel(context)
              : Container()
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Background - full bar with blank decor
        Container(
          color: PROGRESS_BAR_BACKING,
          constraints: BoxConstraints.expand(),
        ),
        // Foreground - percentage bar with progress color
        AnimatedProgressBarManager(
            totalCount: totalCount,
            riddenCount: riddenCount,
            oldRatio: oldRatio,
            barColor: barColor ?? Colors.green)
      ],
    );
  }

  Widget _buildProgressLabel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Progress: $riddenCount/$totalCount",
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
        )
      ],
    );
  }

  Widget _buildDefunctLabel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            "Defunct: $defunctCount",
            textAlign: TextAlign.right,
            textScaleFactor: 1.2,
          ),
        )
      ],
    );
  }

  Widget _buildSeasonalLabel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Seasonal: $seasonalCount",
            textAlign: TextAlign.left,
            textScaleFactor: 1.2,
          ),
        )
      ],
    );
  }
}

class AnimatedProgressBarManager extends StatefulWidget {
  AnimatedProgressBarManager(
      {this.totalCount,
      this.riddenCount,
      this.oldRatio,
      this.shimmer = true,
      this.barColor});

  final int totalCount, riddenCount;
  final double oldRatio;
  final bool shimmer;
  final Color barColor;

  @override
  State<StatefulWidget> createState() => _AnimatedProgressBarManagerState();
}

class _AnimatedProgressBarManagerState extends State<AnimatedProgressBarManager>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    double targetRatio = 0.0;
    if (widget.totalCount != 0.0)
      targetRatio = widget.riddenCount / widget.totalCount;

    animation =
        Tween(begin: widget.oldRatio, end: targetRatio).animate(controller);
    controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBarManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.dispose();

    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    double targetRatio = 0.0;
    if (widget.totalCount != 0.0)
      targetRatio = widget.riddenCount / widget.totalCount;

    animation =
        Tween(begin: widget.oldRatio, end: targetRatio).animate(controller);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Background - full bar with blank decor
        Container(
          color: PROGRESS_BAR_BACKING,
          constraints: BoxConstraints.expand(),
        ),
        // Foreground - percentage bar with progress color
        AnimatedFractionBar(animation: animation, shimmer: widget.shimmer, barColor: widget.barColor ?? Colors.green)
      ],
    );
  }
}

class AnimatedFractionBar extends AnimatedWidget {
  AnimatedFractionBar(
      {Key key, Animation<double> animation, this.shimmer = true, this.barColor})
      : super(key: key, listenable: animation);

  final bool shimmer;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    if (animation.value == 1.0 && shimmer) {
      return Shimmer.fromColors(
        child: Container(
            constraints: BoxConstraints.expand(), color: PROGRESS_BAR_GOLD),
        baseColor: PROGRESS_BAR_GOLD,
        highlightColor: PROGRESS_BAR_GOLD_SHIMMER,
        period: const Duration(milliseconds: 2500),
      );
    } else {
      return FractionallySizedBox(
          widthFactor: animation.value,
          heightFactor: 1.0,
          child: Container(
            color: barColor ?? Colors.green,
            constraints: BoxConstraints.expand(),
          ));
    }
  }
}

class FractionBar extends StatelessWidget {
  FractionBar({this.ratio, this.barColor});
  final double ratio;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    if (ratio == 1.0) {
      return Shimmer.fromColors(
        child: Container(
            constraints: BoxConstraints.expand(), color: PROGRESS_BAR_GOLD),
        baseColor: PROGRESS_BAR_GOLD,
        highlightColor: PROGRESS_BAR_GOLD_SHIMMER,
        period: const Duration(milliseconds: 2500),
      );
    } else {
      return FractionallySizedBox(
        widthFactor: ratio,
        heightFactor: 1.0,
        child: Container(
          color: barColor ?? Colors.green,
          constraints: BoxConstraints.expand(),
        ),
      );
    }
  }
}
