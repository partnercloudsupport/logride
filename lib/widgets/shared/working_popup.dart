import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum WorkingStatus { initializing, processing, error, complete }

/// Class used to control a [WorkingPopUp] widget.
class WorkingController {
  /// Determines how a [WorkingPopUp] is displayed.
  WorkingStatus status = WorkingStatus.initializing;

  /// The text that is displayed to the user.
  String workingText = "Working...";

  /// Double ranging from 0.0 to 1.0, controlling the display of the
  /// circular progress indicator.
  double progress = 0.0;

  WorkingController({this.status, this.workingText, this.progress});
}

class WorkingPopUp extends StatefulWidget {
  WorkingPopUp({this.controller, this.showProgress = false});

  final ValueNotifier<WorkingController> controller;
  final bool showProgress;

  @override
  State<StatefulWidget> createState() => _WorkingPopUpState();
}

class _WorkingPopUpState extends State<WorkingPopUp> with SingleTickerProviderStateMixin{
  AnimationController progressController;
  Animation<double> progressAnim;
  double oldProgress = 0.0;

  void progressAnimator() {
    double newProgress = widget.controller.value.progress ?? 0.0;
    if(newProgress == oldProgress) return;

    progressAnim = Tween(begin: oldProgress, end: newProgress).animate(progressController);
    progressController.forward();

    oldProgress = newProgress;
  }

  @override
  void initState() {
    progressController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100));

    progressAnim = Tween(begin: 0.0, end: 0.0).animate(progressController);

    widget.controller.addListener(progressAnimator);

    super.initState();
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(),
            color: Colors.black54,
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 2 / 5,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: ValueListenableBuilder<WorkingController>(
                  valueListenable: widget.controller,
                  builder: (BuildContext context, WorkingController status,
                      Widget _) {
                    return AspectRatio(
                      aspectRatio: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AnimatedBuilder(
                                animation: progressAnim, builder: (BuildContext context, Widget _) {
                                  return CircularProgressIndicator(
                                    value:
                                    progressAnim.value,
                                    valueColor: AlwaysStoppedAnimation(
                                        (status.status == WorkingStatus.error)
                                            ? Colors.redAccent
                                            : Theme.of(context).primaryColor),
                                  );
                            }),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                status.workingText ?? "Working...",
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
