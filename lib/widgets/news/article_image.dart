import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:log_ride/widgets/shared/no_image.dart';

class ArticleImage extends StatelessWidget {
  ArticleImage({this.url, this.likeFunction, this.onTap});

  final String url;
  final Function likeFunction;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: (url != "")
          ? CachedNetworkImage(
              imageUrl: url,
              placeholder: (BuildContext context, String url) {
                return NoImage(
                    label: "Loading Image", child: CircularProgressIndicator());
              },
              placeholderFadeInDuration: Duration(milliseconds: 250),
              height: 200.0,
              fit: BoxFit.cover,
            )
          : NoImage(label: "No Image Avaliable"),
      onDoubleTap: () => likeFunction(),
      onTap: (onTap != null) ? () => onTap() : null,
    );
  }
}
