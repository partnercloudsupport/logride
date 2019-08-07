import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class HeroNetworkImage extends StatelessWidget {
  const HeroNetworkImage({Key key, this.url, this.onTap, this.fit})
      : super(key: key);

  final String url;
  final VoidCallback onTap;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Hero(
      transitionOnUserGestures: true,
      tag: url,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onTap,
            child: CachedNetworkImage(
              imageUrl: url,
              placeholder: (c, url) {
                return Image.memory(kTransparentImage);
              },
              placeholderFadeInDuration: Duration(milliseconds: 250),
              fit: fit,
            )),
      ),
    );
  }
}
