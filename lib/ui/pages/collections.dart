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

  int attractionCount;
  int parkCount;
  int manCount;
  int modCount;

  @override
  void initState() {
    widget.wf.getDatabaseStats().then((m) {
      setState(() {
        attractionCount = m['attractionsCount'];
        parkCount = m['parkCount'];
        manCount = m['manufacturerCount'];
        modCount = m['modelCount'];
      });
    });
    super.initState();
  }

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
                value: attractionCount ?? 0,
                label: "Attractions",
              ),
              BigStatDisplay(
                value: parkCount ?? 0,
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
                  value: modCount ?? 0,
                  label: "Models",
                ),
              ),
              BigStatDisplay(
                value: manCount ?? 0,
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
