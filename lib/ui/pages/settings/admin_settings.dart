import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:log_ride/widgets/settings/settings_tile.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

class AdminSettings extends StatefulWidget {
  @override
  _AdminSettingsState createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PadlessPageHeader(text: "ADMIN SETTINGS"),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PreferencePage([
        SwitchPreference(
          "Show Admin Features",
          preferencesKeyMap[PREFERENCE_KEYS.SHOW_ADMIN],
          defaultVal: defaultPreferences[PREFERENCE_KEYS.SHOW_ADMIN],
          desc:
              "Want to clean up? LogRide ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SHOW_ADMIN]) ? "will" : "will not"} show admin features",
          onChange: () {
            setState(() {});
            PrefService.notify(preferencesKeyMap[PREFERENCE_KEYS.SHOW_ADMIN]);
          },
        ),
        SwitchPreference(
          "Spoof Location to DAK",
          preferencesKeyMap[PREFERENCE_KEYS.SPOOF_DAK],
          defaultVal: defaultPreferences[PREFERENCE_KEYS.SPOOF_DAK],
          desc:
              "LogRide simulates that you ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SPOOF_DAK]) ? "are" : "are not"} in Disney's Animal Kingdom",
          onChange: () {
            setState(() {});
            PrefService.notify(preferencesKeyMap[PREFERENCE_KEYS.SPOOF_DAK]);
          },
        ),
        SettingsTile(
          title: "UUID",
          subtitle: Provider.of<LogRideUser>(context).uuid,
        )
      ]),
    );
  }
}
