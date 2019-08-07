import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum _LikeButtonAnimationState { liked, unliked, liking, unliking }

class LikeButton extends StatefulWidget {
  const LikeButton({Key key, this.onTap, this.isLiked}) : super(key: key);

  final bool isLiked;
  final Function onTap;

  @override
  LikeButtonState createState() => LikeButtonState();
}

class LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  Animation<double> anim;
  AnimationController controller;

  _LikeButtonAnimationState animationState = _LikeButtonAnimationState.unliked;

  void like() {
    if (animationState == _LikeButtonAnimationState.unliked) {
      if (widget.onTap != null) widget.onTap();
      animationState = _LikeButtonAnimationState.liking;
      animate();
    }
  }

  void animationFinished() {
    controller.reset();

    switch (animationState) {
      case _LikeButtonAnimationState.liked:
        // Do nothing. We're liked.
        break;
      case _LikeButtonAnimationState.unliked:
        // Do nothing. We're liked.
        break;
      case _LikeButtonAnimationState.liking:
        // We've finished liking, now we transition over to liked
        animationState = _LikeButtonAnimationState.liked;
        break;
      case _LikeButtonAnimationState.unliking:
        // We've finished unliking, now we transition over to unliked
        animationState = _LikeButtonAnimationState.unliked;
        break;
    }

    animate();
  }

  void animate() {
    controller.reset();
    switch (animationState) {
      case _LikeButtonAnimationState.liked:
        anim = AlwaysStoppedAnimation<double>(1.0);
        break;
      case _LikeButtonAnimationState.unliked:
        anim = AlwaysStoppedAnimation<double>(0.0);
        break;
      case _LikeButtonAnimationState.liking:
        anim = CurvedAnimation(
            parent: Tween<double>(begin: 0.0, end: 1.0).animate(controller),
            curve: Curves.decelerate);
        break;
      case _LikeButtonAnimationState.unliking:
        anim = CurvedAnimation(
            parent: Tween<double>(begin: 1.0, end: 0.0).animate(controller),
            curve: Curves.decelerate);
        break;
    }

    controller.forward();
    setState(() {});
  }

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 50));
    controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) animationFinished();
    });

    animationState = widget.isLiked
        ? _LikeButtonAnimationState.liked
        : _LikeButtonAnimationState.unliked;

    animate();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => like(),
      child: Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: anim,
            child: Icon(
              FontAwesomeIcons.solidHeart,
              color: Theme.of(context).primaryColor,
            ),
            builder: (BuildContext context, Widget child) {
              return Transform.scale(scale: anim.value * 1, child: child);
            },
          ),
          Icon(FontAwesomeIcons.heart),
        ],
      ),
    );
  }
}
