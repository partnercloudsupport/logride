import 'package:firebase_database/ui/firebase_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../data/attraction_structures.dart';
import '../data/color_constants.dart';
import '../data/fbdb_manager.dart';
import '../data/scorecard_structures.dart';
import '../widgets/interface_button.dart';

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

  @override
  void initState() {
    super.initState();
    print(widget.db == null);
    print(widget.db.runtimeType);
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

    int topScore = 0;
    if (_entries.isNotEmpty) {
      topScore = _entries.first.score;
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
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
                      //Top Score
                      _ScorecardTopScore(
                        topScore: topScore,
                      ),
                      //Following Scores
                      Container(
                        width: double.infinity,
                        height: 200.0,
                        child: ListView.builder(
                            itemCount: _entries.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Text(_entries[index].score.toString());
                            }),
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
                style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 1, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InterfaceButton(
                text: "Close",
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            color: PROGRESS_BAR_GOLD,
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
