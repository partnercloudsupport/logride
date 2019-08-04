import 'package:shared_preferences/shared_preferences.dart';

enum PREFERENCE_KEYS {
  SHOW_DUPED_FAVORITES,
  SHOW_DEFUNCT,
  SHOW_SEASONAL,
  INCREMENT_ON,
  ENABLE_GEOLOCATION,
  GEOLOCATOR_RANGE,
  USE_METRIC,
  UP_FRONT_ARTICLES,
}

Map<PREFERENCE_KEYS, String> preferencesKeyMap = {
  PREFERENCE_KEYS.SHOW_DUPED_FAVORITES: "showDupedFavorites",
  PREFERENCE_KEYS.SHOW_DEFUNCT: "showDefunct",
  PREFERENCE_KEYS.SHOW_SEASONAL: "showSeasonal",
  PREFERENCE_KEYS.INCREMENT_ON: "incrementOn",
  PREFERENCE_KEYS.ENABLE_GEOLOCATION: "geolocationEnabled",
  PREFERENCE_KEYS.GEOLOCATOR_RANGE: "geolocatorRange",
  PREFERENCE_KEYS.USE_METRIC: "useMetric",
  PREFERENCE_KEYS.UP_FRONT_ARTICLES: "articleUpFront"
};

Map<PREFERENCE_KEYS, dynamic> defaultPreferences = {
  PREFERENCE_KEYS.SHOW_DUPED_FAVORITES: true,
  PREFERENCE_KEYS.SHOW_DEFUNCT: true,
  PREFERENCE_KEYS.SHOW_SEASONAL: true,
  PREFERENCE_KEYS.INCREMENT_ON: true,
  PREFERENCE_KEYS.ENABLE_GEOLOCATION: true,
  PREFERENCE_KEYS.GEOLOCATOR_RANGE: 1609.0,
  PREFERENCE_KEYS.USE_METRIC: false,
  PREFERENCE_KEYS.UP_FRONT_ARTICLES: false
};

dynamic safelyGetPreference(SharedPreferences prefs, PREFERENCE_KEYS key) {
  dynamic value = prefs.get(preferencesKeyMap[key]) ?? defaultPreferences[key];
  return value;
}
