import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/data/contact_url_constants.dart';
import 'package:log_ride/widgets/dialogs/dialog_frame.dart';
import 'package:log_ride/widgets/forms/form_header.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';
import 'package:log_ride/widgets/shared/working_popup.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

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
  SubmitAttractionPhoto(this.attractionData, this.userName, this.parkName);

  final BluehostAttraction attractionData;
  final String userName;
  final String parkName;

  @override
  _SubmitAttractionPhotoState createState() => _SubmitAttractionPhotoState();
}

class _SubmitAttractionPhotoState extends State<SubmitAttractionPhoto> {
  FirebaseStorage storage = FirebaseStorage();
  StorageReference target;

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
    dynamic confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return _UserConfirmationPage(
              image: image,
              attractionName: widget.attractionData.attractionName);
        });

    if (confirmed == null) return;

    if (confirmed as bool) {
      WorkingController controller = WorkingController(
          progress: 0.0, workingText: "Preparing Image for Upload...");
      ValueNotifier<WorkingController> workingController =
          ValueNotifier(controller);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return WorkingPopUp(
              controller: workingController,
              showProgress: true,
            );
          });

      // Step 1: Compress Image to 0.25% JPEG quality
      Im.Image processed = Im.decodeImage(image.readAsBytesSync());
      List<int> data = Im.encodeJpg(processed, quality: 25);

      // Step 2: Establish MetaData
      StorageMetadata _metaData = StorageMetadata(contentType: "image/jpg");

      workingController.value = WorkingController(
          status: WorkingStatus.processing,
          workingText: "Uploading Prepared Image...",
          progress: 0.5);

      // Step 3: Upload to Firebase
      var success = await storage
          .ref()
          .child("UserSubmit/${widget.attractionData.attractionID}.jpg")
          .putData(data, _metaData)
          .onComplete;

      if (success.error != null) {
        workingController.value = WorkingController(
            status: WorkingStatus.error,
            progress: 1.0,
            workingText: "Error during upload process.");
        await Future.delayed(Duration(seconds: 5));
        Navigator.of(context).pop();
        return;
      }

      workingController.value = WorkingController(
          status: WorkingStatus.processing,
          workingText: "Submitting image information...",
          progress: 0.75);

      // Step 4: On Success, post info to bluehost
      WebFetcher wf = WebFetcher();
      int result = await wf.submitAttractionImage(
          rideId: widget.attractionData.attractionID,
          parkId: widget.attractionData.parkID,
          photoArtist: widget.userName,
          rideName: widget.attractionData.attractionName,
          parkName: widget.parkName);

      if (result == 200) {
        // Success!
        workingController.value = WorkingController(
            status: WorkingStatus.complete,
            workingText: "Submission Complete!",
            progress: 1.0);
        await Future.delayed(Duration(seconds: 5));
        // Pop progress, then options
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return;
      } else {
        // Report error with submission process
        workingController.value = WorkingController(
            status: WorkingStatus.error,
            workingText: "Error $result with submission.",
            progress: 1.0);
        await Future.delayed(Duration(seconds: 5));
        // Pop progress, return to options
        Navigator.of(context).pop();
        return;
      }
    } else {
      // A simple return sends the user back to the type selection dialog.
      // This provides the user the opportunity to select which type of upload
      // they want again.
      return;
    }
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
                  width: 40.0,
                  right: 8.0,
                  top: 8.0,
                  child: RawMaterialButton(
                    child: Icon(
                      FontAwesomeIcons.info,
                      color: Theme.of(context).primaryColor,
                      size: 24.0,
                    ),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StyledDialog(
                            body:
                                "Images you submit for review must comply with our Terms of Service. For more information, tap the \"Terms\" button below.",
                            title: "Image Terms",
                            actionText: "Close",
                            additionalAction: FlatButton(
                                onPressed: () async {
                                  if (await canLaunch(URL_TOS)) {
                                    launch(URL_TOS);
                                  }
                                },
                                child: Text("Terms")),
                          );
                        }),
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
          onPressed: () => Navigator.of(context).pop(false),
          color: UI_BUTTON_BACKGROUND,
          textColor: Colors.black,
        ),
        InterfaceButton(
          text: "Submit",
          onPressed: () async {
            dynamic result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return StyledDialog(
                  title: "Image Rights Notice",
                  body: "All images submitted must be uploaded with permission of the copyright owner. By continuing, you affirm that you hold the rights to use this image.",
                  action: () => Navigator.of(context).pop(true),
                  actionText: "Confirm",
                  additionalAction: FlatButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Deny")),
                );
              }
            );

            if(result == null) return;
            if(result == true) Navigator.of(context).pop(true);
            if(result == false) Navigator.of(context).pop(false);
          },
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
        ),
      ],
    );
  }
}
