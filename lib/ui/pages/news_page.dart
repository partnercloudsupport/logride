import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:log_ride/data/public_key.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:simple_rsa/simple_rsa.dart';

class TestNewsPage extends StatefulWidget {
  @override
  _TestNewsPageState createState() => _TestNewsPageState();
}

class _TestNewsPageState extends State<TestNewsPage> {
  String payload = "";
  String returnString = "";

  void testRequest() async {
    print("Beginning test");
    String words = '{"newsID": 116}';

    //String encryptedText = await encryptString(words, PUBLIC_KEY);
    String signedString = await signString(words, PRIVATE_KEY);
    print("Signature done: $signedString");

    Map body = {"payload": words, "signature": signedString};

    http.Response request = await http.post(
        "http://www.beingpositioned.com/theparksman/LogRide/Version1.2.2/newsfeedLikeArticle.php",
        body: jsonEncode(body));

    print("Got result: ${request.statusCode}");
    print("Result: ${request.body}");
    print("Local Test: ${await verifyString(words, signedString, PUBLIC_KEY)}");
    setState(() {
      payload = signedString;
      returnString = request.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => setState(() {
                returnString = "";
                payload = "";
              }),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(returnString),
              InterfaceButton(
                text: "Send test request",
                color: Theme.of(context).primaryColor,
                onPressed: () => testRequest(),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
