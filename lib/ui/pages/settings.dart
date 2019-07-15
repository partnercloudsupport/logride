import 'package:flutter/material.dart';
import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({this.auth, this.uid});

  final BaseAuth auth;
  final String uid;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool showDupedFavorites = true;
  bool showDefunct = true;
  bool showSeasonal = true;
  bool incrementorOn = true;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showDupedFavorites =
        safelyGetPreference(prefs, PREFERENCE_KEYS.SHOW_DUPED_FAVORITES);
    showDefunct = safelyGetPreference(prefs, PREFERENCE_KEYS.SHOW_DEFUNCT);
    showSeasonal = safelyGetPreference(prefs, PREFERENCE_KEYS.SHOW_SEASONAL);
    incrementorOn = safelyGetPreference(prefs, PREFERENCE_KEYS.INCREMENT_ON);
    setState(() {});
  }

  Future<Null> storeBool(bool val, PREFERENCE_KEYS key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(preferencesKeyMap[key], val);
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: <Widget>[
          /*SwitchListTile.adaptive(
              title: Text("Test Toggle!"),
              value: testToggle,
              onChanged: (v) async {
                if (v != testToggle && v != null) {
                  testToggle = v;
                  storeBool(v, PREFERENCE_KEYS.TEST_TOGGLE);
                  setState(() {});
                }
              }),
          SwitchListTile.adaptive(
              title: Text("Show Duped Favorites"),
              value: showDupedFavorites,
              onChanged: (v) async {
                if (v != showDupedFavorites && v != null) {
                  showDupedFavorites = v;
                  storeBool(v, PREFERENCE_KEYS.SHOW_DUPED_FAVORITES);
                  setState(() {});
                }
              }),*/

          // Account Settings
          // - Sign Out
          // - Delete Account (with confirm)
          _settingsSectionHeader(context, "Account Settings"),
          _settingsTappableTile(context,
              label: "Account Information",
              description: "View information about your account",
              onTap: () {}),
          _settingsTappableTile(context,
              label: "Delete Account",
              description: "Permanently delete your account data.",
              onTap: () {}),
          // UI Settings
          // - Show Favorites in All Parks (favs duplication)
          _settingsSectionHeader(context, "Interface Settings"),
          _settingsToggle(context,
              value: showDupedFavorites,
              key: PREFERENCE_KEYS.SHOW_DUPED_FAVORITES,
              label: "Show Favorites in 'All Parks'",
              description:
                  "Favorite parks ${showDupedFavorites ? "will" : "won't"} show up in both the 'All Parks' section and the 'Favorites' section",
              updateValue: (v) {
            setState(() {
              showDupedFavorites = v;
            });
          }),
          // Park Default Settings
          // - Show Defunct/Seasonal default
          // - tally/toggle default
          _settingsSectionHeader(context, "Park Settings"),
          _settingsToggle(context,
              value: showDefunct,
              key: PREFERENCE_KEYS.SHOW_DEFUNCT,
              label: "Show Defunct Attractions",
              description:
                  "New parks ${showDefunct ? "do" : "don't"} show defunct attractions by default",
              updateValue: (v) {
            setState(() {
              showDefunct = v;
            });
          }),
          _settingsToggle(context,
              value: showSeasonal,
              key: PREFERENCE_KEYS.SHOW_SEASONAL,
              label: "Show Seasonal Attractions",
              description:
                  "New parks ${showSeasonal ? "do" : "don't"} show seasonal attractions by default",
              updateValue: (v) {
            setState(() {
              showSeasonal = v;
            });
          }),
          _settingsToggle(context,
              value: incrementorOn,
              key: PREFERENCE_KEYS.INCREMENT_ON,
              label: "Tally Mode",
              description:
                  "New parks ${incrementorOn ? "will" : "won't"} be in tally mode by default",
              updateValue: (v) {
            setState(() {
              incrementorOn = v;
            });
          }),
          // News Settings
          _settingsSectionHeader(context, "News Settings")
          // App info / contact
          // - Just like old info page
        ],
      ),
    );
  }

  Widget _settingsSectionHeader(BuildContext context, String headerTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            headerTitle,
            style: Theme.of(context).textTheme.title,
          ),
          Divider()
        ],
      ),
    );
  }

  Widget _settingsToggle(BuildContext context,
      {bool value,
      PREFERENCE_KEYS key,
      String label,
      String description,
      Function(bool) updateValue}) {
    return SwitchListTile.adaptive(
        value: value,
        title: Text(label ?? key.toString()),
        subtitle: Text(description ?? ""),
        onChanged: (v) async {
          if (v != value && v != null) {
            updateValue(v);
            storeBool(v, key);
          }
        });
  }

  Widget _settingsTappableTile(BuildContext context,
      {String label, String description, Function() onTap}) {
    return ListTile(
      title: Text(label),
      subtitle: (description != null) ? Text(description) : null,
      onTap: () {
        if (onTap != null) onTap();
      },
    );
  }
}
