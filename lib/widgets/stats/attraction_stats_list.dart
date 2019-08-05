import 'package:flutter/material.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/stats_calculator.dart';
import 'package:preferences/preferences.dart';

enum _AttractionStatsSorting { RIDE_TYPE, EXPERIENCES, CHECK_INS }

class AttractionStats extends StatefulWidget {
  AttractionStats({this.stats});
  final UserStats stats;

  @override
  _AttractionStatsState createState() => _AttractionStatsState();
}

class _AttractionStatsState extends State<AttractionStats> {
  _AttractionStatsSorting sortMode = _AttractionStatsSorting.RIDE_TYPE;

  List<_AttractionStatData> displayData;

  void _handleButtonTap(_AttractionStatsSorting buttonType) {
    if (buttonType != sortMode) {
      setState(() {
        sortMode = buttonType;
      });
    }
  }

  /// Returns a list of [_AttractionStatData] to display, sorted by the widget's [sortMode]
  List<_AttractionStatData> prepareAndSort() {
    List<_AttractionStatData> data = List<_AttractionStatData>();

    widget.stats.rideTypeStats.forEach((i, t) {
      // We don't want unknown/empty types displaying
      if (i == 0) return;
      // We'll hide empty ride types
      if (t.experienceCount + t.checkCount == 0 &&
          PrefService.getBool(
              preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS])) return;
      data.add(_AttractionStatData(
          type: t.label, checks: t.checkCount, experiences: t.experienceCount));
    });

    data.sort((_AttractionStatData a, _AttractionStatData b) {
      switch (sortMode) {
        case _AttractionStatsSorting.CHECK_INS:
          // Greatest to Least
          return b.checks.compareTo(a.checks);
        case _AttractionStatsSorting.EXPERIENCES:
          // Greatest to Least
          return b.experiences.compareTo(a.experiences);
        case _AttractionStatsSorting.RIDE_TYPE:
          // Alphabetical
          return a.type.compareTo(b.type);
      }
      return a.type.compareTo(b.type);
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    List<_AttractionStatData> toDisplay = prepareAndSort();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Header buttons/bars
        _buildButtonRow(context)
      ]..addAll(List<Widget>.generate(toDisplay.length,
          (index) => _buildEntry(toDisplay[index], (index % 2 == 1)))),
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // Checks
        _AttractionStatColButton(
          text: "Checks",
          callback: () => _handleButtonTap(_AttractionStatsSorting.CHECK_INS),
          align: _ColButtonAlign.LEFT,
          active: (sortMode == _AttractionStatsSorting.CHECK_INS),
        ),
        // Type
        _AttractionStatColButton(
          text: "Attraction Type",
          callback: () => _handleButtonTap(_AttractionStatsSorting.RIDE_TYPE),
          align: _ColButtonAlign.CENTER,
          active: (sortMode == _AttractionStatsSorting.RIDE_TYPE),
        ),
        // Experience
        _AttractionStatColButton(
          text: "Experiences",
          callback: () => _handleButtonTap(_AttractionStatsSorting.EXPERIENCES),
          align: _ColButtonAlign.RIGHT,
          active: (sortMode == _AttractionStatsSorting.EXPERIENCES),
        ),
      ],
    );
  }

  Widget _buildEntry(_AttractionStatData data, bool odd) {
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
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                data.checks.toString(),
                style: entryStyle,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              data.type,
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

  @override
  void initState() {
    super.initState();
    PrefService.onNotify(preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS],
        () => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    PrefService.onNotifyRemove(
        preferencesKeyMap[PREFERENCE_KEYS.HIDE_EMPTY_STATS]);
  }
}

enum _ColButtonAlign { LEFT, RIGHT, CENTER }

class _AttractionStatColButton extends StatelessWidget {
  _AttractionStatColButton(
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
        //highlightedBorderColor: Theme.of(context).primaryColor,
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

class _AttractionStatData {
  final String type;
  final int checks;
  final int experiences;

  _AttractionStatData({this.type = "", this.checks = 0, this.experiences = 0});
}
