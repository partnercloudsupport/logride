import 'package:flutter/material.dart';
import '../data/park_structures.dart';
import '../widgets/generic_list_entry.dart';
import '../widgets/content_frame.dart';
import 'standard_page_structure.dart';

class SearchParksCard extends StatefulWidget {
  SearchParksCard({Key key, this.parkList, this.tapBack}) : super(key: key);

  final List<ParkData> parkList;
  final Function(ParkData) tapBack;

  @override
  _SearchParksCardState createState() => new _SearchParksCardState();
}

class _SearchParksCardState extends State<SearchParksCard> {
  TextEditingController editingController = TextEditingController();

  var workingList = List<ParkData>();

  @override
  void initState() {
    workingList.addAll(widget.parkList);
    super.initState();
  }

  void filterListBySearch(String search) {
    List<ParkData> tempToSearch = List<ParkData>();
    tempToSearch.addAll(widget.parkList);
    if (search.isNotEmpty) {
      List<ParkData> tempToDisplay = List<ParkData>();
      tempToSearch.forEach((park) {
        // Searching for both the park name or location, with case ignored
        if (park.parkName.toLowerCase().contains(search.toLowerCase()) ||
            park.parkCity.toLowerCase().contains(search.toLowerCase())) {
          tempToDisplay.add(park);
        }
      });
      setState(() {
        workingList.clear();
        workingList.addAll(tempToDisplay);
      });
      return;
    } else {
      setState(() {
        workingList.clear();
        workingList.addAll(widget.parkList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            TextField(
              onChanged: (value) {
                filterListBySearch(value);
              },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
              ),
              controller: editingController,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: workingList.length,
                  itemBuilder: (context, index) {
                    return GenericListEntry(
                        park: workingList[index], onTap: widget.tapBack);
                  }),
            )
          ],
        ),
      ]),
    );
  }
}

class AllParkSearchCard extends StatelessWidget {
  AllParkSearchCard({this.allParkData, this.tapBack});

  final List<ParkData> allParkData;
  final Function(ParkData) tapBack;

  @override
  Widget build(BuildContext context) {
    return ContentFrame(
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: SearchParksCard(parkList: allParkData, tapBack: tapBack)),
    );
  }
}

class AllParkSearchPage extends StatelessWidget {
  AllParkSearchPage({this.allParks, this.tapBack});

  final List<ParkData> allParks;
  final Function(ParkData) tapBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        body: StandardPageStructure(
          iconFunction: () => Navigator.of(context).pop(),
          content: <Widget>[
            AllParkSearchCard(allParkData: allParks, tapBack: tapBack)
          ],
        ));
  }
}
