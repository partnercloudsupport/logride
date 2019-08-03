import 'package:flutter/material.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';

enum SingleValueDialogType { NUMBER, TEXT, PASSWORD }

class SingleValueDialog extends StatefulWidget {
  SingleValueDialog(
      {this.type,
      this.title,
      this.submitText,
      this.hintText,
      this.initialValue});

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

  // Used in password obscuring
  bool visible = false;

  @override
  void initState() {
    controller = TextEditingController(
        text: (widget.initialValue != null)
            ? widget.initialValue.toString()
            : "");
    super.initState();
  }

  void finish() {
    dynamic value;
    switch (widget.type) {
      case SingleValueDialogType.NUMBER:
        value = num.tryParse(controller.text);
        Navigator.of(context).pop(value);
        break;
      case SingleValueDialogType.PASSWORD:
      case SingleValueDialogType.TEXT:
        value = controller.text;
        Navigator.of(context).pop(value as String);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextInputType type = TextInputType.text;

    switch (widget.type) {
      case SingleValueDialogType.NUMBER:
        type = TextInputType.numberWithOptions(signed: false, decimal: false);
        break;
      case SingleValueDialogType.PASSWORD:
      case SingleValueDialogType.TEXT:
        type = TextInputType.text;
        break;
    }

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 2 / 3,
            child: TextField(
              obscureText: (widget.type == SingleValueDialogType.PASSWORD)
                  ? !visible
                  : false,
              controller: controller,
              onEditingComplete: () => finish(),
              decoration: InputDecoration(
                  hintText: widget.hintText,
                  suffixIcon: (widget.type == SingleValueDialogType.PASSWORD)
                      ? GestureDetector(
                          child: Icon(visible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          // Toggle visibility of password on tap
                          onTap: () => setState(() => visible = !visible),
                        )
                      : null),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              keyboardType: type,
              maxLines: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: InterfaceButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              text: widget.submitText,
              onPressed: () => finish(),
            ),
          )
        ],
      ),
    );
  }
}
