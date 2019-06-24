import 'dart:math';

/// Contains various strings used for the loading page. Call [pick] to access.
class LoadingStrings{

  static const List<String> _strings = <String>[
    "Clearing Block Breaks",
    "Dispatching Ride Vehicles",
    "Buying Concessions",
    "Loading Fireworks",
    "Placing Winding Queues",
    "Training Employees",
    "Lubricating Coaster Wheels",
    "Standing in Line",
    "Inflating Balloons",
    "Cleaning 3D Glasses",
    "Santizing a Code V",
    "Installing Show Control",
    "Paging Operations",
    "Strobing the Yeti",
    "Delaying for Weather"
  ];

  /// Returns a random loading string from our list
  static String pick(){
    int index = Random().nextInt(_strings.length);
    return "${_strings[index]}...";
  }
}