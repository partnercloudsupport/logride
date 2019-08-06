import 'package:flutter/material.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:preferences/preferences.dart';

enum _SortState { CHECKS, LABEL, EXPERIENCE }

class GenericStats extends StatefulWidget {
  GenericStats(
      {this.statData, this.labelLabel, this.persistKey, this.alone = true});

  final List<_GenericStatData> statData;
  final String labelLabel;

  /// [persistKey] is a string used by the PrefService to keep track of which
  /// sorting mode was used last, and persist it. Easy way to ensure to users
  /// that the table is the same as when they last left it.
  final String persistKey;

  /// [alone] is used when there may be multiple tables on the same page, i.e.
  /// the attractions page. If the table is alone, it'll subscribe and refresh
  /// the preferences all by itself. This runs into an issue when it tries to
  /// dispose itself and remove the notification, but there's still other things
  /// subscribed to it.
  ///
  /// Instead, it is up to the parent widgets to setState upon the hideEmptyStats
  /// preference onNotify
  final bool alone;

  @override
  _GenericStatsState createState() => _GenericStatsState();
}

class _GenericStatsState extends State<GenericStats> {
  _SortState sortState = _SortState.LABEL;

  @override
  void initState() {
    if (widget.alone)
      PrefService.onNotify(preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS],
          () => setState(() {}));

    // If we have a persistkey, use the persistkey to find any existing stats
    // or, reset to the label by default
    if (widget.persistKey != null)
      sortState = _SortState.values[PrefService.getInt(widget.persistKey) ?? 1];
    super.initState();
  }

  @override
  void dispose() {
    if (widget.alone)
      PrefService.onNotifyRemove(
          preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS]);
    super.dispose();
  }

  /// Called by a button in the header of the stats table. Will have the table
  /// change the sorting order based upon what type of button tapped it
  void _handleButtonTap(_SortState buttonType) {
    if (buttonType != sortState) {
      // Update our persistence if we have it
      if (widget.persistKey != null)
        PrefService.setInt(widget.persistKey, buttonType.index);

      setState(() {
        sortState = buttonType;
      });
    }
  }

  /// Prepares a new list from the widget's given list for display, sorting it
  List<_GenericStatData> prepareAndSort() {
    List<_GenericStatData> data = List<_GenericStatData>();

    bool hideEmpty = PrefService.getBool(
        preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS]);

    widget.statData.forEach((t) {
      // Don't include empty data when we don't want to
      if (t.checks + t.experiences == 0 && hideEmpty) return;
      data.add(t);
    });

    data.sort((a, b) {
      switch (sortState) {
        case _SortState.CHECKS:
          return b.checks.compareTo(a.checks);
          break;
        case _SortState.LABEL:
          return a.label.compareTo(b.label);
          break;
        case _SortState.EXPERIENCE:
          return b.experiences.compareTo(a.experiences);
          break;
      }
      return a.label.compareTo(b.label);
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    List<_GenericStatData> toDisplay = prepareAndSort();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Header buttons/bars
        _buildButtonRow(context),
        for (int i = 0; i < toDisplay.length; i++)
          _GenericStatEntry(toDisplay[i], (i % 2 == 1))
      ],
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // Checks
        _GenericStatColButton(
          text: "Checks",
          callback: () => _handleButtonTap(_SortState.CHECKS),
          align: _ColButtonAlign.LEFT,
          active: (sortState == _SortState.CHECKS),
        ),
        // Type
        _GenericStatColButton(
          text: widget.labelLabel,
          callback: () => _handleButtonTap(_SortState.LABEL),
          align: _ColButtonAlign.CENTER,
          active: (sortState == _SortState.LABEL),
        ),
        // Experience
        _GenericStatColButton(
          text: "Experiences",
          callback: () => _handleButtonTap(_SortState.EXPERIENCE),
          align: _ColButtonAlign.RIGHT,
          active: (sortState == _SortState.EXPERIENCE),
        ),
      ],
    );
  }
}

class _GenericStatEntry extends StatelessWidget {
  _GenericStatEntry(this.data, this.odd);

  final _GenericStatData data;
  final bool odd;

  @override
  Widget build(BuildContext context) {
    TextStyle entryStyle = TextStyle(fontSize: 16.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: odd
          ? ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              color: UI_BUTTON_BACKGROUND)
          : null,
      child: Row(
        children: <Widget>[
          // All three columns are expanded with the same flex - otherwise,
          // differences in the sizes of the left and right could affect
          // the position of the center of the label
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                data.checks.toString(),
                style: entryStyle,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              data.label,
              style: entryStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                data.experiences.toString(),
                style: entryStyle,
                textAlign: TextAlign.right,
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum _ColButtonAlign { LEFT, RIGHT, CENTER }

class _GenericStatColButton extends StatelessWidget {
  _GenericStatColButton(
      {this.text = "Unlabeled button",
      this.callback,
      this.align = _ColButtonAlign.LEFT,
      this.active = false});

  final String text;
  final VoidCallback callback;
  final _ColButtonAlign align;
  final bool active;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      child: FlatButton(
        onPressed: callback,
        child: Container(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          decoration: active
              ? BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 3.0, color: Theme.of(context).primaryColor)))
              : null,
        ),
      ),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 3.0, color: Theme.of(context).primaryColor))),
    );

    return Expanded(
      child: button,
      flex: (align == _ColButtonAlign.CENTER) ? 5 : 4,
    );
  }
}

class _GenericStatData {
  _GenericStatData({this.label, this.checks, this.experiences});

  final String label;
  final int checks;
  final int experiences;
}

class AttractionStatsTable extends StatefulWidget {
  AttractionStatsTable(this.stats,
      {this.alone = true, this.persistKey = "statsAttractionsTable"});

  final List<RideTypeStats> stats;
  final bool alone;
  final String persistKey;

  @override
  _AttractionStatsTableState createState() => _AttractionStatsTableState();
}

class _AttractionStatsTableState extends State<AttractionStatsTable> {
  // This widget is kept as a stateful widget so we don't have to recalculate
  // the list of data every time, nor offload that work to our parent widget
  List<_GenericStatData> data;

  @override
  void initState() {
    data = List<_GenericStatData>();
    widget.stats.forEach((t) {
      data.add(_GenericStatData(
          checks: t.checkCount,
          label: t.label,
          experiences: t.experienceCount));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GenericStats(
      labelLabel: "Attraction Type",
      statData: data,
      alone: widget.alone,
      persistKey: widget.persistKey,
    );
  }
}

class ManufacturerStatsTable extends StatefulWidget {
  ManufacturerStatsTable(this.stats,
      {this.alone = true, this.persistKey = "statsManufacturerTable"});

  final List<ManufacturerStats> stats;
  final bool alone;
  final String persistKey;

  @override
  _ManufacturerStatsTableState createState() => _ManufacturerStatsTableState();
}

class _ManufacturerStatsTableState extends State<ManufacturerStatsTable> {
  List<_GenericStatData> data;

  @override
  void initState() {
    data = List<_GenericStatData>();
    widget.stats.forEach((t) {
      data.add(_GenericStatData(
          checks: t.checkCount,
          label: t.label,
          experiences: t.experienceCount));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GenericStats(
      labelLabel: "Manufacturer",
      statData: data,
      alone: widget.alone,
      persistKey: widget.persistKey,
    );
  }
}
