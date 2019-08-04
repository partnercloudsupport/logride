import 'package:flutter/material.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:log_ride/ui/pages/settings/account_settings.dart';
import 'package:log_ride/ui/pages/settings/app_info.dart';
import 'package:log_ride/ui/pages/settings/geolocation_settings.dart';
import 'package:log_ride/ui/pages/settings/interface_settings.dart';
import 'package:log_ride/ui/pages/settings/park_settings.dart';
import 'package:log_ride/widgets/settings/account_tile.dart';
import 'package:log_ride/widgets/settings/settings_footer.dart';
import 'package:log_ride/widgets/settings/settings_tile.dart';
import 'package:package_info/package_info.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

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
                  title: "Park Settings",
                  subtitle: "Change the way parks behave",
                  showNavArrow: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          DefaultParkSettings())),
                ),
                SettingsTile(
                  title: "App Info",
                  subtitle: "View information about LogRide",
                  showNavArrow: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => AppInfoPage())),
                ),
                if (Provider.of<LogRideUser>(context).isAdmin ?? false)
                  SettingsTile(
                    title: "Admin Page 🎉",
                    subtitle: "You shouldn't see this",
                    showNavArrow: true,
                  ),
                SettingsFooter(
                  appVersion: snapshot?.data?.version ?? "error",
                ),
                /*

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
