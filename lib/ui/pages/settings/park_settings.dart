import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:preferences/preferences.dart';

class DefaultParkSettings extends StatefulWidget {
  @override
  _DefaultParkSettingsState createState() => _DefaultParkSettingsState();
}

class _DefaultParkSettingsState extends State<DefaultParkSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Park Settings"),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PreferencePage([
        SwitchPreference(
          "Hide Ignored Attractions",
          preferencesKeyMap[PREFERENCE_KEYS.HIDE_IGNORED],
          desc:
              "Ignored attractions ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.HIDE_IGNORED]) ? "will" : "will not"} be hidden in all parks",
          defaultVal: defaultPreferences[PREFERENCE_KEYS.HIDE_IGNORED],
          onChange: () {
            setState(() {});
            PrefService.notify(preferencesKeyMap[PREFERENCE_KEYS.HIDE_IGNORED]);
          },
        ),
        SwitchPreference(
          "Tally Mode",
          preferencesKeyMap[PREFERENCE_KEYS.INCREMENT_ON],
          desc:
              "Newly added parks ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.INCREMENT_ON]) ? "will" : "will not"} be in tally mode",
          defaultVal: defaultPreferences[PREFERENCE_KEYS.INCREMENT_ON],
          onChange: () {
            setState(() {});
            PrefService.notify(preferencesKeyMap[PREFERENCE_KEYS.INCREMENT_ON]);
          },
        ),
        SwitchPreference(
          "Show Defunct",
          preferencesKeyMap[PREFERENCE_KEYS.SHOW_DEFUNCT],
          desc:
              "Newly added parks ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SHOW_DEFUNCT]) ? "will" : "will not"} show defunct attractions by default",
          defaultVal: defaultPreferences[PREFERENCE_KEYS.SHOW_DEFUNCT],
          onChange: () {
            setState(() {});
            PrefService.notify(preferencesKeyMap[PREFERENCE_KEYS.SHOW_DEFUNCT]);
          },
        ),
        SwitchPreference(
          "Show Seasonal",
          preferencesKeyMap[PREFERENCE_KEYS.SHOW_SEASONAL],
          desc:
              "Newly added parks ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SHOW_SEASONAL]) ? "will" : "will not"} show seasonal attractions by default",
          defaultVal: defaultPreferences[PREFERENCE_KEYS.SHOW_SEASONAL],
          onChange: () {
            setState(() {});
            PrefService.notify(
                preferencesKeyMap[PREFERENCE_KEYS.SHOW_SEASONAL]);
          },
        ),
      ]),
    );
  }
}
