import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:preferences/preferences.dart';

Position _dakPosition = Position(latitude: 28.356993, longitude: -81.590357);

class CheckInManager {
  final BaseDB db;
  final List<BluehostPark> serverParks;
  final CheckInListenable listenable =
      CheckInListenable(CheckInData(null, false));
  final Function(int parkID) addPark;
  final LogRideUser user;

  var geolocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15,
      timeInterval: 1000); // Wait one minute between check-in thing
  StreamSubscription<Position> locationStream;
  Position lastPosition;

  static double checkInRange;

  CheckInManager({this.db, this.serverParks, this.addPark, this.user}) {
    checkInRange = PrefService.getDouble(
            preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE]) ??
        defaultPreferences[PREFERENCE_KEYS.GEOLOCATOR_RANGE];

    bool isEnabled = PrefService.getBool(
            preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION]) ??
        defaultPreferences[PREFERENCE_KEYS.ENABLE_GEOLOCATION];

    if (isEnabled) {
      locationStream =
          geolocator.getPositionStream(locationOptions).listen(_positionUpdate);
    } else {
      print("Geolocation is not enabled at this time");
    }

    // We need to pay attention to two things: Range and Enabled
    PrefService.onNotify(preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION],
        () => _enablePrefUpdate());
    PrefService.onNotify(preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE],
        () => _rangePrefUpdate());
    PrefService.onNotify(
        preferencesKeyMap[PREFERENCE_KEYS.SPOOF_DAK], () => _spoofPrefUpdate());
  }

  void deactivate() {
    PrefService.onNotifyRemove(
        preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION]);
    PrefService.onNotifyRemove(
        preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE]);
    PrefService.onNotifyRemove(preferencesKeyMap[PREFERENCE_KEYS.SPOOF_DAK]);
    locationStream?.cancel();
  }

  /// Called when the 'Enabled' preference changes. If it turns off, we cancel
  /// our subscription and clear our listenable. Turns on, begin our stream again.
  void _enablePrefUpdate() {
    bool isEnabled = PrefService.getBool(
        preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION]);
    if (isEnabled) {
      locationStream =
          geolocator.getPositionStream(locationOptions).listen(_positionUpdate);
    } else {
      // May be null if we didn't have a location stream to begin with
      locationStream?.cancel();
      // Reset our listenable to null
      listenable.value = CheckInData(null, false);
    }
  }

  /// Called when the 'Range' preference changes. When it does, we update our
  /// range variable, and then recalculate nearest park
  void _rangePrefUpdate() {
    checkInRange = PrefService.getDouble(
            preferencesKeyMap[PREFERENCE_KEYS.GEOLOCATOR_RANGE]) ??
        defaultPreferences[PREFERENCE_KEYS.GEOLOCATOR_RANGE];
    _positionUpdate(lastPosition);
  }

  void _spoofPrefUpdate() {
    bool spoofing =
        PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SPOOF_DAK]) &&
            user.isAdmin;
    if (spoofing) {
      _geolocatorCheck(_dakPosition);
    } else {
      if (PrefService.getBool(
              preferencesKeyMap[PREFERENCE_KEYS.ENABLE_GEOLOCATION]) &&
          lastPosition != null) {
        _geolocatorCheck(lastPosition);
      } else {
        listenable.value = CheckInData(null, false);
      }
    }
  }

  /// Callback for the geolocator position stream. Store our last position and then do something with it.
  void _positionUpdate(Position position) {
    lastPosition = position;
    if (user.isAdmin &&
        PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.SPOOF_DAK])) {
      _geolocatorCheck(_dakPosition);
    } else {
      _geolocatorCheck(position);
    }
  }

  /// Used to handle all the logic related to checking if the user is near a park.
  /// This is handled manually, as we want to check it once the user has updated their geolocation range, too.
  void _geolocatorCheck(Position position) async {
    print("position update");
    // Get the user's position...
    LatLng userPosition = _positionToLatLng(position);
    Map<BluehostPark, double> closestParks = Map<BluehostPark, double>();

    // Find the parks within check_in_range
    serverParks.forEach((park) {
      double userDistance = Distance().distance(userPosition, park.location);
      if (userDistance <= checkInRange) {
        // We're within check-in range for this park!
        closestParks[park] = userDistance;
      }
    });

    // If we don't have any parks within check-in-range, give up
    if (closestParks.length == 0) {
      listenable.value = CheckInData(null, false);
      return;
    }

    // Otherwise, find the closest park
    double closestDistance =
        checkInRange * 10; // Just get it silly far away. Just to be safe
    BluehostPark closestPark;
    closestParks.forEach((park, distance) {
      if (distance < closestDistance) {
        closestDistance = distance;
        closestPark = park;
      }
    });

    // Now that we have our closest park, we need to see if the user has already been there today
    DateTime today = DateTime.now();
    DateTime midnight = DateTime(today.year, today.month, today.day, 0);

    bool hasCheckedInToday = await db
        .getEntryAtPath(
            path: DatabasePath.PARKS, key: "${closestPark.id}/lastDayVisited")
        .then((value) async {
      // If there's no user data for checking in at this park, we know they haven't checked in today
      if (value == null) {
        return false;
      } else {
        // We've got data for the last day visited - now we see if the last day was within the last day
        double secondsSinceEpoch = (value as int)
            .toDouble(); // Again, time is stored in the firebase in seconds thanks to the iOS app
        DateTime lastDayVisited = DateTime.fromMillisecondsSinceEpoch(
            (secondsSinceEpoch * 1000).toInt());
        DateTime lastMidnightVisited = DateTime(
            lastDayVisited.year, lastDayVisited.month, lastDayVisited.day, 0);

        Duration difference = midnight.difference(lastMidnightVisited);

        bool checkedInToday = (difference.inHours >= 24) ? false : true;

        db.setEntryAtPath(
            path: DatabasePath.PARKS,
            key: "${closestPark.id}/checkedInToday",
            payload: false);

        return checkedInToday;
      }
    });

    // Establish a new value for our listenable
    listenable.value = CheckInData(closestPark, hasCheckedInToday);
    return;
  }

  void checkIn(int parkID) async {
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day, 0);

    // If the park hasn't been used before, add it to the user's data (properly)
    bool exists = await db.doesEntryExistAtPath(
        path: DatabasePath.PARKS, key: parkID.toString());
    if (!exists) {
      await addPark(parkID);
    }

    // Get the number of times the user has checked in to this park
    int checkinCount = (await db.getEntryAtPath(
            path: DatabasePath.PARKS, key: "$parkID/numberOfCheckIns") as int ??
        0);

    // Update accordingly
    db.updateEntryAtPath(path: DatabasePath.PARKS, key: "$parkID", payload: {
      "checkedInToday": true,
      "lastDayVisited": midnight.millisecondsSinceEpoch / 1000,
      "numberOfCheckIns": checkinCount + 1
    });

    listenable.value.checkedInToday = true;
    FirebaseAnalytics().logEvent(
        name: "check_into_park",
        parameters: {"parkName": listenable.value.park.parkName});
  }
}

class CheckInListenable extends ValueNotifier<CheckInData> {
  CheckInListenable(CheckInData value) : super(value);
}

class CheckInData {
  BluehostPark park;
  bool checkedInToday;
  CheckInData(this.park, this.checkedInToday);

  bool isEqualTo(CheckInData other) {
    return (park == other.park && checkedInToday == other.checkedInToday);
  }
}

LatLng _positionToLatLng(Position position) {
  return LatLng(position.latitude, position.longitude);
}
