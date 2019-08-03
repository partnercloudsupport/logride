import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:provider/provider.dart';

class AccountTile extends StatelessWidget {
  AccountTile({this.onTap, this.showNavArrow = true});

  final Function onTap;
  final bool showNavArrow;

  @override
  Widget build(BuildContext context) {
    String proStatus; // TODO: implement pro features

    LogRideUser user = Provider.of<LogRideUser>(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage("assets/plain.png"),
      ),
      trailing: (onTap != null && showNavArrow)
          ? Icon(FontAwesomeIcons.angleRight)
          : null,
      title: Text(user.username),
      subtitle:
          Text("${user.email}${(proStatus != null) ? "\n$proStatus" : ""}"),
      isThreeLine: (proStatus != null),
      onTap: onTap,
    );
  }
}
