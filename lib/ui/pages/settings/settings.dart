import 'package:flutter/material.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/ui/pages/settings/account_settings.dart';
import 'package:log_ride/ui/pages/settings/geolocation_settings.dart';
import 'package:log_ride/ui/pages/settings/interface_settings.dart';
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
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AccountSettings(widget.onSignedOut))),
                ),
                SettingsTile(
                  title: "Interface Settings",
                  subtitle: "Change the way LogRide looks",
                  showNavArrow: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => InterfaceSettings())),
                ),
                SettingsTile(
                  title: "Geolocation Settings",
                  subtitle: "Change the way LogRide uses your GPS position",
                  showNavArrow: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          GeolocationSettings())),
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
}
