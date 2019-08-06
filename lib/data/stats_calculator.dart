import 'dart:async';
import 'dart:collection';

import 'package:latlong/latlong.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/manufacturer_structures.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/ride_type_structures.dart';

const int _MAX_LIST_SIZE = 5;
const int _RIDE_TYPE_COASTER = 1;

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
  Map<int, RideTypeStats> rideTypeStats = Map<int, RideTypeStats>();
  CoasterStats coasterStats = CoasterStats();

  Map<int, ManufacturerStats> totalManufacturerStats =
      Map<int, ManufacturerStats>();
  Map<int, ManufacturerStats> coasterManufacturerStats =
      Map<int, ManufacturerStats>();

  Map<List<String>, LatLng> parkLocations = Map<List<String>, LatLng>();
  LinkedHashMap<BluehostAttraction, int> topAttractions =
      LinkedHashMap<BluehostAttraction, int>();
  LinkedHashMap<BluehostPark, int> topParks =
      LinkedHashMap<BluehostPark, int>();

  UserStats(
      {this.activeAttractionsChecked = 0,
      this.totalAttractionsChecked = 0,
      this.totalCheckIns = 0,
      this.countries = 0,
      this.totalExperiences = 0,
      this.extinctAttractionsChecked = 0,
      this.totalParks = 0,
      this.parksCompleted = 0,
      List<RideType> rideTypes}) {
    rideTypes.forEach((t) {
      rideTypeStats[t.id] = RideTypeStats(label: t.label);
    });
  }

  UserStats.fromJson(Map<String, dynamic> json) {
    activeAttractionsChecked = json['activeAttractions'] ?? 0;
    totalAttractionsChecked = json['attractions'] ?? 0;
    totalCheckIns = json['checkIns'] ?? 0;
    countries = json['countries'] ?? 0;
    totalExperiences = json['experiences'] ?? 0;
    extinctAttractionsChecked = json['extinctAttracions'] ?? 0;
    totalParks = json['parks'] ?? 0;
    parksCompleted = json['parksCompleted'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activeAttractions'] = this.activeAttractionsChecked;
    data['attractions'] = this.totalAttractionsChecked;
    data['checkIns'] = this.totalCheckIns;
    data['experiences'] = this.totalExperiences;
    data['extinctAttracions'] = this.extinctAttractionsChecked;
    data['parks'] = this.totalParks;
    data['parksCompleted'] = this.parksCompleted;
    return data;
  }
}

class RideTypeStats {
  RideTypeStats({this.label, this.experienceCount = 0, this.checkCount = 0});

  String label;
  int experienceCount = 0;
  int checkCount = 0;
}

class CoasterStats {
  int coasterCount = 0;
  int experienceCount = 0;
  AttractionBundle tallest;
  AttractionBundle fastest;
  AttractionBundle timeLongest;
  AttractionBundle lengthLongest;
  num totalLength = 0;
  num totalTime = 0;
}

class ManufacturerStats {
  ManufacturerStats(
      {this.label, this.experienceCount = 0, this.checkCount = 0});

  String label;
  int experienceCount;
  int checkCount;
}

class StatsCalculator {
  StatsCalculator(
      {this.db, this.serverParks, this.rideTypes, this.manufacturers});

  final BaseDB db;
  final List<BluehostPark> serverParks;
  final List<RideType> rideTypes;
  final List<Manufacturer> manufacturers;

  void _setServerStats(UserStats stats) async {
    db.setEntryAtPath(
        path: DatabasePath.STATS,
        key: "life-time-stats",
        payload: stats.toJson());
  }

  Future<UserStats> countStats() async {
    // Since we're calculating user stats fresh each time, we don't have to wait for the old values to load
    UserStats stats = UserStats(rideTypes: rideTypes);

    print("Beginning Stats Count");

    // Base step: get user parks
    List<FirebasePark> userParks = List<FirebasePark>();
    dynamic rawResponse =
        await db.getEntryAtPath(path: DatabasePath.PARKS, key: "");

    // User doesn't have any park data to analyze, return the bare UserStats object
    if (rawResponse == null) {
      return stats;
    }

    print(rawResponse);

    List entries = Map.from(rawResponse).values.toList();

    print("Got ${entries.length} park entries");

    entries.forEach((e) {
      FirebasePark park = FirebasePark.fromMap(Map.from(e));
      if (park != null) {
        userParks.add(park);
      }
    });

    print("Added ${userParks.length} parks to the userParks list");

    List<String> countryLabelList = List<String>();

    print("Beginning to calculate park stats.");

    // Base Step: Calculate Park Stats
    for (int i = 0; i < userParks.length; i++) {
      FirebasePark park = userParks[i];

      // Sometime a null park pops up. Treat it like it doesn't exist and skip over it.
      if (park.name == null) continue;

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
          .getEntryAtPath(path: DatabasePath.ATTRACTIONS, key: "${park.parkID}")
          .timeout(Duration(milliseconds: 500), onTimeout: () => null);

      if (rawResponse != null) {
        List attractionEntries = List();

        // Occasionally, firebase will send us a "list" with a null entry instead
        // Not sure why, as the null entry does not appear in the firebase console.
        // In cases where this occurs, the map fails, so we just make it a list instead
        // and filter out the nulls.
        try {
          attractionEntries = Map.from(rawResponse).values.toList();
          print(attractionEntries);
        } catch (e) {
          print(e);
          List temp = List.from(rawResponse);
          temp.forEach((i) {
            if (i != null) {
              attractionEntries.add(i);
            }
          });
          print("OOpsed with map, result with list: $temp, $attractionEntries");
        }

        attractionEntries.forEach((data) {
          _calculateAttractionStats(data, stats, furtherData);
        });
      } else {
        continue;
      }
    }

    // Clear unknown attraction and manufacturers
    stats.rideTypeStats.removeWhere((i, t) => t.label == "");
    stats.totalManufacturerStats.removeWhere((i, t) => t.label == "");
    stats.coasterManufacturerStats.removeWhere((i, t) => t.label == "");

    stats.countries = countryLabelList.length;

    // Finally, we sort and chop the top lists

    print("Done with park stats");

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

    print("Statistics has been calculated, displaying results.");

    _setServerStats(stats);

    return stats;
  }

  Future<void> _calculateAttractionStats(
      dynamic data, UserStats stats, BluehostPark furtherData) {
    FirebaseAttraction attraction = FirebaseAttraction.fromMap(Map.from(data));
    BluehostAttraction attrData = getBluehostAttractionFromList(
        furtherData.attractions, attraction.rideID);

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
    // Update 8/5/2019 - I'm just going to ignore firebase and do my thing
    if (attrData.rideType != null &&
        attrData.rideType.id != null &&
        attrData.rideType.id != 0 &&
        stats.rideTypeStats.containsKey(attrData.rideType.id)) {
      RideTypeStats rideTypeStats = stats.rideTypeStats[attrData.rideType.id];
      rideTypeStats.checkCount++;
      rideTypeStats.experienceCount += attraction.numberOfTimesRidden ?? 0;
    }

    // Add our attraction to the top scores
    stats.topAttractions[attrData] = attraction.numberOfTimesRidden;

    // Coaster Stats - if our attraction is of type 2, Coaster, we need to do any and all logic related to being a roller coaster
    if (attrData.rideType != null &&
        attrData.rideType.id != null &&
        attrData.rideType.id == _RIDE_TYPE_COASTER) {
      calculateCoasterStats(stats, attraction, attrData, furtherData.parkName);
    }

    calculateManufacturerStats(stats, attraction, attrData);

    return null;
  }

  void calculateCoasterStats(UserStats stats, FirebaseAttraction attr,
      BluehostAttraction details, String parkName) {
    // Objects are passed as a reference in flutter, so we're fine
    CoasterStats coasterStats = stats.coasterStats;
    coasterStats.coasterCount++;
    coasterStats.experienceCount += attr.numberOfTimesRidden;

    // Find the fastest coaster
    if (coasterStats.fastest == null ||
        details.maxSpeed > coasterStats.fastest.bluehost.maxSpeed) {
      coasterStats.fastest = AttractionBundle(
          firebase: attr, bluehost: details, parkName: parkName);
    }

    // Find the tallest coaster
    if (coasterStats.tallest == null ||
        details.height > coasterStats.tallest.bluehost.height) {
      print("New tallest: ${details.attractionName}");
      coasterStats.tallest = AttractionBundle(
          firebase: attr, bluehost: details, parkName: parkName);
    }

    // Find the longest (time) coaster
    if (coasterStats.timeLongest == null ||
        details.attractionDuration >
            coasterStats.timeLongest.bluehost.attractionDuration) {
      coasterStats.timeLongest = AttractionBundle(
          firebase: attr, bluehost: details, parkName: parkName);
    }

    // Find the longest (track) coaster
    if (coasterStats.lengthLongest == null ||
        details.length > coasterStats.lengthLongest.bluehost.length) {
      coasterStats.lengthLongest = AttractionBundle(
          firebase: attr, bluehost: details, parkName: parkName);
    }

    // Calculate summed stats (total length, total time)
    coasterStats.totalLength += details.length * attr.numberOfTimesRidden;
    coasterStats.totalTime +=
        details.attractionDuration * attr.numberOfTimesRidden;

    // Handle coaster manufacturer stuff
    if (details.manufacturerID != 0) {
      // If our manufacturer doesn't exist in our manuStats, add them
      if (!stats.coasterManufacturerStats.containsKey(details.manufacturerID)) {
        stats.coasterManufacturerStats[details.manufacturerID] =
            ManufacturerStats(label: details.manufacturer);
      }

      // Add our attraction stats to the thing
      stats.coasterManufacturerStats[details.manufacturerID].checkCount++;
      stats.coasterManufacturerStats[details.manufacturerID].experienceCount +=
          attr.numberOfTimesRidden;
    }
  }

  void calculateManufacturerStats(
      UserStats stats, FirebaseAttraction attr, BluehostAttraction details) {
    if (details.manufacturerID != 0) {
      if (!stats.totalManufacturerStats.containsKey(details.manufacturerID)) {
        stats.totalManufacturerStats[details.manufacturerID] =
            ManufacturerStats(label: details.manufacturer);
      }

      stats.totalManufacturerStats[details.manufacturerID].checkCount++;
      stats.totalManufacturerStats[details.manufacturerID].experienceCount +=
          attr.numberOfTimesRidden;
    }
  }
}
