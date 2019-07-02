import 'package:intl/intl.dart';

const DATE_FORMAT_STRING = "yyyy'-'MM'-'dd HH:mm:ss";

class Manufacturer {
  int id;
  String name;
  String altName;
  bool active;
  String country;
  int yearOpen;
  int yearClosed;
  String website;
  String notes;
  int umbrellaId;
  DateTime dateTimeCreated;
  DateTime dateTimeLastUpdated;

  Manufacturer(
      {this.id,
      this.name,
      this.altName,
      this.active,
      this.country,
      this.yearOpen,
      this.yearClosed,
      this.website,
      this.notes,
      this.umbrellaId,
      this.dateTimeCreated,
      this.dateTimeLastUpdated});

  Manufacturer.fromJson(Map<String, dynamic> json) {
    id = num.parse(json['manufacturer_id']);
    name = json['manufacturer'];
    altName = json['manufacturer_alt_name'];
    active = (json['active'] == '1');
    country = json['country'];
    yearOpen = num.parse(json['year_open']);
    yearClosed = num.parse(json['year_closed']);
    website = json['website'];
    notes = json['notes'];
    umbrellaId = num.parse(json['umbrella_id']);
    dateTimeCreated = DateTime.parse(json['DateTime_Created']);
    dateTimeLastUpdated = DateTime.parse(json['DateTime_LastUpdated']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['manufacturer_id'] = this.id;
    data['manufacturer'] = this.name;
    data['manufacturer_alt_name'] = this.altName;
    data['active'] = this.active ? 1 : 0;
    data['country'] = this.country;
    data['year_open'] = this.yearOpen;
    data['year_closed'] = this.yearClosed;
    data['website'] = this.website;
    data['notes'] = this.notes;
    data['umbrella_id'] = this.umbrellaId;
    data['DateTime_Created'] =
        DateFormat(DATE_FORMAT_STRING).format(this.dateTimeCreated);
    data['DateTime_LastUpdated'] =
        DateFormat(DATE_FORMAT_STRING).format(this.dateTimeLastUpdated);
    return data;
  }
}

/// Returns the first instance of [Manufacturer] with the given ID in toSearch.
/// Returns NULL if no matching manufacturer is found.
Manufacturer getManufacturerById(List<Manufacturer> toSearch, int id) {
  for (int i = 0; i < toSearch.length; i++) {
    if (toSearch[i] == null) continue;
    if (toSearch[i].id == id) return toSearch[i];
  }
  return null;
}
