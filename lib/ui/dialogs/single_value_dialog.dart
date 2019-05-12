import 'package:flutter/material.dart';
import 'package:log_ride/widgets/dialogs/dialog_frame.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';

enum SingleValueDialogType { NUMBER, TEXT }

class SingleValueDialog extends StatefulWidget {
  SingleValueDialog({this.type, this.title, this.submitText, this.hintText, this.initialValue});

  final SingleValueDialogType type;
  final String title;
  final String submitText;
  final String hintText;
  final dynamic initialValue;

  @override
  _SingleValueDialogState createState() => _SingleValueDialogState();
}

class _SingleValueDialogState extends State<SingleValueDialog> {
  TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: (widget.initialValue != null) ? widget.initialValue.toString() : "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    TextInputType type = TextInputType.text;

    switch (widget.type) {
      case SingleValueDialogType.NUMBER:
        type = TextInputType.numberWithOptions(signed: false, decimal: false);
        break;
      case SingleValueDialogType.TEXT:
        type = TextInputType.text;
        break;
    }

    return DialogFrame(
      content: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: widget.hintText
            ),
            autofocus: true,
            keyboardType: type,
            maxLines: 1,
          ),
        ),
        InterfaceButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          text: widget.submitText,
          onPressed: () {
            dynamic value;
            switch (widget.type) {
              case SingleValueDialogType.NUMBER:
                value = num.tryParse(controller.text);
                Navigator.of(context).pop(value);
                break;
              case SingleValueDialogType.TEXT:
                value = controller.text;
                Navigator.of(context).pop(value as String);
                break;
            }
          },
        )
      ],
      title: widget.title,
    );
  }
}
