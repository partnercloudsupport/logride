import 'package:intl/intl.dart';

const DATE_FORMAT_STRING = "yyyy'-'MM'-'dd HH:mm:ss";

class Model {
  int id;
  int manufacturerId;
  String manufacturer;
  String name;
  int modelType;
  String tags;
  String specsLink;
  String imageLink;
  num height;
  num width;
  num length;
  int capacity;
  String notes;
  DateTime dateTimeCreated;
  DateTime dateTimeLastUpdated;

  Model(
      {this.id,
      this.manufacturerId,
      this.manufacturer,
      this.name,
      this.modelType,
      this.tags,
      this.specsLink,
      this.imageLink,
      this.height,
      this.width,
      this.length,
      this.capacity,
      this.notes,
      this.dateTimeCreated,
      this.dateTimeLastUpdated});

  Model.fromJson(Map<String, dynamic> json) {
    id = num.parse(json['model_id']);
    manufacturerId = num.parse(json['manufacturer_id']);
    manufacturer = json['manufacturer'];
    name = json['model'];
    modelType = num.parse(json['ModelType']);
    tags = json['tags'];
    specsLink = json['specs_link'];
    imageLink = json['image_link'];
    height = num.parse(json['height']);
    width = num.parse(json['width']);
    length = num.parse(json['length']);
    capacity = num.parse(json['capacity']);
    notes = json['notes'];
    dateTimeCreated = DateTime.parse(json['DateTime_Created']);
    dateTimeLastUpdated = DateTime.parse(json['DateTime_LastUpdated']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['model_id'] = this.id;
    data['manufacturer_id'] = this.manufacturerId;
    data['manufacturer'] = this.manufacturer;
    data['model'] = this.name;
    data['ModelType'] = this.modelType;
    data['tags'] = this.tags;
    data['specs_link'] = this.specsLink;
    data['image_link'] = this.imageLink;
    data['height'] = this.height;
    data['width'] = this.width;
    data['length'] = this.length;
    data['capacity'] = this.capacity;
    data['notes'] = this.notes;
    data['DateTime_Created'] =
        DateFormat(DATE_FORMAT_STRING).format(this.dateTimeCreated);
    data['DateTime_LastUpdated'] =
        DateFormat(DATE_FORMAT_STRING).format(this.dateTimeLastUpdated);
    return data;
  }
}
