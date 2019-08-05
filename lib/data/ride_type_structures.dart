class RideType {
  RideType({this.id, this.label});

  int id;
  String label;
}

RideType findRideTypeByID(List<RideType> listToSearch, int id) {
  return listToSearch.firstWhere((t) => t.id == id, orElse: () => null);
}
