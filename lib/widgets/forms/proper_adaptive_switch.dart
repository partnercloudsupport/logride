import 'package:flutter/material.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';

class AdaptiveSwitchEntry extends StatelessWidget {
  AdaptiveSwitchEntry({this.text, this.value, this.onChanged});

  final String text;
  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .title
                    .apply(fontWeightDelta: -1, color: Colors.grey[700]),
              ),
              Switch.adaptive(value: value, onChanged: (val) => onChanged(val))
            ]));
  }
}

class AdaptiveSwitchFormField extends StatelessWidget {
  AdaptiveSwitchFormField(
      {this.initialValue, this.label, this.onChanged, this.onSaved});

  final bool initialValue;
  final String label;
  final Function(bool) onChanged;
  final Function(bool) onSaved;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: initialValue,
      builder: (FormFieldState<bool> state) {
        return InputDecorator(
            decoration: submissionDecoration(),
            child: AdaptiveSwitchEntry(
              text: label,
              value: state.value,
              onChanged: (val) {
                if (onChanged != null) onChanged(val);

                state.didChange(val);
              },
            ));
      },
      onSaved: (value) => onSaved(value),
    );
  }
}
