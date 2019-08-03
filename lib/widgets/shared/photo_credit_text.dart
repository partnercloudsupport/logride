import 'package:flutter/material.dart';
import 'package:log_ride/widgets/shared/hyperlink_text.dart';

class PhotoCreditText extends StatelessWidget {
  PhotoCreditText({this.photoUrl, this.author, this.ccType, this.style});

  final String photoUrl;
  final String author;
  final String ccType;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (photoUrl == "" && author == "" && ccType == "") {
      return Container();
    }

    Widget _linkPortion = (photoUrl != "")
        ? HyperlinkText(text: "Photo", url: photoUrl, style: style)
        : Text(
            "Photo",
            style: style,
          );

    Widget _userNamePortion = (author != "")
        ? Text(
            " by $author",
            style: style,
          )
        : Text("");

    Widget _licensePortion = (ccType != "")
        ? Text(
            ccType,
            style: style,
          )
        : Text("");

    return Row(
      children: <Widget>[
        _linkPortion,
        _userNamePortion,
        _licensePortion,
      ],
    );
  }
}
