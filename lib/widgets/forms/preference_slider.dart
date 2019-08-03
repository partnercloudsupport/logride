import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

class SliderPreference extends StatefulWidget {
  SliderPreference(this.title, this.localKey,
      {this.desc,
      this.defaultVal,
      this.onChange,
      this.min = 0.0,
      this.max = 1.0});

  final String title;
  final String desc;
  final String localKey;
  final double defaultVal;
  final double min;
  final double max;

  final Function onChange;

  @override
  _SliderPreferenceState createState() => _SliderPreferenceState();
}

class _SliderPreferenceState extends State<SliderPreference> {
  @override
  void initState() {
    super.initState();
    if (PrefService.getDouble(widget.localKey) == null)
      PrefService.setDouble(widget.localKey, widget.defaultVal);
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
          value: PrefService.getDouble(widget.localKey) ?? widget.defaultVal,
          onChanged: onChange,
          min: widget.min,
          max: widget.max,
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Colors.grey,
          label: "Test",
        )
      ],
    );
  }

  void onChange(double val) async {
    setState(() => PrefService.setDouble(widget.localKey, val));
    if (widget.onChange != null) widget.onChange(val);
  }
}
