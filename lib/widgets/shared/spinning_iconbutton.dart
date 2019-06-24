import 'dart:math';
import 'package:flutter/material.dart';

enum SpinningIconButtonState {
  STOPPED,
  SPINNING,
}

enum _internalSpinState { STOPPED, SPIN_UP, SPIN_DOWN, SPINNING }

class SpinningIconButton extends StatefulWidget {
  SpinningIconButton({this.icon, this.spinState, this.onTap});

  final Widget icon;
  final SpinningIconButtonState spinState;
  final VoidCallback onTap;

  @override
  _SpinningIconButtonState createState() => _SpinningIconButtonState();
}

class _SpinningIconButtonState extends State<SpinningIconButton>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  _internalSpinState _iSpinState = _internalSpinState.STOPPED;

  void _animationFinished() {
    switch (_iSpinState) {
      case _internalSpinState.STOPPED:
        break;
      case _internalSpinState.SPIN_UP:
        _iSpinState = _internalSpinState.SPINNING;
        break;
      case _internalSpinState.SPIN_DOWN:
        _iSpinState = _internalSpinState.STOPPED;
        break;
      case _internalSpinState.SPINNING:
        break;
    }
    _animate();
  }

  void _animate() {
    controller.reset();
    switch (_iSpinState) {
      case _internalSpinState.STOPPED:
        animation = AlwaysStoppedAnimation<double>(0.0);
        controller.reset();
        break;
      case _internalSpinState.SPIN_UP:
        animation = CurvedAnimation(
            parent: Tween<double>(begin: 0.0, end: 1.0).animate(controller),
            curve: Curves.easeIn);
        controller.forward();
        break;
      case _internalSpinState.SPIN_DOWN:
        animation = CurvedAnimation(
            parent: Tween<double>(begin: 0.0, end: 1.0).animate(controller),
            curve: Curves.easeOut);
        controller.forward();
        break;
      case _internalSpinState.SPINNING:
        animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
        controller.repeat();
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) _animationFinished();
    });
    animation = AlwaysStoppedAnimation<double>(0.0);

    _animate();
  }

  @override
  void didUpdateWidget(SpinningIconButton oldWidget) {
    if (oldWidget.spinState == SpinningIconButtonState.STOPPED) {
      if (widget.spinState == SpinningIconButtonState.SPINNING) {
        _iSpinState = _internalSpinState.SPIN_UP;
      } else {
        _iSpinState = _internalSpinState.STOPPED;
      }
    } else if (oldWidget.spinState == SpinningIconButtonState.SPINNING) {
      if (widget.spinState == SpinningIconButtonState.SPINNING) {
        _iSpinState = _internalSpinState.SPINNING;
      } else {
        _iSpinState = _internalSpinState.SPIN_DOWN;
      }
    }

    _animate();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        builder: (BuildContext context, Widget child) {
          return Transform.rotate(
            angle: animation.value * 2 * pi,
            child: child,
          );
        },
        animation: animation,
        child: widget.icon,
      ),
    );
  }
}
