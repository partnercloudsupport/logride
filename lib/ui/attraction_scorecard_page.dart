import 'package:firebase_database/ui/firebase_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/scorecard_structures.dart';
import 'package:log_ride/ui/single_value_dialog.dart';
import 'package:log_ride/widgets/interface_button.dart';

Map<int, Color> positionalColors = {
  0: POSITION_FIRST,
  1: POSITION_SECOND,
  2: POSITION_THIRD
};

const double _ENTRY_ICON_SIZE = 20;

class AttractionScorecardPage extends StatefulWidget {
  AttractionScorecardPage({@required this.attraction, @required this.db});

  final BluehostAttraction attraction;
  final BaseDB db;

  @override
  _AttractionScorecardPageState createState() =>
      _AttractionScorecardPageState();
}

class _AttractionScorecardPageState extends State<AttractionScorecardPage> {
  List<ScorecardEntry> _entries;
  FirebaseList _firebaseList;
  SlidableController _slidableController = SlidableController();

  bool _loaded = false;

  void _onScoreAdded(int index, DataSnapshot snap) {
    if (!_loaded) return;
    if (mounted) setState(() {});
  }

  void _onScoreRemoved(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onScoreChanged(int index, DataSnapshot snap) {
    if (mounted) setState(() {});
  }

  void _onScoreValue(DataSnapshot snap) {
    if (mounted && !_loaded)
      setState(() {
        _loaded = true;
      });
  }

  void _buildEntriesList() {
    _entries = List<ScorecardEntry>();
    _firebaseList.forEach((snap) {
      ScorecardEntry parsed = ScorecardEntry.fromMap(Map.from(snap.value));
      _entries.add(parsed);
    });
    // Sort from highest to least (hopefully)
    _entries.sort((a, b) => b.score.compareTo(a.score));
  }

  void _deleteCallback(ScorecardEntry entry) async {
    // Run Confirmation
    dynamic confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Text("Delete Score?"),
            content: Text(
                "This will permanately delete your score of ${NumberFormat.decimalPattern().format(entry.score)} from ${DateFormat.yMMMMd().format(entry.time)}"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text("Delete"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        });
    if (!confirmed) print("User cancelled deletion of score");
    // Convert time to the time that firebase checks for
    int simpleTime = entry.time.millisecondsSinceEpoch ~/ 1000;
    print(
        "Attempting to delete [user]/${widget.attraction.parkID}/${widget.attraction.attractionID}/$simpleTime");
    // Delete from firebase
    widget.db.removeEntryFromPath(
        path: DatabasePath.SCORECARD,
        key:
            "${widget.attraction.parkID}/${widget.attraction.attractionID}/$simpleTime");
    print("Entry deleted");
  }

  @override
  void initState() {
    super.initState();

    Query query = widget.db.getQueryForUser(
      path: DatabasePath.SCORECARD,
      key: "${widget.attraction.parkID}/${widget.attraction.attractionID}",
    );

    _firebaseList = FirebaseList(
        query: query,
        onChildAdded: _onScoreAdded,
        onChildRemoved: _onScoreRemoved,
        onChildChanged: _onScoreChanged,
        onValue: _onScoreValue);
  }

  @override
  Widget build(BuildContext context) {
    _buildEntriesList();

    num cardHeight = MediaQuery.of(context).size.height / 2;
    if (cardHeight < 200.0) cardHeight = 200.0;

    Widget content;
    if (_entries.length > 0) {
      content = ListView.builder(
          itemCount: _entries.length,
          itemBuilder: (BuildContext context, int index) {
            // Making the icons transparent mean they take up the exact same space it would if there was a decoration, but they're just not there
            Color decoratorColor = Colors.transparent;
            if (positionalColors.containsKey(index)) {
              decoratorColor = positionalColors[index];
            }

            return Column(
              children: <Widget>[
                _ScorecardEntry(
                  data: _entries[index],
                  slidableController: _slidableController,
                  slidableCallback: _deleteCallback,
                  isHighScore: (index == 0),
                  decorator: Icon(
                    FontAwesomeIcons.trophy,
                    color: decoratorColor,
                    size: _ENTRY_ICON_SIZE,
                  ),
                ),
              ],
            );
          });
    } else {
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          "Tap the Experience button for this attraction or press the \"SUBMIT NEW SCORE\" button below to add a score to your score card!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Container(constraints: BoxConstraints.expand()),
            ),
            SafeArea(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _ScorecardTitleBar(
                        title: widget.attraction.attractionName,
                      ),
                      Container(
                          width: double.infinity,
                          height: cardHeight,
                          child: content),
                      InterfaceButton(
                        text: "SUBMIT NEW SCORE",
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async {
                          dynamic result = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SingleValueDialog(
                                  title: "Enter Today's New Score",
                                  submitText: "SUBMIT",
                                  type: SingleValueDialogType.NUMBER,
                                );
                              });
                          if (result == null) return;

                          ScorecardEntry entry = ScorecardEntry(
                              rideID: widget.attraction.attractionID,
                              score: result,
                              time: DateTime.now());

                          widget.db.setEntryAtPath(
                              path: DatabasePath.SCORECARD,
                              key:
                                  "${widget.attraction.parkID}/${widget.attraction.attractionID}/${entry.time.millisecondsSinceEpoch ~/ 1000}",
                              payload: entry.toMap());
                        },
                      )
                    ],
                  ),
                ),
              ),
            )),
          ],
        ));
  }
}

class _ScorecardTitleBar extends StatelessWidget {
  _ScorecardTitleBar({this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                "Score Card",
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .apply(fontWeightDelta: 1, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InterfaceButton(
                text: "Close",
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*

class _ScorecardTopScore extends StatelessWidget {
  _ScorecardTopScore({this.topScore});
  final int topScore;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            FontAwesomeIcons.trophy,
            color: POSITION_FIRST,
          ),
        ),
        Expanded(
          child: Text(
            NumberFormat.decimalPattern().format(topScore) + " points",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.title.apply(fontSizeDelta: 8),
          ),
        )
      ],
    );
  }
}
*/

class _ScorecardEntry extends StatelessWidget {
  _ScorecardEntry(
      {this.data,
      this.decorator,
      this.isHighScore = false,
      this.slidableController,
      this.slidableCallback});

  final Widget decorator;
  final ScorecardEntry data;
  final SlidableController slidableController;
  final bool isHighScore;
  final Function(ScorecardEntry entry) slidableCallback;

  @override
  Widget build(BuildContext context) {
    Widget rowIcon = decorator ?? Container();

    return Slidable(
      controller: slidableController,
      delegate: SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      secondaryActions: [
        IconSlideAction(
          icon: FontAwesomeIcons.trash,
          color: Colors.red,
          caption: "Delete",
          onTap: () => slidableCallback(this.data),
        )
      ],
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: <Widget>[
                  rowIcon,
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      NumberFormat.decimalPattern().format(data.score ?? 0),
                      style: Theme.of(context).textTheme.body1.apply(
                          fontSizeDelta: isHighScore ? 8 : 6,
                          fontWeightDelta: isHighScore ? 6 : 0),
                    ),
                  ),
                ]),
                Text(DateFormat.yMMMMd().format(
                    data.time ?? DateTime.fromMillisecondsSinceEpoch(0)))
              ],
            ),
          ),
          Divider(
            height: 0,
          )
        ],
      ),
    );
  }
}
