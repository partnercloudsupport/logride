import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum _ButtonType {
  SUBTRACT_ONE,
  SUBTRACT_MANY,
  ADD_ONE,
  ADD_MANY,
}

const Map<_ButtonType, IconData> _buttonImageMap = {
  _ButtonType.SUBTRACT_ONE: FontAwesomeIcons.angleLeft,
  _ButtonType.SUBTRACT_MANY: FontAwesomeIcons.angleDoubleLeft,
  _ButtonType.ADD_ONE: FontAwesomeIcons.angleRight,
  _ButtonType.ADD_MANY: FontAwesomeIcons.angleDoubleRight
};

class SetExperienceDialogBox extends StatefulWidget {
  SetExperienceDialogBox(this.originalCount);

  final num originalCount;

  @override
  _SetExperienceDialogBoxState createState() => _SetExperienceDialogBoxState();
}

class _SetExperienceDialogBoxState extends State<SetExperienceDialogBox> {
  TextEditingController _editingController;

  num currentCount;

  @override
  void initState() {
    currentCount = widget.originalCount;
    _editingController = TextEditingController(text: currentCount.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Establishing the text every time we build ensures that the text is always up to date.
    _editingController.text = currentCount.toString();

    // Used to direct the user's cursor to the end of the text field each time the widget rebuilds and the user is editing.
    // This means it typically happens when the user first taps on the widget and the keyboard rolls up.
    _editingController.selection =
        TextSelection.collapsed(offset: currentCount.toString().length);

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Title/header section
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Text(
                  "Set Experience Count",
                  style: Theme.of(context).textTheme.title,
                ),
              ),

              // Section responsible for direct user input/interaction
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildInputIconButton(_ButtonType.SUBTRACT_ONE),
                  _buildInputIconButton(_ButtonType.SUBTRACT_MANY),
                  Container(
                    width: 60,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.grey[100]),
                      child: TextField(
                        controller: _editingController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(border: InputBorder.none),
                        onChanged: (value) {
                          currentCount = int.parse(value);
                        },
                      ),
                    ),
                  ),
                  _buildInputIconButton(_ButtonType.ADD_MANY),
                  _buildInputIconButton(_ButtonType.ADD_ONE)
                ],
              ),

              // Confirm/cancel buttons for user input. Tapping on the background also cancels, but just in case.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildConfirmButton(FontAwesomeIcons.times, Colors.grey[350],
                      () => Navigator.of(context).pop(widget.originalCount)),
                  _buildConfirmButton(
                      FontAwesomeIcons.check,
                      Theme.of(context).buttonColor,
                      () => Navigator.of(context).pop(currentCount))
                ],
              )
            ],
          ),
        ));
  }

  // Used in the manipulation of user data
  Widget _buildInputIconButton(_ButtonType type) {
    return IconButton(
      icon: Icon(_buttonImageMap[type]),
      onPressed: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        switch (type) {
          // Addition cases are easy - we really can't overflow with this.
          case _ButtonType.ADD_MANY:
            setState(() {
              currentCount += 5;
            });
            break;

          case _ButtonType.ADD_ONE:
            setState(() {
              currentCount++;
            });
            break;

          case _ButtonType.SUBTRACT_MANY:
            int valueRemoved = 5;
            // If we're going to go negative, only remove as much as is needed
            // to take us to zero.
            if (currentCount - valueRemoved < 0) {
              valueRemoved = currentCount;
            }

            setState(() {
              currentCount -= valueRemoved;
            });
            break;

          case _ButtonType.SUBTRACT_ONE:
            // Keeping us from going negative
            if (currentCount - 1 < 0) return;
            setState(() {
              currentCount--;
            });
            break;
        }
      },
    );
  }

  // Simple wrapper to clean up the creation of confirmation/cancel buttons
  Widget _buildConfirmButton(
      IconData data, Color iconColor, Function tapHandler) {
    return IconButton(
      icon: Icon(data, color: iconColor, size: 32),
      onPressed: tapHandler,
    );
  }
}
