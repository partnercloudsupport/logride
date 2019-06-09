import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/search_comparators.dart';
import 'package:log_ride/widgets/shared/generic_list_entry.dart';

class AllParkSearchPage extends StatefulWidget {
  AllParkSearchPage({this.allParks, this.tapBack, this.suggestPark});

  final List<BluehostPark> allParks;
  final Function(BluehostPark park, bool openPark) tapBack;
  final VoidCallback suggestPark;

  @override
  _AllParkSearchPageState createState() => _AllParkSearchPageState();
}

class _AllParkSearchPageState extends State<AllParkSearchPage> {
  TextEditingController editingController = TextEditingController();

  List<BluehostPark> workingList = List<BluehostPark>();
  bool multiMode = false;
  String search = "";

  @override
  void initState() {
    workingList.addAll(widget.allParks);
    workingList.sort((a, b) => a.parkName.compareTo(b.parkName));
    super.initState();
  }

  void suggestPark() {
    print(
        "User is suggesting park, sending them back to the main page to do so");
    Navigator.of(context).pop();
    widget.suggestPark();
  }

  void _handleLongEntryTap(BluehostPark park){
    if(park.filled) return;

    if(!multiMode) multiMode = true;
    widget.tapBack(park, false);
  }

  void _handleShortEntryTap(BluehostPark park) {
    if(park.filled) return;

    if(!multiMode) {
      widget.tapBack(park, true);
      Navigator.of(context).pop();
      return;
    } else {
      widget.tapBack(park, false);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              leading: IconButton(
                icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white,),
                onPressed: () => Navigator.of(context).pop(),
              ),
              automaticallyImplyLeading: false,
              title: TextField(
                autofocus: true,
                onChanged: (value) {
                  if(mounted){
                    setState(() {
                      search = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search for new parks",
                  suffixIcon: Icon(
                    FontAwesomeIcons.search,
                    color: Colors.white,
                  ),
                  hintStyle: Theme.of(context).textTheme.subhead.apply(color: Colors.white),
                  border: InputBorder.none
                ),
                style: Theme.of(context)
                    .textTheme
                    .title
                    .apply(color: Colors.white),
                controller: editingController,
              ),
              floating: true,
              snap: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  ListView.builder(
                    padding: const EdgeInsets.only(top: 4.0),
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
                            longTap: (b) => suggestPark(),
                            fillable: false,
                          );
                        } else {
                          if(isBluehostParkInSearch(workingList[index], search)) {
                            return GenericListEntry(
                                park: workingList[index], onTap: _handleShortEntryTap, longTap: _handleLongEntryTap,);
                          } else {
                            return Container();
                          }
                        }
                      }, shrinkWrap: true,
                  physics: ClampingScrollPhysics(),)
                ],
              ),
            )
          ],
        ));
  }
}
