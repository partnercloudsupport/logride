import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/widgets/settings/toggle_tile.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
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
        title: PadlessPageHeader(text: "Interface Settings"),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PreferencePage([
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TogglePreference(
            title: "Measurement Units",
            defaultVal: defaultPreferences[PREFERENCE_KEYS.USE_METRIC],
            localKey: preferencesKeyMap[PREFERENCE_KEYS.USE_METRIC],
            label1: "Metric",
            label2: "Imperial",
            subtitleBuilder: (v) {
              return "Units displayed will be part of the ${v ? "Metric" : "Imperial"} system";
            },
            onChange: () {
              PrefService.notify(preferencesKeyMap[PREFERENCE_KEYS.USE_METRIC]);
            },
          ),
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
        SwitchPreference(
          "Hide Empty Stats",
          preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS],
          defaultVal: defaultPreferences[PREFERENCE_KEYS.HIDE_EMPTY_STATS],
          desc:
              "Empty Ride Type Categories on the Stats page ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS]) ? "will" : "will not"} be hidden from view",
          onChange: () {
            setState(() {});
            PrefService.notify(
                preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS]);
          },
        )
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
