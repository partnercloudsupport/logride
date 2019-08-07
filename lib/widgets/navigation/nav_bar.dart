import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/color_constants.dart';

class ContextNavBar extends StatelessWidget {
  ContextNavBar(
      {this.index = 0,
      this.height = 76,
      this.peek = 22,
      this.sink = 8,
      this.homeIndex = 0,
      this.menuTap,
      this.homeFocus,
      @required this.items});

  final int index;
  final double height;
  final double peek;
  final double sink;
  final int homeIndex;
  final Function menuTap;
  final List<ContextNavBarItem> items;
  final bool homeFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Stack(
        children: <Widget>[
          // Bar
          _buildBar(context),
          // Icon
          _buildContextButton(context),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    List<BottomNavigationBarItem> buttons = _buildNavBarItems();

    return Padding(
      padding: EdgeInsets.only(top: peek),
      child: BottomNavigationBar(
          onTap: menuTap,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: PROGRESS_BAR_DEFUNCT,
          selectedItemColor: Theme.of(context).primaryColor,
          currentIndex: index,
          items: buttons),
    );
  }

  List<BottomNavigationBarItem> _buildNavBarItems() {
    List<BottomNavigationBarItem> barItems = List<BottomNavigationBarItem>();

    int itemIndex = 0;
    for (int i = 0; i < items.length + 1; i++) {
      // Halfway though the list exists a spacer
      if (i == (items.length ~/ 2)) {
        barItems.add(BottomNavigationBarItem(
          title: Text(""),
          icon: Icon(Icons.error),
        ));
        continue;
      }

      barItems.add(BottomNavigationBarItem(
        icon: Stack(
          children: <Widget>[
            Icon(items[itemIndex].iconData),
            if (items[itemIndex].hasNotification)
              Positioned(
                top: 0.0,
                right: 0.0,
                child: Transform.translate(
                  offset: Offset(7, 0),
                  child: Icon(
                    Icons.brightness_1,
                    size: 10.0,
                    color: Colors.redAccent,
                  ),
                ),
              )
          ],
        ),
        title: Text(items[itemIndex].label),
      ));
      itemIndex++;
    }

    return barItems;
  }

  Widget _buildContextButton(BuildContext context) {
    Widget display = Image.asset("assets/plain.png");

    if (index == homeIndex) {
      if (homeFocus) {
        display = Container(
          constraints: BoxConstraints.expand(),
          child: Icon(
            FontAwesomeIcons.plus,
            color: APP_ICON_FOREGROUND,
            size: 48,
          ),
        );
      }
    }

    return ClipRect(
        child: Container(
      alignment: Alignment.center,
      transform: Matrix4.translationValues(0, sink, 0),
      foregroundDecoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: Colors.white)),
      decoration:
          BoxDecoration(color: APP_ICON_BACKGROUND, shape: BoxShape.circle),
      child: ClipOval(
          child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          children: <Widget>[
            AnimatedSwitcher(
              child: display,
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
            ),
            SizedBox.expand(
              child: MaterialButton(
                onPressed: () => menuTap(homeIndex),
              ),
            )
          ],
        ),
      )),
    ));
  }
}

class ContextNavBarItem {
  IconData iconData;
  String label;
  bool hasNotification;

  ContextNavBarItem(
      {this.iconData = Icons.settings,
      this.label = "test",
      this.hasNotification = false});
}
