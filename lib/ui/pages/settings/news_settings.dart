import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
import 'package:preferences/preferences.dart';

class NewsSettingsPage extends StatefulWidget {
  @override
  _NewsSettingsPageState createState() => _NewsSettingsPageState();
}

class _NewsSettingsPageState extends State<NewsSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PadlessPageHeader(
          text: "NEWS SETTINGS",
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PreferencePage([
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SwitchPreference(
            "Filter News to only Parks News",
            preferencesKeyMap[PREFERENCE_KEYS.SHOW_MY_PARKS_NEWS],
            defaultVal: defaultPreferences[PREFERENCE_KEYS.SHOW_MY_PARKS_NEWS],
            onChange: () {
              PrefService.notify(
                  preferencesKeyMap[PREFERENCE_KEYS.SHOW_MY_PARKS_NEWS]);
              setState(() {});
            },
            desc:
                "LogRide ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SHOW_MY_PARKS_NEWS]) ? "will" : "will not"} filter news to show news relevant to your saved parks",
          ),
        ),
        SwitchPreference(
          "Unread News Indicator",
          preferencesKeyMap[PREFERENCE_KEYS.SHOW_PARKS_NEWS_NOTIFICATION],
          defaultVal:
              defaultPreferences[PREFERENCE_KEYS.SHOW_PARKS_NEWS_NOTIFICATION],
          onChange: () {
            PrefService.notify(preferencesKeyMap[
                PREFERENCE_KEYS.SHOW_PARKS_NEWS_NOTIFICATION]);
            setState(() {});
          },
          desc:
              "The \"News\" tab ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SHOW_PARKS_NEWS_NOTIFICATION]) ? "will" : "will not"} display an indicator for unread news",
        )
      ]),
    );
  }
}
