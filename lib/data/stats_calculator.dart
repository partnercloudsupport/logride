import 'dart:async';
import 'dart:collection';
import 'package:latlong/latlong.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';

const int _MAX_LIST_SIZE = 5;

class UserStats {
  // Park Related Stats
  int totalCheckIns;
  int totalParks;
  int parksCompleted;
  int countries;

  // Overall Attraction Stats
  int activeAttractionsChecked;
  int totalAttractionsChecked;
  int extinctAttractionsChecked;
  int totalExperiences;

  // Ride Type Specific Stats
  int rideTypeChildrensExperiences;
  int rideTypeChildrens;
  int rideTypeDarkRideExperiences;
  int rideTypeDarkRides;
  int rideTypeExploreExperiences;
  int rideTypeExplores;
  int rideTypeFilmExperiences;
  int rideTypeFilms;
  int rideTypeFlatRideExperiences;
  int rideTypeFlatRides;
  int rideTypeParadeExperience;
  int rideTypeParades;
  int rideTypePlayAreaExperiences;
  int rideTypePlayAreas;
  int rideTypeRollerCoasterExperiences;
  int rideTypeRollerCoasters;
  int rideTypeShowExperiences;
  int rideTypeShows;
  int rideTypeSpectacularExperiences;
  int rideTypeSpectaculars;
  int rideTypeTransportExperiences;
  int rideTypeTransports;
  int rideTypeChargeExperiences;
  int rideTypeChargeRides;
  int rideTypeWaterExperience;
  int rideTypeWaterRides;

  Map<List<String>, LatLng> parkLocations = Map<List<String>, LatLng>();
  LinkedHashMap<BluehostAttraction, int> topAttractions =
      LinkedHashMap<BluehostAttraction, int>();
  LinkedHashMap<BluehostPark, int> topParks =
      LinkedHashMap<BluehostPark, int>();

  UserStats(
      {this.activeAttractionsChecked = 0,
      this.totalAttractionsChecked = 0,
      this.totalCheckIns = 0,
      this.rideTypeChildrensExperiences = 0,
      this.rideTypeChildrens = 0,
      this.countries = 0,
      this.rideTypeDarkRides = 0,
      this.rideTypeDarkRideExperiences = 0,
      this.totalExperiences = 0,
      this.rideTypeExploreExperiences = 0,
      this.rideTypeExplores = 0,
      this.extinctAttractionsChecked = 0,
      this.rideTypeFilms = 0,
      this.rideTypeFilmExperiences = 0,
      this.rideTypeFlatRideExperiences = 0,
      this.rideTypeFlatRides = 0,
      this.rideTypeParades = 0,
      this.rideTypeParadeExperience = 0,
      this.totalParks = 0,
      this.parksCompleted = 0,
      this.rideTypePlayAreaExperiences = 0,
      this.rideTypePlayAreas = 0,
      this.rideTypeRollerCoasterExperiences = 0,
      this.rideTypeRollerCoasters = 0,
      this.rideTypeShowExperiences = 0,
      this.rideTypeShows = 0,
      this.rideTypeSpectacularExperiences = 0,
      this.rideTypeSpectaculars = 0,
      this.rideTypeTransportExperiences = 0,
      this.rideTypeTransports = 0,
      this.rideTypeChargeExperiences = 0,
      this.rideTypeChargeRides = 0,
      this.rideTypeWaterExperience = 0,
      this.rideTypeWaterRides = 0});

  UserStats.fromJson(Map<String, dynamic> json) {
    activeAttractionsChecked = json['activeAttractions'] ?? 0;
    totalAttractionsChecked = json['attractions'] ?? 0;
    totalCheckIns = json['checkIns'] ?? 0;
    rideTypeChildrensExperiences = json['childrensRideExperience'] ?? 0;
    rideTypeChildrens = json['childrensRides'] ?? 0;
    countries = json['countries'] ?? 0;
    rideTypeDarkRides = json['darkRides'] ?? 0;
    rideTypeDarkRideExperiences = json['darkRidesExperience'] ?? 0;
    totalExperiences = json['experiences'] ?? 0;
    rideTypeExploreExperiences = json['exploreExperience'] ?? 0;
    rideTypeExplores = json['exploreRides'] ?? 0;
    extinctAttractionsChecked = json['extinctAttracions'] ?? 0;
    rideTypeFilms = json['films'] ?? 0;
    rideTypeFilmExperiences = json['filmsExperience'] ?? 0;
    rideTypeFlatRideExperiences = json['flatRideExperience'] ?? 0;
    rideTypeFlatRides = json['flatRides'] ?? 0;
    rideTypeParades = json['parades'] ?? 0;
    rideTypeParadeExperience = json['paradesExperience'] ?? 0;
    totalParks = json['parks'] ?? 0;
    parksCompleted = json['parksCompleted'] ?? 0;
    rideTypePlayAreaExperiences = json['playAreaExperience'] ?? 0;
    rideTypePlayAreas = json['playAreas'] ?? 0;
    rideTypeRollerCoasterExperiences = json['rollerCoasterExperience'] ?? 0;
    rideTypeRollerCoasters = json['rollerCoasters'] ?? 0;
    rideTypeShowExperiences = json['showExperience'] ?? 0;
    rideTypeShows = json['shows'] ?? 0;
    rideTypeSpectacularExperiences = json['spectacularExperince'] ?? 0;
    rideTypeSpectaculars = json['spectaculars'] ?? 0;
    rideTypeTransportExperiences = json['transportExperience'] ?? 0;
    rideTypeTransports = json['transportRides'] ?? 0;
    rideTypeChargeExperiences = json['upchargeExperience'] ?? 0;
    rideTypeChargeRides = json['upchargeRides'] ?? 0;
    rideTypeWaterExperience = json['waterExperience'] ?? 0;
    rideTypeWaterRides = json['waterRides'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activeAttractions'] = this.activeAttractionsChecked;
    data['attractions'] = this.totalAttractionsChecked;
    data['checkIns'] = this.totalCheckIns;
    data['childrensRideExperience'] = this.rideTypeChildrensExperiences;
    data['childrensRides'] = this.rideTypeChildrens;
    data['countries'] = this.countries;
    data['darkRides'] = this.rideTypeDarkRides;
    data['darkRidesExperience'] = this.rideTypeDarkRideExperiences;
    data['experiences'] = this.totalExperiences;
    data['exploreExperience'] = this.rideTypeExploreExperiences;
    data['exploreRides'] = this.rideTypeExplores;
    data['extinctAttracions'] = this.extinctAttractionsChecked;
    data['films'] = this.rideTypeFilms;
    data['filmsExperience'] = this.rideTypeFilmExperiences;
    data['flatRideExperience'] = this.rideTypeFlatRideExperiences;
    data['flatRides'] = this.rideTypeFlatRides;
    data['parades'] = this.rideTypeParades;
    data['paradesExperience'] = this.rideTypeParadeExperience;
    data['parks'] = this.totalParks;
    data['parksCompleted'] = this.parksCompleted;
    data['playAreaExperience'] = this.rideTypePlayAreaExperiences;
    data['playAreas'] = this.rideTypePlayAreas;
    data['rollerCoasterExperience'] = this.rideTypeRollerCoasterExperiences;
    data['rollerCoasters'] = this.rideTypeRollerCoasters;
    data['showExperience'] = this.rideTypeShowExperiences;
    data['shows'] = this.rideTypeShows;
    data['spectacularExperince'] = this.rideTypeSpectacularExperiences;
    data['spectaculars'] = this.rideTypeSpectaculars;
    data['transportExperience'] = this.rideTypeTransportExperiences;
    data['transportRides'] = this.rideTypeTransports;
    data['upchargeExperience'] = this.rideTypeChargeExperiences;
    data['upchargeRides'] = this.rideTypeChargeRides;
    data['waterExperience'] = this.rideTypeWaterExperience;
    data['waterRides'] = this.rideTypeWaterRides;
    return data;
  }
}

class StatsCalculator {
  StatsCalculator({this.db, this.serverParks});

  final BaseDB db;
  final List<BluehostPark> serverParks;

  void _setServerStats(UserStats stats) async {
    db.setEntryAtPath(
        path: DatabasePath.STATS,
        key: "life-time-stats",
        payload: stats.toJson());
  }

  Future<UserStats> countStats() async {
    print("Beginning CountStats");
    // Since we're calculating user stats fresh each time, we don't have to wait for the old values to load
    UserStats stats = UserStats();

    // Base step: get user parks
    List<FirebasePark> userParks = List<FirebasePark>();
    dynamic rawResponse =
        await db.getEntryAtPath(path: DatabasePath.PARKS, key: "");

    List entries = Map.from(rawResponse).values.toList();

    entries.forEach((e) {
      FirebasePark park = FirebasePark.fromMap(Map.from(e));
      userParks.add(park);
    });

    List<String> countryLabelList = List<String>();

    // Base Step: Calculate Park Stats
    for (int i = 0; i < userParks.length; i++) {
      FirebasePark park = userParks[i];
      BluehostPark furtherData = getBluehostParkByID(serverParks, park.parkID);
      // For each park, we need to do a few things
      // 1) Add to checkins
      stats.totalCheckIns += park.numberOfCheckIns;
      stats.topParks[furtherData] = park.numberOfCheckIns;
      // 2) Add to totalParks
      stats.totalParks++;
      // 3) Check Countries
      if (!countryLabelList.contains(furtherData.parkCountry)) {
        countryLabelList.add(furtherData.parkCountry);
      }
      // 4) Check Completed
      if (park.totalRides == park.ridesRidden) {
        stats.parksCompleted++;
      }
      // 5) Add data to the locations list
      stats.parkLocations[[furtherData.parkName, furtherData.parkCountry]] =
          furtherData.location;

      // Then we run the loop for each of the user's attractions for the park
      dynamic rawResponse = await db
          .getEntryAtPath(path: DatabasePath.ATTRACTIONS, key: "${park.parkID}");
      if(rawResponse != null) {
        List attractionEntries = Map.from(rawResponse).values.toList();

        attractionEntries.forEach((data) {
          _calculateAttractionStats(data, stats, furtherData.attractions);
        });
      }
    }

    stats.countries = countryLabelList.length;

    // Finally, we sort and chop the top lists

    // TOP PARKS
    List<BluehostPark> topParkLabels =
        stats.topParks.keys.toList(growable: false);

    if (topParkLabels.length > 0) {
      topParkLabels.sort((a, b) {
        return stats.topParks[b].compareTo(stats.topParks[a]);
      });
      // Get only up to the first 10 list keys in the list
      int maxParkNum = (topParkLabels.length >= _MAX_LIST_SIZE)
          ? _MAX_LIST_SIZE
          : topParkLabels.length;

      topParkLabels =
          topParkLabels.getRange(0, maxParkNum).toList(growable: false);

      LinkedHashMap<BluehostPark, int> sortedParks =
          LinkedHashMap<BluehostPark, int>();
      topParkLabels.forEach((e) {
        sortedParks[e] = stats.topParks[e];
      });
      stats.topParks = sortedParks;
    }

    // TOP ATTRACTIONS
    List<BluehostAttraction> topAttractionLabels =
        stats.topAttractions.keys.toList(growable: false);

    if (topAttractionLabels.length > 0) {
      topAttractionLabels.sort((a, b) {
        return stats.topAttractions[b].compareTo(stats.topAttractions[a]);
      });

      int maxAttractionNum = (topAttractionLabels.length >= _MAX_LIST_SIZE)
          ? _MAX_LIST_SIZE
          : topAttractionLabels.length;
      topAttractionLabels = topAttractionLabels
          .getRange(0, maxAttractionNum)
          .toList(growable: false);
      LinkedHashMap<BluehostAttraction, int> sortedAttractions =
          LinkedHashMap<BluehostAttraction, int>();
      topAttractionLabels.forEach((e) {
        sortedAttractions[e] = stats.topAttractions[e];
      });
      stats.topAttractions = sortedAttractions;
    }

    print(stats.topAttractions.length);

    _setServerStats(stats);

    return stats;
  }

  Future<void> _calculateAttractionStats(dynamic data, UserStats stats, List<BluehostAttraction> furtherData){

    FirebaseAttraction attraction =
    FirebaseAttraction.fromMap(Map.from(data));
    BluehostAttraction attrData = getBluehostAttractionFromList(
        furtherData, attraction.rideID);

    // This traditionally happens when a user rides then removes an attraction. Data is still there, but just in case.
    if (attraction.numberOfTimesRidden <= 0) return null;

    // Increment totals
    stats.totalAttractionsChecked++;
    stats.totalExperiences += attraction.numberOfTimesRidden;

    if (attrData.active) {
      stats.activeAttractionsChecked++;
    } else {
      stats.extinctAttractionsChecked++;
    }


    // I'd REALLY love to do something different here, but since it's hard-coded in firebase, we're stuck with this
    switch (attrData.rideType) {
      case 1:
        stats.rideTypeRollerCoasters++;
        stats.rideTypeRollerCoasterExperiences +=
            attraction.numberOfTimesRidden;
        break;
      case 2:
        stats.rideTypeWaterRides++;
        stats.rideTypeWaterExperience += attraction.numberOfTimesRidden;
        break;
      case 3:
        stats.rideTypeChildrens++;
        stats.rideTypeChildrensExperiences +=
            attraction.numberOfTimesRidden;
        break;
      case 4:
        stats.rideTypeFlatRides++;
        stats.rideTypeFlatRideExperiences +=
            attraction.numberOfTimesRidden;
        break;
      case 5:
        stats.rideTypeTransports++;
        stats.rideTypeTransportExperiences +=
            attraction.numberOfTimesRidden;
        break;
      case 6:
        stats.rideTypeDarkRides++;
        stats.rideTypeDarkRideExperiences +=
            attraction.numberOfTimesRidden;
        break;
      case 7:
        stats.rideTypeExplores++;
        stats.rideTypeExploreExperiences +=
            attraction.numberOfTimesRidden;
        break;
      case 8:
        stats.rideTypeSpectaculars++;
        stats.rideTypeSpectacularExperiences +=
            attraction.numberOfTimesRidden;
        break;
      case 9:
        stats.rideTypeShows++;
        stats.rideTypeShowExperiences += attraction.numberOfTimesRidden;
        break;
      case 10:
        stats.rideTypeFilms++;
        stats.rideTypeFilmExperiences += attraction.numberOfTimesRidden;
        break;
      case 11:
        stats.rideTypeParades++;
        stats.rideTypeParadeExperience += attraction.numberOfTimesRidden;
        break;
      case 12:
        stats.rideTypePlayAreas++;
        stats.rideTypePlayAreaExperiences +=
            attraction.numberOfTimesRidden;
        break;
      case 13:
        stats.rideTypeChargeRides++;
        stats.rideTypeChargeExperiences += attraction.numberOfTimesRidden;
        break;
      default:
        print("Error with calculating stats - unknown ride type");
        break;
    }
    // Set add our attraction to the top scores
    stats.topAttractions[attrData] = attraction.numberOfTimesRidden;

    return null;
  }
}
