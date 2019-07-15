import 'package:shared_preferences/shared_preferences.dart';

enum PREFERENCE_KEYS {
  SHOW_DUPED_FAVORITES,
  SHOW_DEFUNCT,
  SHOW_SEASONAL,
  INCREMENT_ON
}

Map<PREFERENCE_KEYS, String> preferencesKeyMap = {
  PREFERENCE_KEYS.SHOW_DUPED_FAVORITES: "showDupedFavorites",
  PREFERENCE_KEYS.SHOW_DEFUNCT: "showDefunct",
  PREFERENCE_KEYS.SHOW_SEASONAL: "showSeasonal",
  PREFERENCE_KEYS.INCREMENT_ON: "incrementOn"
};

const Map<PREFERENCE_KEYS, dynamic> defaultPreferences = {
  PREFERENCE_KEYS.SHOW_DUPED_FAVORITES: true,
  PREFERENCE_KEYS.SHOW_DEFUNCT: true,
  PREFERENCE_KEYS.SHOW_SEASONAL: true,
  PREFERENCE_KEYS.INCREMENT_ON: true
};

dynamic safelyGetPreference(SharedPreferences prefs, PREFERENCE_KEYS key) {
  dynamic value = prefs.get(preferencesKeyMap[key]) ?? defaultPreferences[key];
  return value;
}
