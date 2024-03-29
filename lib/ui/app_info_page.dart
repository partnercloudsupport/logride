import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:log_ride/data/contact_url_constants.dart';
import 'package:log_ride/widgets/shared/home_icon.dart';
import 'package:log_ride/widgets/shared/hyperlink_text.dart';
import 'package:log_ride/widgets/shared/back_button.dart';

class AppInfoPage extends StatefulWidget {
  AppInfoPage(
      {this.signOut,
      this.username,
      this.locationSpoofUpdate,
      this.locationSpoofEnabled = false,
      this.admin = false});

  final Function signOut;
  final Function(bool) locationSpoofUpdate;
  final bool admin;
  final bool locationSpoofEnabled;
  final String username;

  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  PackageInfo ourInfo;
  bool _locationSpoofEnabled;

  @override
  void initState() {
    super.initState();
    _locationSpoofEnabled = widget.locationSpoofEnabled;
    initVersionCode();
  }

  void initVersionCode() async {
    PackageInfo loadedInfo = await PackageInfo.fromPlatform();
    setState(() {
      ourInfo = loadedInfo;
    });
  }

  void _locationSwitchTapped() {
    setState(() {
      _locationSpoofEnabled = !_locationSpoofEnabled;
    });
  }

  void _creditsPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text("LogRide Credits"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _CreditHeader("App Development"),
              _CreditEntry("Justin Lawrence (iOS)"),
              _CreditEntry("Mark Lawrence (iOS)"),
              _CreditEntry("Thomas Stoeckert (Android)"),
              _CreditHeader("Park / Attraction Research"),
              _CreditEntry("Cardin Menkemeller"),
              _CreditEntry("Daniel Fischman"),
              _CreditEntry("Mario Brajevich"),
              _CreditHeader("Social Media"),
              _CreditEntry("Michael Brenkan")
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle linkStyle = Theme.of(context)
        .textTheme
        .body1
        .apply(color: Theme.of(context).primaryColor, fontSizeDelta: 6);

    Widget toggleWidget = Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: InkWell(
        onTap: _locationSwitchTapped,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Spoof location to Animal Kingdom"),
            Switch.adaptive(
                value: _locationSpoofEnabled,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (nValue) =>
                    _locationSwitchTapped())
          ],
        ),
      ),
    );

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: <Widget>[
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: HomeIconButton(
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "LogRide",
                            textScaleFactor: 2,
                          ),
                        ),
                        Text("Version: ${ourInfo?.version ?? "unknown"}"),
                        widget.admin ? toggleWidget : Container(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HyperlinkText(
                            text: "FAQ",
                            url: URL_FAQ,
                            style: linkStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HyperlinkText(
                            text: "Terms of Service",
                            url: URL_TOS,
                            style: linkStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HyperlinkText(
                            text: "Privacy Policy",
                            url: URL_PRIVACY,
                            style: linkStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            child: Text("Credits", style: linkStyle.apply(decoration: TextDecoration.underline)),
                            onTap: () => _creditsPopUp(),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child:
                              Text("Currently Logged in as ${widget.username}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0)),
                            child: Text(
                              "LOG OUT",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              widget.signOut();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text("Questions or Comments? Contact us at"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: HyperlinkText(
                            text: URL_EMAIL.replaceAll("mailto:", ""),
                            url:
                                "$URL_EMAIL?subject=LogRide%20Android%20Feedback&body=Android%20Edition.%20Version:%20${ourInfo?.version ?? "unknown"}",
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            RoundBackButton(
              direction: BackButtonDirection.RIGHT,
            )
          ],
        ));
  }
}

class _CreditHeader extends StatelessWidget {
  _CreditHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold),),
    );
  }
}

class _CreditEntry extends StatelessWidget {
  _CreditEntry(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 16.0),);
  }
}
