import 'package:intl/intl.dart';

const DATE_FORMAT_STRING = "yyyy'-'MM'-'dd HH:mm:ss";

class BluehostNews {
  int newsID;
  bool active;
  bool priority;
  int parkId;
  int numberOfLikes;
  int startingNumberOfLikes;
  String mainParkName;
  String snippet;
  String sourceName;
  String sourceLink;
  String photoLink;
  String submittedBy;
  DateTime dateCreated;
  DateTime dateLastUpdated;

  bool liked = false;
  bool read = false;
  // Image something IDK

  BluehostNews(
      {this.newsID,
      this.active,
      this.priority,
      this.parkId,
      this.numberOfLikes,
      this.startingNumberOfLikes,
      this.mainParkName,
      this.snippet,
      this.sourceName,
      this.sourceLink,
      this.photoLink,
      this.submittedBy,
      this.dateCreated,
      this.dateLastUpdated});

  BluehostNews.fromJson(Map<String, dynamic> json) {
    newsID = num.parse(json['news_id']);
    active = (json['active'] == '1');
    priority = (json['priority'] == '1');
    parkId = num.parse(json['park_id']);
    numberOfLikes = num.parse(json['number_of_likes']);
    startingNumberOfLikes = num.parse(json['starting_number_of_likes']);
    mainParkName = json['main_park_name'];
    snippet = json['snippet'];
    sourceName = json['source_name'];
    sourceLink = json['source_link'];
    photoLink = json['photo_link'];
    submittedBy = json['submittedBy'];
    dateCreated = DateTime.parse(json['DateCreated']);
    dateLastUpdated = DateTime.parse(json['DateLastUpdated']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['news_id'] = this.newsID;
    data['active'] = this.active ? 1 : 0;
    data['priority'] = this.priority ? 1 : 0;
    data['park_id'] = this.parkId;
    data['number_of_likes'] = this.numberOfLikes;
    data['starting_number_of_likes'] = this.startingNumberOfLikes;
    data['main_park_name'] = this.mainParkName;
    data['snippet'] = this.snippet;
    data['source_name'] = this.sourceName;
    data['source_link'] = this.sourceLink;
    data['photo_link'] = this.photoLink;
    data['submittedBy'] = this.submittedBy;
    data['DateCreated'] =
        DateFormat(DATE_FORMAT_STRING).format(this.dateCreated);
    data['DateLastUpdated'] =
        DateFormat(DATE_FORMAT_STRING).format(this.dateLastUpdated);
    return data;
  }
}

class FirebaseNews {
  FirebaseNews({this.newsID, this.hasLiked, this.hasRead});

  int newsID;
  bool hasLiked;
  bool hasRead;

  FirebaseNews.fromJsonWithID(int id, Map<String, dynamic> json) {
    newsID = id;
    hasLiked = json['hasLiked'] ?? 'false' == 'true';
    hasRead = json['hasRead'] ?? 'false' == 'true';
  }

  FirebaseNews.fromJsonWithoutID(Map<String, dynamic> json) {
    newsID = json['articleID'];
    hasLiked = json['hasLiked'] ?? 'false' == 'true';
    hasRead = json['hasRead'] ?? 'false' == 'true';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['articleID'] = this.newsID;
    data['hasLiked'] = hasLiked ? 'true' : 'false';
    data['hasRead'] = hasRead ? 'true' : 'false';
    return data;
  }

  @override
  String toString() {
    return "{articleID: $newsID, hasLiked: $hasLiked, hasRead: $hasRead}";
  }
}

class NewsSubmission {
  NewsSubmission({this.url, this.description, this.username});

  String url;
  String description;
  String username;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['article_url'] = url;
    data['additional_notes'] = description;
    data['user_name'] = username;
    return data;
  }
}
