import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/attraction_structures.dart';

class AttractionListEntry extends StatelessWidget {
  AttractionListEntry(
      {this.attractionData,
      this.buttonWidget,
      this.ignored,
      this.slidableController,
      this.ignoreCallback});

  final BluehostAttraction attractionData;
  final Widget buttonWidget;
  final bool ignored;
  final SlidableController slidableController;
  final Function(BluehostAttraction) ignoreCallback;

  @override
  Widget build(BuildContext context) {
    Widget built;

    Color tileColor = ignored || !attractionData.active ? Theme.of(context).disabledColor : Colors.white;

    built = InkWell(
      onTap: _onInfoTap,
      child: Container(
        color: tileColor,
        constraints: BoxConstraints.expand(height: 58.0),
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(
                  attractionData.attractionName,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.subhead,
                ),
                AutoSizeText(
                  attractionData.typeLabel,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.subtitle
                )
              ],
            ))
          ],
        ),
      ),
    );

    return Slidable(
      delegate: SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: built,
      actions: <Widget>[_buildIgnoreSlideAction()],
      controller: slidableController,
      // TODO: Insert unique key if needed.
    );
  }

  Widget _buildIgnoreSlideAction() {
    return IconSlideAction(
      icon: FontAwesomeIcons.ban,
      color: Color.fromARGB(255, 221, 222, 224),
      caption: ignored ? "Remove from Ignored" : "Ignore",
      onTap: () => ignoreCallback(this.attractionData),
    );
  }

  void _onInfoTap() {
    //TODO: Open attraction info panel
    print(
        "NOT YET IMPLEMENTED: Thomas, open an attraction panel for ${this.attractionData.attractionName}");
  }
}
