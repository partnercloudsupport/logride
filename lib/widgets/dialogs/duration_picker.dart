import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';
import 'package:log_ride/widgets/dialogs/dialog_frame.dart';

class DurationPickerFormField extends StatelessWidget {
  DurationPickerFormField({this.onSaved, this.initialValue});

  final Function(Duration) onSaved;
  final Duration initialValue;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: submissionDecoration(),
      child: FormField<Duration>(
        initialValue: initialValue,
        onSaved: (d) => onSaved(d),
        builder: (FormFieldState<Duration> state) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // Open Dialog
              dynamic result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DurationPickerDialog(
                      initialValue: state.value,
                    );
                  });
              // Get result
              // Tell State
              if (result != state.value) {
                state.didChange(result);
              }
            },
            child: Container(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Duration",
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .apply(fontWeightDelta: -1, color: Colors.grey[700]),
                  ),
                  Expanded(
                    child: Text(
                        (state.value.inMinutes + state.value.inSeconds == 0)
                            ? ""
                            : "${state.value.inMinutes}m ${state.value.inSeconds % 60}s",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.title.apply(
                            fontWeightDelta: -1,
                            color: Theme.of(context).primaryColor)),
                  ),
                  if (state.value != Duration.zero)
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        state.didChange(Duration.zero);
                      },
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DurationPickerDialog extends StatefulWidget {
  DurationPickerDialog({this.initialValue, this.title = "Duration"});

  final Duration initialValue;
  final String title;

  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  Duration _duration;

  @override
  void initState() {
    _duration = widget.initialValue ?? Duration.zero;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogFrame(
      title: widget.title,
      dismiss: () => Navigator.of(context).pop(_duration),
      content: <Widget>[
        Container(
          height: 250.0,
          child: CupertinoTimerPicker(
            initialTimerDuration: widget.initialValue,
            mode: CupertinoTimerPickerMode.ms,
            onTimerDurationChanged: (d) => setState(() => _duration = d),
          ),
        )
      ],
    );
  }
}
