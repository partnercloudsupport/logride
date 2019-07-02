import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/manufacturer_structures.dart';
import 'package:log_ride/data/model_structures.dart';
import 'package:log_ride/data/park_structures.dart';

/// Returns a [bool] whether the given [BluehostPark] is valid for the given search
bool isBluehostParkInSearch(BluehostPark park, String search) {
  search = search.toLowerCase();

  if (park.parkName.toLowerCase().contains(search) ||
      park.parkCity.toLowerCase().contains(search) ||
      park.parkCountry.toLowerCase().contains(search) ||
      park.previousNames.toLowerCase().contains(search) ||
      park.initials.toLowerCase().contains(search) ||
      park.id.toString().toLowerCase().contains(search)) return true;

  return false;
}

/// Returns a [bool] whether the given [FirebasePark] is valid for the given search
bool isFirebaseParkInSearch(FirebasePark park, String search) {
  search = search.toLowerCase();

  if (park.name.toLowerCase().contains(search) ||
      park.location.toLowerCase().contains(search) ||
      park.parkID.toString() == search) return true;

  return false;
}

/// Returns a [bool] whether the given [BluehostAttraction] is valid for the given search
bool isBluehostAttractionInSearch(BluehostAttraction attr, String search) {
  search = search.toLowerCase();

  if (attr.attractionName.toLowerCase().contains(search) ||
      attr.typeLabel.toLowerCase().contains(search) ||
      attr.attractionID.toString() == search ||
      attr.formerNames.join(" ").toLowerCase().contains(search) ||
      attr.yearOpen.toString() == search ||
      attr.yearClosed.toString() == search) return true;

  return false;
}

bool isManufacturerInSearch(Manufacturer m, String search) {
  search = search.toLowerCase();
  if (m.name.toLowerCase().contains(search) ||
      m.id.toString() == search ||
      m.altName.toLowerCase().contains(search) ||
      m.country.toLowerCase().contains(search)) return true;

  return false;
}

bool isModelInSearch(Model m, String search) {
  search = search.toLowerCase();
  if (m.name.toLowerCase().contains(search) ||
      m.id.toString() == search ||
      m.manufacturer.toLowerCase().contains(search) ||
      m.tags.toString().contains(search)) return true;

  return false;
}
