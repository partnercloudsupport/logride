import 'package:flutter/material.dart';
import '../widgets/hyperlink_text.dart';

class PhotoCreditText extends StatelessWidget {
  PhotoCreditText({this.photoUrl, this.username, this.ccType, this.style});

  final String photoUrl;
  final String username;
  final String ccType;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {

    if(photoUrl == "" && username == "" && ccType == ""){
      return Container();
    }

    Widget _linkPortion = (photoUrl != "") ?
        HyperlinkText(text: "Photo", url: photoUrl, style: style) :
        Text("Photo", style: style,);

    Widget _userNamePortion = (username != "") ?
        Text(" by $username", style: style,) :
        Text("");

    Widget _licensePortion = (ccType != "") ?
        Text(ccType, style: style,) :
        Text("");

    return Row(
      children: <Widget>[
        _linkPortion,
        _userNamePortion,
        _licensePortion,
      ],
    );
  }
}
