import 'package:flutter/material.dart';
import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/manufacturer_structures.dart';
import 'package:log_ride/data/model_structures.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/widgets/collections/stat_displays.dart';
import 'package:log_ride/widgets/dialogs/generic_list_picker.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';

class CollectionsPage extends StatefulWidget {
  CollectionsPage({this.wf, this.pm, this.db});

  final WebFetcher wf;
  final ParksManager pm;
  final BaseDB db;

  @override
  _CollectionsPageState createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  String selectedManufacturer;
  int selectedManufacturerID;

  String selectedModelName = "";
  int selectedModelID = 0;

  BluehostPark selectedPark;

  int attractionCount = 0;
  int parkCount = 0;
  int manCount = 0;
  int modCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PadlessPageHeader(text: "COLLECTIONS"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0)
                    .add(EdgeInsets.only(top: 61.0)),
                child: Text(
                  "This page will be home to new and exciting features in the future. For now, why not explore our more than ",
                  textAlign: TextAlign.center,
                ),
              ),
              BigStatDisplay(
                value: 15263,
                label: "Attractions",
              ),
              BigStatDisplay(
                value: 539,
                label: "Parks",
              ),
              InterfaceButton(
                text: "Browse All Parks",
                onPressed: () async {
                  dynamic result = await Navigator.push(
                      context,
                      SlideInRoute(
                          dialogStyle: true,
                          direction: SlideInDirection.UP,
                          widget: ParkPicker(
                            parks: widget.pm.allParksInfo,
                          )));

                  if (result == null) return;

                  setState(() {
                    selectedPark = result as BluehostPark;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: BigStatDisplay(
                  value: 1327,
                  label: "Models",
                ),
              ),
              BigStatDisplay(
                value: 286,
                label: "Manufacturers",
              ),
              InterfaceButton(
                text: "Select a Manufacturer",
                onPressed: () async {
                  dynamic result = await Navigator.push(
                      context,
                      SlideInRoute(
                          dialogStyle: true,
                          direction: SlideInDirection.UP,
                          widget: ManufacturerPicker(
                            manufacturers: widget.pm.manufacturers,
                            allowCustomSubmit: false,
                          )));

                  if (result == null) return;

                  if (mounted) {
                    setState(() {
                      result = result as Manufacturer;
                      selectedManufacturer = result.name;
                      selectedManufacturerID = result.id;
                      selectedModelID = null;
                      selectedModelName = null;
                    });
                  }
                },
              ),
              if (selectedManufacturer != null)
                Text(
                  "Selected Manufacturer: $selectedManufacturer",
                  textAlign: TextAlign.center,
                ),
              if (selectedManufacturer != null)
                InterfaceButton(
                  text: "View Attraction Models",
                  onPressed: () async {
                    List<Model> models =
                        await widget.pm.getModels(selectedManufacturerID);
                    dynamic result = await Navigator.push(
                        context,
                        SlideInRoute(
                            dialogStyle: true,
                            direction: SlideInDirection.UP,
                            widget: ModelPicker(
                              models: models,
                              allowCustomSubmit: false,
                            )));
                  },
                )
            ],
          ),
        ),
      )),
    );
  }
}
