import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HyperlinkText extends StatelessWidget {
  HyperlinkText({this.text, this.url, this.style});

  final String text;
  final String url;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {

    TextStyle linkStyle = style;
    if(style == null){
      linkStyle = Theme.of(context).textTheme.body1;
    }
    linkStyle = linkStyle.apply(decoration: TextDecoration.underline);

    return InkWell(
      onTap: () async {
        if(await canLaunch(url)){
          await launch(url);
        }
      },
      child: Text(
        text,
        style: linkStyle,
      ),
    );
  }
}
