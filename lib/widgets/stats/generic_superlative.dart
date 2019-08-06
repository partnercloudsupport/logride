import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:log_ride/widgets/stats/generic_stats_list.dart';
import 'package:preferences/preferences.dart';

enum _GenericStatsSortMode { checks, experiences }

class GenericStatsSuperlative extends StatefulWidget {
  GenericStatsSuperlative(
      {this.categoryList, this.persistKey = "superlativeSort", this.label});

  final List<GenericStatData> categoryList;
  final String label;
  final String persistKey;

  @override
  _GenericStatsSuperlativeState createState() =>
      _GenericStatsSuperlativeState();
}

class _GenericStatsSuperlativeState extends State<GenericStatsSuperlative> {
  _GenericStatsSortMode sortMode = _GenericStatsSortMode.checks;

  GenericStatData findTop() {
    if (widget.categoryList == null || widget.categoryList.length == 0) {
      return GenericStatData(label: "No Stats Data", experiences: 0, checks: 0);
    }

    List<GenericStatData> workingList =
        List<GenericStatData>.from(widget.categoryList);
    switch (sortMode) {
      case _GenericStatsSortMode.checks:
        workingList.sort((a, b) => b.checks.compareTo(a.checks));
        break;
      case _GenericStatsSortMode.experiences:
        workingList.sort((a, b) => b.experiences.compareTo(a.experiences));
        break;
    }

    return workingList.first;
  }

  @override
  void initState() {
    sortMode = _GenericStatsSortMode
        .values[PrefService.getInt(widget.persistKey) ?? 0];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GenericStatData toDisplay = findTop();

    bool empty = (sortMode == _GenericStatsSortMode.checks)
        ? (toDisplay.checks == 0)
        : (toDisplay.experiences == 0);

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            // Label
            Text(
              widget.label,
              style: TextStyle(
                  fontSize: 18.0,
                  textBaseline: TextBaseline.alphabetic,
                  fontWeight: FontWeight.normal),
            ),
            // Button
            FlatButton(
              child: Text(
                (sortMode == _GenericStatsSortMode.checks)
                    ? "BY CHECKS:"
                    : "BY EXPERIENCES:",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 18.0),
              ),
              onPressed: () {
                setState(() => sortMode =
                    (sortMode == _GenericStatsSortMode.checks)
                        ? _GenericStatsSortMode.experiences
                        : _GenericStatsSortMode.checks);

                PrefService.setInt(widget.persistKey, sortMode.index);
              },
            )
          ],
        ),
        // Value
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.baseline,
            //textBaseline: TextBaseline.alphabetic,
            //mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: AutoSizeText(
                  (empty) ? "No Stats Data" : toDisplay.label ?? "No Data",
                  maxLines: 1,
                  maxFontSize: 32,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                    "(${(sortMode == _GenericStatsSortMode.checks) ? toDisplay.checks.toString() : toDisplay.experiences.toString()})"),
              )
            ],
          ),
        )
      ],
    );
  }
}

class AttractionStatsSuperlative extends StatefulWidget {
  AttractionStatsSuperlative({Key key, this.list, this.label})
      : super(key: key);

  final List<RideTypeStats> list;
  final String label;

  @override
  _AttractionStatsSuperlativeState createState() =>
      _AttractionStatsSuperlativeState();
}

class _AttractionStatsSuperlativeState
    extends State<AttractionStatsSuperlative> {
  List<GenericStatData> displayList;

  @override
  void initState() {
    displayList = List<GenericStatData>();

    widget.list.forEach((t) {
      displayList.add(GenericStatData(
          label: t.label,
          checks: t.checkCount,
          experiences: t.experienceCount));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GenericStatsSuperlative(
      categoryList: displayList,
      label: widget.label,
      persistKey: "attractionStatsSuperlativeSort",
    );
  }
}

class ManufacturerStatsSuperlative extends StatefulWidget {
  ManufacturerStatsSuperlative(
      {Key key, this.list, this.label, this.persistKey})
      : super(key: key);

  final List<ManufacturerStats> list;
  final String label;
  final String persistKey;

  @override
  _ManufacturerStatsSuperlativeState createState() =>
      _ManufacturerStatsSuperlativeState();
}

class _ManufacturerStatsSuperlativeState
    extends State<ManufacturerStatsSuperlative> {
  List<GenericStatData> displayList;

  @override
  void initState() {
    displayList = List<GenericStatData>();

    widget.list.forEach((t) {
      displayList.add(GenericStatData(
          label: t.label,
          checks: t.checkCount,
          experiences: t.experienceCount));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GenericStatsSuperlative(
      categoryList: displayList,
      label: widget.label,
      persistKey: widget.persistKey ?? "manufacturerStatsSuperlativeSort",
    );
  }
}
