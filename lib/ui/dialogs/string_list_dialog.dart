import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:toast/toast.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';
import 'package:log_ride/ui/dialogs/single_value_dialog.dart';
import 'package:log_ride/widgets/dialogs/dialog_frame.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';

class StringListDialogPage extends StatefulWidget {
  StringListDialogPage(
      {@required this.initialString,
      this.headerTitle = "Values",
      this.valueText = "Add new value",
      this.emptyText = "Please submit a value",
      this.hintText = ""});

  final List<String> initialString;
  final String headerTitle;
  final String valueText;
  final String emptyText;
  final String hintText;

  @override
  _StringListDialogPageState createState() => _StringListDialogPageState();
}

class _StringListDialogPageState extends State<StringListDialogPage> {
  List<String> entries;

  void onDismiss() {
    Navigator.of(context).pop(entries);
  }

  void onDeleteEntry(int index) async {
    dynamic result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StyledConfirmDialog(
            body: "Are you sure you want to delete \"${entries[index]}\"?",
            title: "Delete Item",
            confirmButtonText: "Yes",
            denyButtonText: "No",
          );
        });

    if (result == null || result == false) {
      return;
    }

    setState(() {
      entries.removeAt(index);
    });
  }

  void onAddTapped() async {
    dynamic result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleValueDialog(
            title: widget.valueText,
            submitText: "SUBMIT",
            type: SingleValueDialogType.TEXT,
            hintText: widget.hintText,
          );
        });

    if (result == null) return;

    addEntry(result);
  }

  void addEntry(String entry) {
    setState(() {
      entries.add(entry);
    });
  }

  void editEntry(int index) async {
    String entry = entries[index];

    dynamic result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleValueDialog(
            title: "Edit Entry",
            initialValue: entry,
            submitText: "Save Changes",
            type: SingleValueDialogType.TEXT,
          );
        });

    if (result == null) return;

    setState(() {
      entries[index] = result.toString();
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      String row = entries.removeAt(oldIndex);
      entries.insert(newIndex, row);
    });
  }

  @override
  void initState() {
    entries = List.from(widget.initialString);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController =
        PrimaryScrollController.of(context) ?? ScrollController();

    num cardHeight = MediaQuery.of(context).size.height / 2;
    if (cardHeight < 200) cardHeight = 200;

    Widget content = Container();

    if (entries.length != 0) {
      content = Container(
          width: double.infinity,
          height: cardHeight,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              ReorderableSliverList(
                  delegate: ReorderableSliverChildBuilderDelegate(
                      (BuildContext context, int index) => _SingleStringEntry(
                          data: entries[index],
                          delete: () => onDeleteEntry(index),
                          edit: () => editEntry(index)),
                      childCount: entries.length),
                  onReorder: _onReorder)
            ],
          ));
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          widget.emptyText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
      );
    }

    return DialogFrame(
      resizeToAvoidBottomInset: false,
      title: widget.headerTitle,
      dismiss: onDismiss,
      content: <Widget>[
        Container(width: double.infinity, height: cardHeight, child: content),
        InterfaceButton(
          text: widget.valueText,
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: onAddTapped,
        )
      ],
    );
  }
}

class _SingleStringEntry extends StatelessWidget {
  _SingleStringEntry({this.data, this.delete, this.edit});

  final String data;
  final VoidCallback delete;
  final VoidCallback edit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => Toast.show("Press and hold an item to re-order the list", context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: edit,
                ),
                Expanded(
                  child: Text(
                    data,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.body1.apply(
                      fontSizeDelta: 6,
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.delete), onPressed: delete)
              ],
            ),
          ),
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }
}

class StringListField extends StatelessWidget {
  StringListField(
      {this.onSaved,
      this.validator,
      this.initialValue,
      this.label = "List",
      this.enabled = true,
      this.headerText = "List",
      this.valueText = "Add to List",
      this.emptyText = "Add items to the list",
      this.hintText = ""});

  final Function(List<String>) onSaved;
  final Function validator;
  final List<String> initialValue;
  final String label;
  final bool enabled;

  final String headerText;
  final String valueText;
  final String emptyText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: submissionDecoration(enabled: enabled),
      child: FormField<List<String>>(
        initialValue: initialValue,
        onSaved: (d) => onSaved(d),
        validator: (v) {
          if (validator != null) {
            validator(v);
          }
        },
        enabled: enabled,
        builder: (FormFieldState<List<String>> state) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (!enabled) return;

              dynamic result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StringListDialogPage(
                      initialString: state.value,
                      headerTitle: headerText,
                      valueText: valueText,
                      emptyText: emptyText,
                      hintText: hintText,
                    );
                  });

              if(result == null) return;

              if (result as List<String> != state.value) {
                state.didChange(result as List<String>);
              }
            },
            child: Container(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    label,
                    style: Theme.of(context).textTheme.title.apply(
                        fontWeightDelta: -1,
                        color: enabled ? Colors.grey[700] : Colors.grey[500]),
                  ),
                  Text(
                      (state.value != null)
                      // The ${(state.value.length ==1)} bit is for quick and dirty plurality tidiness.
                          ? "${state.value.length} item${(state.value.length == 1) ? "" : "s"}"
                          : "",
                      style: Theme.of(context).textTheme.title.apply(
                          fontWeightDelta: -1,
                          color: enabled
                              ? Theme.of(context).primaryColor
                              : Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
