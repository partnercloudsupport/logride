import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class HeroNetworkImage extends StatelessWidget {
  const HeroNetworkImage({Key key, this.url, this.onTap, this.fit}) : super(key: key);

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
          child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage, image: url, fit: fit)
        ),
      ),
    );
  }
}