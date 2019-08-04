import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/units.dart';
import 'package:log_ride/widgets/forms/preference_slider.dart';
import 'package:preferences/preferences.dart';

class GeolocationSettings extends StatefulWidget {
  @override
  _GeolocationSettingsState createState() => _GeolocationSettingsState();
}

class _GeolocationSettingsState extends State<GeolocationSettings> {
  double displayGeoRange;

  @override
  void initState() {
    super.initState();
    displayGeoRange = PrefService.getDouble(
            preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE]) ??
        defaultPreferences[PREFERENCE_KEYS.GEOLOCATOR_RANGE];
  }

  @override
  Widget build(BuildContext context) {
    double geoRange = displayGeoRange;
    double defaultRange = defaultPreferences[PREFERENCE_KEYS.GEOLOCATOR_RANGE];
    double smallRange = geoRange / 5280.0;
    bool useMetric =
        PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.USE_METRIC]) ??
            defaultPreferences[PREFERENCE_KEYS.USE_METRIC];
    if (useMetric) {
      geoRange = convertUnit(geoRange, Unit.foot, Unit.meter);
      defaultRange = convertUnit(defaultRange, Unit.foot, Unit.meter);
      smallRange = geoRange / 1000.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Geolocation Settings"),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PreferencePage([
        // Use Geolocation
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SwitchPreference(
            "Enable Geolocation",
            preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION],
            defaultVal: defaultPreferences[PREFERENCE_KEYS.ENABLE_GEOLOCATION],
            desc:
                "LogRide ${PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION]) ? "will" : "will not"} use your GPS location to determine which park you are in. Defaults to ${defaultPreferences[PREFERENCE_KEYS.ENABLE_GEOLOCATION] ? "on" : "off"}",
            onChange: () {
              PrefService.notify(
                  preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION]);
              setState(() {});
            },
          ),
        ),
        // Geolocation Range
        SliderPreference(
          "Geolocator Range",
          preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE],
          defaultVal: defaultPreferences[PREFERENCE_KEYS.GEOLOCATOR_RANGE],
          desc:
              "Parks within ${geoRange.truncate()} ${useMetric ? "m" : "ft"} (${smallRange.toStringAsFixed(2)} ${useMetric ? "km" : "miles"}) will appear for check-in. Default is ${defaultRange.truncate()} ${useMetric ? "m" : "ft"}",
          max: 5280,
          min: 0,
          onChangeEnd: (v) {
            PrefService.notify(
                preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE]);
          },
          onChange: (v) => setState(() => displayGeoRange = v),
        )
        // Send notification TODO: Implement Geolocation Check-in Notification
      ]),
    );
  }
}
