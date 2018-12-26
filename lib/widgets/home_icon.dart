import 'package:flutter/material.dart';

class HomeIconButton extends StatelessWidget{
  HomeIconButton({this.onTap, this.decoration});

  final Function onTap;
  final Widget decoration;

  @override
  Widget build(BuildContext context) {
    Widget decor;
    Color colorOverlay;

    if(decoration != null){
      decor = decoration;
      colorOverlay = Colors.grey[600];
    } else {
      decor = Container();
      colorOverlay = Colors.transparent;
    }

    return Column(
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              onTap: onTap != null ? onTap : (){}, // Pass an empty function if we don't have a tap function
              child: Container(
                height: 85.4,
                width: 85.4,
                child: Stack(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints.expand(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(colorOverlay, BlendMode.screen),
                                image: AssetImage('assets/appicon.png')),
                            border: Border.all(
                              color: Colors.white,
                              width: 4.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 0.1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2))
                            ]),
                      ),
                    ),
                    decor
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}