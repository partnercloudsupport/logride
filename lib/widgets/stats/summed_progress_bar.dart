import 'package:flutter/material.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/widgets/shared/progress_bars.dart';

/// A progress bar, showing the balance between left and right
class SummedProgressBar extends StatefulWidget {
  SummedProgressBar(
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
  _SummedProgressBarState createState() => _SummedProgressBarState();
}

class _SummedProgressBarState extends State<SummedProgressBar> {
  final TextStyle labelStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  // Used for smooth animation between states
  double oldRatio;

  // If our old state had a value, attempt to animate between that old one and the new one
  @override
  void didUpdateWidget(SummedProgressBar oldWidget) {
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
