import 'package:flutter/material.dart';

class HomeIconButton extends StatelessWidget{
  HomeIconButton({this.onTap});

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 85.4,
                width: 85.4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
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
            ),
          ),
        )
      ],
    );
  }
}