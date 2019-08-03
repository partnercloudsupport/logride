import 'package:flutter/material.dart';

class SettingsFooter extends StatelessWidget {
  SettingsFooter({this.appVersion});
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        "LogRide for Android | Version $appVersion",
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }
}
