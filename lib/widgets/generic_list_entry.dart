import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../data/park_structures.dart';

class GenericListEntry extends StatefulWidget{
  GenericListEntry({this.park, this.onTap});

  final BluehostPark park;
  final Function(BluehostPark) onTap;

  @override
  _GenericListState createState() => _GenericListState();
}

class _GenericListState extends State<GenericListEntry> {

  @override
  Widget build(BuildContext context) {
    Widget statusWidget;
    if(widget.park.filled){
      // Park is already in the user's list
      statusWidget = Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Container(
          height: 12.0,
          width: 12.0,
          child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).accentColor
          )),
        ),
      );
    } else {
      statusWidget = Container();
    }
    return InkWell(
      child: Container(
          constraints: BoxConstraints.expand(height: 58),
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // AutoSizeText is used to avoid overflow, since park names
                    // and locations may have unknown lengths.
                    AutoSizeText(
                      widget.park.parkName,
                      style: Theme.of(context).textTheme.subhead,
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      widget.park.parkCity,
                      style: Theme.of(context).textTheme.subtitle,
                      maxLines: 1,
                    )
                  ],
                ),
              ),
              statusWidget
            ],
          )),
      onTap: (){
        setState((){
          widget.park.filled = true;
        });
        widget.onTap(widget.park);
      },
      //behavior: HitTestBehavior.opaque,
    );
  }
}