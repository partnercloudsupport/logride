import 'package:flutter/material.dart';

class OffstageCrossFade extends StatefulWidget {
  OffstageCrossFade({this.child, this.offStageState});

  final bool offStageState;
  final Widget child;

  @override
  _OffstageCrossFadeState createState() => _OffstageCrossFadeState();
}

enum _animMode { NONE, ANIM_IN, ANIM_OUT }

class _OffstageCrossFadeState extends State<OffstageCrossFade>
    with TickerProviderStateMixin {
  Animation<double> _fadeAnimation;
  Animation<double> _scaleAnimation;
  AnimationController _controller;

  _animMode _mode;

  bool offstageChild = false;

  @override
  void initState() {
    if (widget.offStageState) {
      _mode = _animMode.ANIM_IN;
      offstageChild = true;
    } else {
      _mode = _animMode.NONE;
    }
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_controller);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) _animationComplete();
    });

    switch (_mode) {
      case _animMode.ANIM_IN:
        _controller.forward();
        break;
      case _animMode.ANIM_OUT:
        _controller.reverse();
        break;
      case _animMode.NONE:
        _controller.value = _controller.upperBound;
        break;
    }
  }

  @override
  void didUpdateWidget(OffstageCrossFade oldWidget) {
    if (oldWidget.offStageState && !widget.offStageState) {
      _mode = _animMode.ANIM_IN;
      offstageChild = false;
      _controller.forward();
    } else if (!oldWidget.offStageState && widget.offStageState) {
      _mode = _animMode.ANIM_OUT;
      _controller.reverse();
    } else {
      _mode = _animMode.NONE;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _animationComplete() {
    if (_mode == _animMode.ANIM_OUT) {
      setState(() {
        offstageChild = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
        offstage: offstageChild,
        child: AnimatedBuilder(
          builder: (BuildContext context, Widget child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                  child: widget.child, scale: _scaleAnimation.value),
            );
          },
          animation: _fadeAnimation,
          child: widget.child,
        ));
  }
}
