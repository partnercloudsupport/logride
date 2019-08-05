import 'package:flutter/material.dart';
import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/manufacturer_structures.dart';
import 'package:log_ride/data/model_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/widgets/dialogs/generic_list_picker.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';

class ListsPage extends StatefulWidget {
  ListsPage({this.wf, this.pm, this.db});

  final WebFetcher wf;
  final ParksManager pm;
  final BaseDB db;

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  String manufacturer;
  int manID;

  String modelName;
  int modelID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PadlessPageHeader(text: "LISTS"),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("$manID: $manufacturer"),
            InterfaceButton(
              text: "Pick Manufacturer",
              onPressed: () async {
                dynamic result = await Navigator.push(
                    context,
                    SlideInRoute(
                        dialogStyle: true,
                        direction: SlideInDirection.UP,
                        widget: ManufacturerPicker(
                            manufacturers: widget.pm.manufacturers)));

                if (result == null) return;

                if (mounted) {
                  setState(() {
                    result = result as Manufacturer;
                    manufacturer = result.name;
                    manID = result.id;
                    modelID = null;
                    modelName = null;
                  });
                }
              },
            ),
            Text("$modelID: $modelName"),
            InterfaceButton(
              text: "Pick Model",
              onPressed: (manID != null)
                  ? () async {
                      List<Model> models = await widget.pm.getModels(manID);
                      dynamic result = await Navigator.push(
                          context,
                          SlideInRoute(
                              dialogStyle: true,
                              direction: SlideInDirection.UP,
                              widget: ModelPicker(models: models)));

                      if (result == null) return;

                      if (mounted) {
                        setState(() {
                          Model model = result as Model;
                          modelName = model.name;
                          modelID = model.id;
                        });
                      }
                    }
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
