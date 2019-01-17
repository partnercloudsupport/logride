import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import '../widgets/hero_network_image.dart';
import '../animations/fade_in_widget.dart';

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
    _target = _storage.ref()
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
          if (!url.hasData || url.hasError){
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
                  ))
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
            ),
            FadeInWidget(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Material(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(24.0),
                    child: IconButton(
                      alignment: Alignment.topLeft,
                      icon: Icon(
                        FontAwesomeIcons.arrowLeft,
                        color: Colors.white,
                        size: 32.0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            )
          ]));
        }));
  }
}
