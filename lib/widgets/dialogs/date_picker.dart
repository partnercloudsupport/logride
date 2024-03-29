import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';
import 'package:log_ride/widgets/dialogs/dialog_frame.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';

class DatePickerFormField extends StatelessWidget {
  DatePickerFormField(
      {this.onSaved,
      this.onUpdate,
      this.validator,
      this.initialValue,
      this.text = "Date",
      this.enabled = true});

  final Function(DateTime) onSaved;
  final Function(DateTime) onUpdate;
  final Function validator;
  final DateTime initialValue;
  final String text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: submissionDecoration(enabled: enabled),
      child: FormField<DateTime>(
        initialValue: initialValue,
        onSaved: (d) => onSaved(d),
        validator: (v) {
          if (validator != null) {
            validator(v);
          }
        },
        enabled: enabled,
        builder: (FormFieldState<DateTime> state) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // Makes sense, people shouldn't be able to touch if it's disabled
              if (!enabled) return;

              dynamic result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DatePickerDialog(
                        initialValue: state.value, title: text);
                  });

              if (result == null) return;

              if (result as DateTime != state.value) {
                state.didChange(result as DateTime);
                if (onUpdate != null) {
                  onUpdate(result as DateTime);
                }
              }
            },
            child: Container(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    text,
                    style: Theme.of(context).textTheme.title.apply(
                        fontWeightDelta: -1,
                        color: enabled ? Colors.grey[700] : Colors.grey[350]),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      (state.value != null)
                          ? DateFormat.yMMMMd("en_US").format(state.value)
                          : "",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.title.apply(
                          fontWeightDelta: -1,
                          color: enabled
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  if(state.value != null) // ignore: sdk_version_ui_as_code
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () { state.didChange(null); onUpdate(null); },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DatePickerDialog extends StatefulWidget {
  DatePickerDialog({this.initialValue, this.title = "Date"});

  final DateTime initialValue;
  final String title;

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  DateTime _dateTime;

  @override
  void initState() {
    _dateTime = widget.initialValue ?? DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogFrame(
      title: widget.title,
      dismiss: () => Navigator.of(context).pop(),
      content: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: 250.0,
              child: CupertinoDatePicker(
                initialDateTime: _dateTime,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (d) => setState(() => _dateTime = d),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InterfaceButton(
                text: "Select Date",
                onPressed: () => Navigator.of(context).pop(_dateTime),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
              ),
            )
          ],
        )
      ],
    );
  }
}
