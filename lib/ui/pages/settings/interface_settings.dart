import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/widgets/settings/toggle_tile.dart';
import 'package:preferences/preferences.dart';

class InterfaceSettings extends StatefulWidget {
  @override
  _InterfaceSettingsState createState() => _InterfaceSettingsState();
}

class _InterfaceSettingsState extends State<InterfaceSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Interface Settings"),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PreferencePage([
        TogglePreference(
          title: "Measurement Units",
          defaultVal: defaultPreferences[PREFERENCE_KEYS.USE_METRIC],
          localKey: preferencesKeyMap[PREFERENCE_KEYS.USE_METRIC],
          label1: "Metric",
          label2: "Imperial",
          subtitleBuilder: (v) {
            return "Units displayed will be part of the ${v ? "Metric" : "Imperial"} system";
          },
        ),
        SwitchPreference(
          "Show Duplicate Parks",
          preferencesKeyMap[PREFERENCE_KEYS.SHOW_DUPED_FAVORITES],
          defaultVal: defaultPreferences[PREFERENCE_KEYS.SHOW_DUPED_FAVORITES],
          desc:
              "Favorite parks ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SHOW_DUPED_FAVORITES]) ? "will" : "will not"} show up in both the 'Favorites' and 'All Parks' list. Defaults to ${defaultPreferences[PREFERENCE_KEYS.SHOW_DUPED_FAVORITES] ? "on" : "off"}.",
          onChange: () {
            setState(() {});
            PrefService.notify(
                preferencesKeyMap[PREFERENCE_KEYS.SHOW_DUPED_FAVORITES]);
          },
        ),
        /*

        // TODO: Implement "Articles Up Front" when I figure out where to properly inject the formatted names

        SwitchPreference(
          "Articles Up Front",
          preferencesKeyMap[PREFERENCE_KEYS.UP_FRONT_ARTICLES],
          defaultVal: defaultPreferences[PREFERENCE_KEYS.UP_FRONT_ARTICLES],
          desc:
              "Attraction Names ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.UP_FRONT_ARTICLES]) ? "will" : "will not"} have articles such as 'The' and 'A' appear in the front of their name. Defaults to ${defaultPreferences[PREFERENCE_KEYS.UP_FRONT_ARTICLES] ? "on" : "off"}.",
          onChange: () {
            setState(() {});
            PrefService.notify(
                preferencesKeyMap[PREFERENCE_KEYS.UP_FRONT_ARTICLES]);
          },
        )*/
      ]),
    );
  }
}
