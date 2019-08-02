import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/widgets/dialogs/dialog_frame.dart';

/// Note:
/// This is not used for anything, and as such is left mostly broken and incomplete.
/// There is no way to add something to the list, for example.
///
/// This WAS to be used with the Former Name(s) field on attraction data, but
/// since we have no dedicated character to split names with, keeping it as one long string seems to be required

class StringListDialog extends StatefulWidget {
  StringListDialog({this.initialList, this.title});

  final List<String> initialList;
  final String title;

  @override
  _StringListDialogState createState() => _StringListDialogState();
}

class _StringListDialogState extends State<StringListDialog> {
  List<String> workingList;

  SlidableController _slidableController = SlidableController();

  void close() {
    Navigator.of(context).pop(workingList);
  }

  @override
  void initState() {
    if (widget.initialList == null) {
      workingList = List<String>();
    } else {
      workingList = widget.initialList.toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogFrame(
      title: widget.title,
      dismiss: close,
      content: <Widget>[
        ListView.builder(
            itemCount: workingList.length,
            itemBuilder: (BuildContext context, int index) {
              return Slidable(
                controller: _slidableController,
                actionPane: SlidableDrawerActionPane(),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    icon: FontAwesomeIcons.trash,
                    color: Colors.red,
                    caption: "Delete",
                    onTap: () {
                      setState(() {
                        workingList.removeAt(index);
                      });
                    },
                  )
                ],
                child: Text(workingList[index]),
              );
            })
      ],
    );
  }
}
