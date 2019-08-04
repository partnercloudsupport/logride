import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:preferences/preferences.dart';

const double _m_to_ft = 3.28084;
const double _kph_to_mph = 0.621371;

enum Unit { meter, foot, kph, mph }

/// Converts the unit from [from] to [to]. Do note that it's pretty simple right now,
/// and is really just converting [from] to the opposite of it (meters <-> feet)
/// and (kph <-> mph). If [from] is the same as [to] then it just returns the value
double displayUnit(num value, Unit from, Unit to) {
  if (from == to) return value;

  switch (from) {
    // Meters can only go to foot
    case Unit.meter:
      return value * _m_to_ft;
    case Unit.foot:
      return value / _m_to_ft;
    case Unit.kph:
      return value * _kph_to_mph;
    case Unit.mph:
      return value / _kph_to_mph;
  }
  return value;
}

/// Returns a string built with the value and unit appropriate according to the
/// USE_METRIC setting. Returns the value if something goes wrong.
String prefDisplay(num value, Unit base) {
  bool usingMetric =
      PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.USE_METRIC]) ??
          false;
  switch (base) {
    case Unit.meter:
      return (usingMetric)
          ? "$value m"
          : "${displayUnit(value, base, Unit.foot).toStringAsFixed(1)} ft";
    case Unit.foot:
      return (usingMetric)
          ? "${displayUnit(value, base, Unit.meter).toStringAsFixed(1)} m"
          : "$value ft";
    case Unit.kph:
      return (usingMetric)
          ? "$value kph"
          : "${displayUnit(value, base, Unit.mph).toStringAsFixed(1)} mph";
    case Unit.mph:
      return (usingMetric)
          ? "${displayUnit(value, base, Unit.kph).toStringAsFixed(1)} kph"
          : "$value mph";
  }

  return "$value";
}
