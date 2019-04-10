import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/widgets/dialogs/dialog_frame.dart';
import 'package:log_ride/widgets/forms/form_header.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:photo_view/photo_view.dart';

// Provide users the option to take new image or upload existing one
// New Image:
// - Open Camera
// - Take Image
// Upload:
// - Image Picker
// Confirm with user
// Upload to firebase
// Confirm with user

class SubmitAttractionPhoto extends StatefulWidget {
  SubmitAttractionPhoto(this.attractionName);

  final String attractionName;

  @override
  _SubmitAttractionPhotoState createState() => _SubmitAttractionPhotoState();
}

class _SubmitAttractionPhotoState extends State<SubmitAttractionPhoto> {
  void _handleImageCapture() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _confirmUserSelection(image);
    }
  }

  void _handleImageSelection() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _confirmUserSelection(image);
    }
  }

  void _confirmUserSelection(File image) async {
    dynamic result = showDialog(
        context: context,
        builder: (BuildContext context) {
          return _UserConfirmationPage(
              image: image, attractionName: widget.attractionName);
        });
  }

  @override
  Widget build(BuildContext context) {
    return DialogFrame(
      content: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _ImageModeIconButton(
              mode: _ImageModeIconButtonMode.CAPTURE,
              onTap: () => _handleImageCapture(),
            ),
            _ImageModeIconButton(
              mode: _ImageModeIconButtonMode.UPLOAD,
              onTap: () => _handleImageSelection(),
            )
          ],
        )
      ],
      title: "Submit Image",
      dismiss: () => Navigator.of(context).pop(),
    );
  }
}

enum _ImageModeIconButtonMode { UPLOAD, CAPTURE }

class _ImageModeIconButton extends StatelessWidget {
  _ImageModeIconButton({this.mode, this.onTap});

  final _ImageModeIconButtonMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    IconData displayIcon;
    String displayText;

    Color interfaceColor = Colors.grey[800];

    switch (mode) {
      case _ImageModeIconButtonMode.CAPTURE:
        displayIcon = FontAwesomeIcons.camera;
        displayText = "CAPTURE";
        break;
      case _ImageModeIconButtonMode.UPLOAD:
        displayIcon = FontAwesomeIcons.upload;
        displayText = "UPLOAD";
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                displayIcon,
                size: 48.0,
                color: interfaceColor,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  displayText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .apply(color: interfaceColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _UserConfirmationPage extends StatelessWidget {
  _UserConfirmationPage({this.image, this.attractionName});

  final File image;
  final String attractionName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Header
          FormHeader(
            text: "Confirm Image For",
            subtext: attractionName,
          ),

          // Image Viewer + Legal Floating Button
          Expanded(
            child: Stack(
              children: <Widget>[
                ClipRect(
                  child: PhotoView(
                    imageProvider: FileImage(image),
                  ),
                ),
                Positioned(
                  right: 8.0,
                  top: 8.0,
                  child: RawMaterialButton(
                    child: Icon(
                      FontAwesomeIcons.info,
                      color: Theme.of(context).primaryColor,
                      size: 24.0,
                    ),
                    onPressed: () => print("Info"),
                    shape: CircleBorder(),
                    fillColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      persistentFooterButtons: <Widget>[
        InterfaceButton(
          text: "Cancel",
          onPressed: () => Navigator.of(context).pop(),
          color: UI_BUTTON_BACKGROUND,
          textColor: Colors.black,
        ),
        InterfaceButton(
          text: "Submit",
          onPressed: () => print("Submit"),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
        ),
      ],
    );
  }
}
