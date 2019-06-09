import 'package:flutter/material.dart';

class TabNavigatorRoutes {
  static const String root = '/';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.rootWidget});
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget rootWidget;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => rootWidget
        );
      },
    );
  }
}
