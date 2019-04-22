import 'package:flutter/material.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';

enum SingleValueDialogType { NUMBER, TEXT }

class SingleValueDialog extends StatefulWidget {
  SingleValueDialog({this.type, this.title, this.submitText});

  final SingleValueDialogType type;
  final String title;
  final String submitText;

  @override
  _SingleValueDialogState createState() => _SingleValueDialogState();
}

class _SingleValueDialogState extends State<SingleValueDialog> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    /* ----- Unused for now --------
    TextInputType type = TextInputType.text;

    switch (widget.type) {
      case SingleValueDialogType.NUMBER:
        type = TextInputType.number;
        break;
      case SingleValueDialogType.TEXT:
        type = TextInputType.text;
        break;
    }*/

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              constraints: BoxConstraints.expand(),
            ),
          ),
          SafeArea(
              child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: Text(
                          "Enter Today's Score:",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                      width: double.infinity,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: false),
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
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
