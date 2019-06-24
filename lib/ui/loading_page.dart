import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:log_ride/data/loading_strings.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  Widget _displayWidget = Container();

  Timer timer;

  void _updateString() {
    setState(() {
      _displayWidget = _buildDisplayWidget(LoadingStrings.pick());
    });
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (t) => _updateString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _displayWidget = _buildDisplayWidget(LoadingStrings.pick());
  }

  @override
  void deactivate() {
    timer.cancel();

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      color: Theme.of(context).primaryColor,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Logo
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height / 6),
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 10.0)),
                  child: ClipOval(
                      child: Image.asset("assets/appicon.png",
                          height: MediaQuery.of(context).size.width / 2))),
            ),
            // Loading Circle
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _displayWidget,
            )
          ]),
    );
  }

  Widget _buildDisplayWidget(String string) {
    TextStyle style =
        Theme.of(context).textTheme.headline.apply(color: Colors.white);

    return AutoSizeText(string, style: style, key: ValueKey<String>(string),);
  }
}
