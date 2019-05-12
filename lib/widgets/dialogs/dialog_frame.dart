import 'package:flutter/material.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';

class DialogFrame extends StatelessWidget {
  DialogFrame({@required this.content, this.title = "Dialog", this.dismiss, this.resizeToAvoidBottomInset = true});

  final String title;
  final Function dismiss;
  final List<Widget> content;
  final bool resizeToAvoidBottomInset;

  void close(BuildContext context) {
    if (dismiss == null) {
      Navigator.of(context).pop();
    } else {
      dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(children: <Widget>[

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => close(context),
            child: Container(
              constraints: BoxConstraints.expand(),
            ),
          ),

          SafeArea(
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  color: Theme.of(context).primaryColor,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .title
                                            .apply(color: Colors.white),
                                      ),
                                      InterfaceButton(
                                        text: "Close",
                                        textColor: Colors.black,
                                        onPressed: () => close(context),
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: content,
                                )
                              ])))))
        ]));
  }
}
