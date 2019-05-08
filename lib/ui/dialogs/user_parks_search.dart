import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:log_ride/ui/standard_page_structure.dart';
import 'package:log_ride/widgets/home_page/park_list_widget.dart';
import 'package:log_ride/widgets/shared/content_frame.dart';
import 'package:log_ride/widgets/shared/custom_animated_firebase_list.dart';

class UserParksSearchPage extends StatefulWidget {
  UserParksSearchPage(
      {this.parksQuery,
      this.slidableController,
      this.entryCallback,
      this.sliderActionCallback});

  final Query parksQuery;
  final SlidableController slidableController;
  final Function entryCallback;
  final Function sliderActionCallback;

  @override
  _UserParksSearchPageState createState() => _UserParksSearchPageState();
}

class _UserParksSearchPageState extends State<UserParksSearchPage> {
  ListFilter filter = ListFilter("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.transparent,
      body: StandardPageStructure(
        iconFunction: () => Navigator.of(context).pop(),
        iconDecoration: FontAwesomeIcons.home,
        content: <Widget>[
          ContentFrame(
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Column(children: <Widget>[
                    TextField(
                      autofocus: true,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            if (filter.value != value) {
                              filter.value = value;
                            }
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    Expanded(
                      child: ParkListView(
                        parksData: widget.parksQuery,
                        favorites: false,
                        slidableController: widget.slidableController,
                        headerCallback: (faves) => Navigator.of(context).pop(),
                        onTap: widget.entryCallback,
                        sliderActionCallback: widget.sliderActionCallback,
                        arrowWidget: Container(),
                        filter: filter,
                      ),
                    ),
                  ])))
        ],
      ),
    );
  }
}