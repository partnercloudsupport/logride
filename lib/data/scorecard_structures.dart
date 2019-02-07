class ScorecardEntry {
  DateTime time;
  int rideID;
  int score;

  ScorecardEntry({this.time, this.rideID, this.score});

  factory ScorecardEntry.fromMap(Map<String, dynamic> map){
    return ScorecardEntry(
      // Firebase/iOS stores time in seconds since epoch w/ decimal places
      time: DateTime.fromMillisecondsSinceEpoch(((map["date"] as double) * 1000).toInt()),
      rideID: map["rideID"],
      score: map["score"]
    );
  }

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      "date": this.time.millisecondsSinceEpoch / 1000,
      "rideID": this.rideID,
      "score": this.score
    };
  }
}