import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/ui/standard_page_structure.dart';
import 'package:log_ride/widgets/shared/generic_list_entry.dart';
import 'package:log_ride/widgets/shared/content_frame.dart';

class SearchParksCard extends StatefulWidget {
  SearchParksCard({Key key, this.parkList, this.tapBack, this.suggestPark})
      : super(key: key);

  final List<BluehostPark> parkList;
  final Function(BluehostPark) tapBack;
  final VoidCallback suggestPark;

  @override
  _SearchParksCardState createState() => new _SearchParksCardState();
}

class _SearchParksCardState extends State<SearchParksCard> {
  TextEditingController editingController = TextEditingController();

  var workingList = List<BluehostPark>();

  @override
  void initState() {
    workingList.addAll(widget.parkList);
    workingList.sort((a, b) => a.parkName.compareTo(b.parkName));
    super.initState();
  }

  void filterListBySearch(String search) {
    List<BluehostPark> tempToSearch = List<BluehostPark>();
    tempToSearch.addAll(widget.parkList);
    if (search.isNotEmpty) {
      List<BluehostPark> tempToDisplay = List<BluehostPark>();
      tempToSearch.forEach((park) {
        // Searching for both the park name or location, with case ignored
        if (park.parkName.toLowerCase().contains(search.toLowerCase()) ||
            park.parkCity.toLowerCase().contains(search.toLowerCase())) {
          tempToDisplay.add(park);
        }
      });
      tempToDisplay.sort((a, b) => a.parkName.compareTo(b.parkName));
      setState(() {
        workingList.clear();
        workingList.addAll(tempToDisplay);
      });
      return;
    } else {
      setState(() {
        workingList.clear();
        workingList.addAll(widget.parkList);
        workingList.sort((a, b) => a.parkName.compareTo(b.parkName));
      });
    }
  }

  void suggestPark() {
    print(
        "User is suggesting park, sending them back to the main page to do so");
    Navigator.of(context).pop();
    widget.suggestPark();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            TextField(
              autofocus: true,
              onChanged: (value) {
                filterListBySearch(value);
              },
              decoration: InputDecoration(
                labelText: "Add Park",
                hintText: "Search for new parks",
                prefixIcon: Icon(Icons.search),
              ),
              controller: editingController,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: workingList.length + 1,
                  itemBuilder: (context, index) {
                    if (workingList.length == index) {
                      BluehostPark placeholder = BluehostPark(id: -1);
                      placeholder.parkName = "Park Not Found?";
                      placeholder.parkCity =
                          "To add it to our database, please suggest it here";

                      return GenericListEntry(
                        park: placeholder,
                        onTap: (b) => suggestPark(),
                        fillable: false,
                      );
                    } else {
                      return GenericListEntry(
                          park: workingList[index], onTap: widget.tapBack);
                    }
                  }),
            )
          ],
        ),
      ]),
    );
  }
}

class AllParkSearchCard extends StatelessWidget {
  AllParkSearchCard({this.allParkData, this.tapBack, this.suggestPark});

  final List<BluehostPark> allParkData;
  final Function(BluehostPark) tapBack;
  final VoidCallback suggestPark;

  @override
  Widget build(BuildContext context) {
    return ContentFrame(
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: SearchParksCard(parkList: allParkData, tapBack: tapBack, suggestPark: suggestPark,)),
    );
  }
}

class AllParkSearchPage extends StatelessWidget {
  AllParkSearchPage({this.allParks, this.tapBack, this.suggestPark});

  final List<BluehostPark> allParks;
  final Function(BluehostPark) tapBack;
  final VoidCallback suggestPark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.transparent,
        body: StandardPageStructure(
          iconFunction: () => Navigator.of(context).pop(),
          iconDecoration: FontAwesomeIcons.home,
          content: <Widget>[
            AllParkSearchCard(allParkData: allParks, tapBack: tapBack, suggestPark: suggestPark,)
          ],
        ));
  }
}
