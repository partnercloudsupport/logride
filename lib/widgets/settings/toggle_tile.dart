import 'package:flutter/material.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:preferences/preference_service.dart';

class ToggleTile extends StatelessWidget {
  ToggleTile(
      {this.title = "Toggle Tile Title",
      this.subtitle = "",
      this.toggleState = false,
      this.primaryString = "Setting 1",
      this.secondaryString = "Setting 2",
      this.onTap});

  final String title;
  final String subtitle;
  final bool toggleState;
  final String primaryString;
  final String secondaryString;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: InterfaceButton(
        onPressed: onTap,
        text: toggleState ? primaryString : secondaryString,
      ),
    );
  }
}

class TogglePreference extends StatefulWidget {
  final String title;
  final String desc;
  final String localKey;
  final String label1;
  final String label2;
  final bool defaultVal;

  final Function(bool mode) subtitleBuilder;
  final Function onChange;

  const TogglePreference(
      {Key key,
      this.title,
      this.desc,
      this.localKey,
      this.defaultVal,
      this.onChange,
      this.label1,
      this.label2,
      this.subtitleBuilder})
      : super(key: key);

  @override
  _TogglePreferenceState createState() => _TogglePreferenceState();
}

class _TogglePreferenceState extends State<TogglePreference> {
  @override
  void initState() {
    super.initState();
    if (PrefService.getBool(widget.localKey) == null)
      PrefService.setBool(widget.localKey, widget.defaultVal);
  }

  @override
  Widget build(BuildContext context) {
    bool currentState = PrefService.getBool(widget.localKey);

    return ToggleTile(
        title: widget.title,
        toggleState: currentState,
        subtitle: (widget.subtitleBuilder == null)
            ? widget.desc
            : widget.subtitleBuilder(currentState),
        primaryString: widget.label1,
        secondaryString: widget.label2,
        onTap: () {
          PrefService.setBool(widget.localKey, !currentState);
          if (widget.onChange != null) widget.onChange();
          setState(() {});
        });
  }
}
