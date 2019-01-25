import 'package:flutter/material.dart';

class FadeWidget extends StatefulWidget {

  FadeWidget({this.child, this.duration = const Duration(milliseconds: 500), this.forward = true});

  final Widget child;
  final Duration duration;
  final bool forward;

  @override
  _FadeWidgetState createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget> with SingleTickerProviderStateMixin{
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    if(widget.forward){
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
