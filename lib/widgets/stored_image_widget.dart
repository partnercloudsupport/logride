import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

class FirebaseAttractionImage extends StatefulWidget {
  FirebaseAttractionImage({this.parkID, this.attractionID});

  final int parkID;
  final int attractionID;

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
          if (!url.hasData) {
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
              Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),)),
              Container(
                constraints: BoxConstraints.expand(),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: url.data,
                  fit: BoxFit.cover,
                ),
              )
            ]);
          }
        },
      ),
    );
  }
}
