import 'package:flutter/material.dart';
import '../animations/auth_bubble_painter.dart';

class PageControllerSliderBar extends StatelessWidget {
  PageControllerSliderBar({
    this.pageController,
    this.height = 50, this.width = 300,
    this.leftText, this.rightText,
    this.leftTextColor, this.rightTextColor
  });

  final double height;
  final double width;
  final String leftText;
  final String rightText;
  final PageController pageController;
  final Color leftTextColor;
  final Color rightTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 221, 222, 224),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: pageController,
            dxEntry: (height / 2),
            dxTarget: width / 2 - (height / 2),
            dy: height / 2,
            radius: height / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  pageController.animateToPage(0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.decelerate);
                },
                child: Text(
                  leftText,
                  style: TextStyle(color: leftTextColor, fontSize: 16.0),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  pageController?.animateToPage(1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.decelerate);
                },
                child: Text(
                  rightText,
                  style: TextStyle(color: rightTextColor, fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}