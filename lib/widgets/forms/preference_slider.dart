import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

class SliderPreference extends StatefulWidget {
  SliderPreference(this.title, this.localKey,
      {this.desc,
      this.defaultVal,
      this.onChangeEnd,
      this.onChange,
      this.min = 0.0,
      this.max = 1.0});

  final String title;
  final String desc;
  final String localKey;
  final double defaultVal;
  final double min;
  final double max;

  final Function(double val) onChange;
  final Function(double val) onChangeEnd;

  @override
  _SliderPreferenceState createState() => _SliderPreferenceState();
}

class _SliderPreferenceState extends State<SliderPreference> {
  double rangeVal;

  @override
  void initState() {
    super.initState();
    if (PrefService.getDouble(widget.localKey) == null)
      PrefService.setDouble(widget.localKey, widget.defaultVal);

    rangeVal = PrefService.getDouble(widget.localKey);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(widget.title),
          subtitle: widget.desc == null ? null : Text(widget.desc),
        ),
        Slider.adaptive(
          value: rangeVal,
          min: widget.min,
          max: widget.max,
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Colors.grey,
          onChangeEnd: onChangeEnd,
          onChanged: (v) {
            setState(() => rangeVal = v);
            if (widget.onChange != null) widget.onChange(v);
          },
          label: "Test",
        )
      ],
    );
  }

  void onChangeEnd(double val) async {
    setState(() => PrefService.setDouble(widget.localKey, val));
    if (widget.onChangeEnd != null) widget.onChangeEnd(val);
  }
}
