import 'package:flutter/material.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:log_ride/ui/dialogs/single_value_dialog.dart';
import 'package:log_ride/widgets/settings/account_tile.dart';
import 'package:log_ride/widgets/settings/settings_tile.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    LogRideUser user = Provider.of<LogRideUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings"),
      ),
      body: PreferencePage([
        // UserTile again (no arrow)
        AccountTile(),
        // Change Email button/field
        SettingsTile(
          title: "Change Email",
          subtitle: "Current Email: ${user.email}",
          onTap: () async {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SingleValueDialog(
                    title: "Change Email",
                    hintText: "example@example.com",
                    submitText: "Submit",
                    type: SingleValueDialogType.TEXT,
                    initialValue: user.email,
                  );
                });
          },
        ),
        // Change password button/field
        SettingsTile(title: "Change Password"),
        // Sign Out button
        SettingsTile(
          title: "Sign Out",
        ),
        // Delete Account button (in RED)
        SettingsTile(title: "Delete Account")
      ]),
    );
  }
}
