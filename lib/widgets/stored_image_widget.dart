import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:log_ride/widgets/hero_network_image.dart';
import 'package:log_ride/widgets/back_button.dart';

class FirebaseAttractionImage extends StatefulWidget {
  FirebaseAttractionImage({this.parkID, this.attractionID, this.overlay});

  final int parkID;
  final int attractionID;
  final Widget overlay;

  @override
  _FirebaseAttractionImageState createState() =>
      _FirebaseAttractionImageState();
}

class _FirebaseAttractionImageState extends State<FirebaseAttractionImage> {
  FirebaseStorage _storage = FirebaseStorage();
  StorageReference _target;

  final _backgroundColor = Colors.grey[600];
  final _foregroundColor = Colors.grey[400];

  Future<String> _getTargetURL() {
    return _target.getDownloadURL().then((value) => value as String);
  }

  @override
  void initState() {
    _target = _storage
        .ref()
        .child(widget.parkID.toString())
        .child(widget.attractionID.toString() + ".jpg");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      child: FutureBuilder(
        future: _getTargetURL(),
        builder: (BuildContext context, AsyncSnapshot<String> url) {
          // If the page 404's, we don't have a URL, and we don't have an image on our firebase.
          // FirebaseStorage spews an error into the console, and I can't seem to prevent it. but it's ok.
          if (!url.hasData || url.hasError) {
            return Container(
              constraints: BoxConstraints.expand(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Icon(
                      FontAwesomeIcons.image,
                      color: _foregroundColor,
                      size: 40.0,
                    ),
                  ),
                  Text(
                    "NO IMAGE FOUND",
                    style: TextStyle(color: _foregroundColor),
                  )
                ],
              ),
            );
          } else {
            return Stack(children: <Widget>[
              Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
              )),
              Container(
                  constraints: BoxConstraints.expand(),
                  child: HeroNetworkImage(
                    url: url.data,
                    fit: BoxFit.cover,
                    onTap: () => _onImageTap(url.data),
                  )),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 20,
                child: (widget.overlay != null)
                    ? Container(
                        color: Color.fromRGBO(0, 0, 0, 0.75),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            child: widget.overlay),
                      )
                    : Container(),
              )
            ]);
          }
        },
      ),
    );
  }

  void _onImageTap(String url) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        maintainState: true,
        builder: (BuildContext context) {
          return Scaffold(
              body: Stack(children: [
            PhotoView(
              imageProvider: NetworkImage(url),
              heroTag: url,
              transitionOnUserGestures: true,
              gaplessPlayback: true,
              maxScale: PhotoViewComputedScale.covered * 5.0,
              minScale: PhotoViewComputedScale.contained * 1.0,
            ),
            RoundBackButton(),
            SafeArea(
              child: (widget.overlay != null)
                  ? Container(
                      constraints: BoxConstraints.expand(),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          constraints: BoxConstraints.expand(height: 20),
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: widget.overlay,
                          )))
                  : Container(),
            )
          ]));
        }));
  }
}
