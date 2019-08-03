import 'package:flutter/material.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/ui/pages/settings/account_settings.dart';
import 'package:log_ride/widgets/settings/account_tile.dart';
import 'package:log_ride/widgets/settings/settings_footer.dart';
import 'package:log_ride/widgets/settings/settings_tile.dart';
import 'package:package_info/package_info.dart';
import 'package:preferences/preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({this.onSignedOut});

  final Function onSignedOut;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double defaultGeo;
  double geoRange;

  Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  void initState() {
    super.initState();
    defaultGeo = defaultPreferences[PREFERENCE_KEYS.GEOLOCATOR_RANGE];
    geoRange = PrefService.getDouble(
            preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE]) ??
        defaultGeo;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: Text("Settings"),
              ),
              body: PreferencePage([
                AccountTile(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return AccountSettings(widget.onSignedOut);
                  })),
                ),
                SettingsTile(
                  title: "Interface Settings",
                  subtitle: "Change the way LogRide looks",
                  showNavArrow: true,
                ),
                SettingsTile(
                  title: "Geolocation Settings",
                  subtitle: "Change the way LogRide uses your GPS position",
                  showNavArrow: true,
                ),
                SettingsTile(
                  title: "Default Park Settings",
                  subtitle: "Change the way newly added parks behave",
                  showNavArrow: true,
                ),
                SettingsTile(
                  title: "App Info",
                  subtitle: "View information about LogRide",
                  showNavArrow: true,
                ),
                SettingsTile(
                  title: "Admin Page 🎉",
                  subtitle: "You shouldn't see this",
                  showNavArrow: true,
                ),
                SettingsFooter(
                  appVersion: snapshot?.data?.version ?? "error",
                ),
                /*
              PreferenceTitle("Account Settings"),
              InkWell(
                  onTap: () => print("Test"), child: PreferenceText("Sign Out")),
              InkWell(
                onTap: () => print("Delete"),
                child: PreferenceText("Delete Account"),
              ),
              PreferenceTitle("Interface Settings"),
              SwitchPreference(
                "Show Favorites in 'All Parks'",
                preferencesKeyMap[PREFERENCE_KEYS.SHOW_DUPED_FAVORITES],
                defaultVal:
                    defaultPreferences[PREFERENCE_KEYS.SHOW_DUPED_FAVORITES],
                desc:
                    "Turning this on places your favorite parks in both the Favorites and All Parks part of the 'My Parks' page. Default is on.",
              ),
              PreferenceTitle("Geolocation Settings"),
              SwitchPreference(
                "Enable Geolocation-based Check-in",
                preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION],
                defaultVal: defaultPreferences[PREFERENCE_KEYS.ENABLE_GEOLOCATION],
                desc:
                    "Turning this on allows LogRide to let you check-in to the park which you are physically in",
              ),
              SliderPreference(
                "Geolocator Range",
                preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE],
                defaultVal: defaultPreferences[PREFERENCE_KEYS.GEOLOCATOR_RANGE],
                desc:
                    "Parks within ${geoRange.toStringAsFixed(0)} ft (${(geoRange / 5820.0).toStringAsFixed(2)} miles) will appear for check-in. Default is $defaultGeo ft",
                min: 100.0,
                max: 4096.0,
                onChange: (double d) {
                  if (d != geoRange) setState(() => geoRange = d);
                },
              ),
              PreferenceTitle("Default Park Settings"),
              SwitchPreference("Experience Tally Mode",
                  preferencesKeyMap[PREFERENCE_KEYS.INCREMENT_ON],
                  defaultVal: defaultPreferences[PREFERENCE_KEYS.INCREMENT_ON],
                  desc:
                      "Turning this on makes new parks start in experience tally mode. Default is on."),
              SwitchPreference("Show Defunct Attractions",
                  preferencesKeyMap[PREFERENCE_KEYS.SHOW_DEFUNCT],
                  defaultVal: defaultPreferences[PREFERENCE_KEYS.SHOW_DEFUNCT],
                  desc:
                      "Turning this on lets new parks show defunct attractions by default. Default is on."),
              SwitchPreference("Experience Tally Mode",
                  preferencesKeyMap[PREFERENCE_KEYS.SHOW_SEASONAL],
                  defaultVal: defaultPreferences[PREFERENCE_KEYS.SHOW_SEASONAL],
                  desc:
                      "Turning this on lets new parks show seasonal attractions by default. Default is on."),
            */
              ]));
        });
  }
  /*

          // Account Settings
          // - Sign Out
          // - Delete Account (with confirm)
          // UI Settings
          // - Show Favorites in All Parks (favs duplication)
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(top: 12.0),
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
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: (description != null) ? Text(description) : null,
      onTap: () {
        if (onTap != null) onTap();
      },
    );
  }
  */
}
