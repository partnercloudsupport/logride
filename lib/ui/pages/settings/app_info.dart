import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/contact_url_constants.dart';
import 'package:log_ride/widgets/dialogs/credits_dialog.dart';
import 'package:log_ride/widgets/settings/settings_footer.dart';
import 'package:log_ride/widgets/settings/settings_tile.dart';
import 'package:package_info/package_info.dart';
import 'package:preferences/preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoPage extends StatefulWidget {
  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  PackageInfo ourInfo;

  @override
  void initState() {
    super.initState();
    initVersionCode();
  }

  void initVersionCode() async {
    PackageInfo loadedInfo = await PackageInfo.fromPlatform();
    setState(() {
      ourInfo = loadedInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Info"),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PreferencePage([
        Padding(
          padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/plain.png'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SettingsFooter(
            appVersion: ourInfo?.version ?? "error",
          ),
        ),
        // contact us
        SettingsTile(
          title: "Contact the LogRide Team",
          subtitle:
              "Questions or Comments? Contact the LogRide Team via email @${URL_EMAIL.replaceAll("mailto:", "")}",
          onTap: () async {
            String mailURL = URL_EMAIL +
                "?subject=LogRide%20Android%20Feedback&body=Android%Edition.%20Version:%20${ourInfo?.version ?? "unknown"}";
            if (await canLaunch(mailURL)) {
              await launch(mailURL);
            }
          },
        ),
        // Credits button
        SettingsTile(
          title: "The LogRide Team",
          subtitle:
              "See dedicated people who were critical in putting the app together",
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CreditsDialog();
                });
          },
        ),
        // App Information Big Item
        SettingsTile(
          title: "FAQ",
          subtitle: "View answers to Frequently Asked Questions",
          onTap: () async {
            if (await canLaunch(URL_FAQ)) {
              await launch(URL_FAQ);
            }
          },
        ),
        SettingsTile(
          title: "Terms of Service",
          subtitle: "View LogRide's Terms of Service",
          onTap: () async {
            if (await canLaunch(URL_TOS)) {
              await launch(URL_TOS);
            }
          },
        ),
        SettingsTile(
          title: "Privacy Policy",
          subtitle: "View LogRide's Privacy Policy",
          onTap: () async {
            if (await canLaunch(URL_PRIVACY)) {
              await launch(URL_PRIVACY);
            }
          },
        ),
        SettingsTile(
          title: "Write a Review",
          subtitle: "Write a review of LogRide on the Google Play Store",
          onTap: () async {
            if (await canLaunch(URL_PLAY)) {
              await launch(URL_PLAY);
            }
          },
        )
      ]),
    );
  }
}
