import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/news/news_structures.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';

class SubmitArticlePage extends StatefulWidget {
  @override
  _SubmitArticlePageState createState() => _SubmitArticlePageState();
}

class _SubmitArticlePageState extends State<SubmitArticlePage> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              constraints: BoxConstraints.expand(),
            ),
          ),
          Center(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "SUBMIT A NEW ARTICLE",
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.title,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: urlController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(FontAwesomeIcons.paste),
                            onPressed: () async {
                              ClipboardData data =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              if (data == null) return;
                              String clipboardString = data.text;
                              urlController.text = clipboardString;
                            },
                          ),
                          labelText: "Link",
                          hintText: "http://google.com",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: detailsController,
                        maxLines: null,
                        decoration: InputDecoration(
                            labelText: "Details",
                            border: InputBorder.none,
                            hintText: "Further details about the article..."),
                      ),
                    ),
                    InterfaceButton(
                      text: "SUBMIT",
                      onPressed: () {
                        if (urlController.text.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StyledDialog(
                                  title: "Error with Submission",
                                  body: "Please include a link to the article",
                                  actionText: "OK",
                                );
                              });
                          return;
                        }

                        Navigator.of(context).pop(NewsSubmission(
                            url: urlController.text,
                            description: detailsController.text));
                      },
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*

/// Don't use WebView until it's stable enough to be useful. Currently, tapping
/// the field to edit it opens the keyboard, triggering a resize, which then
/// causes the webview to resize, disabling the keyboard
/// in short: it's broke, yo

class SubmitArticlePage extends StatefulWidget {
  @override
  _SubmitArticlePageState createState() => _SubmitArticlePageState();
}

class _SubmitArticlePageState extends State<SubmitArticlePage> {
  TextEditingController urlController = TextEditingController();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  void _pageFinishedHandler(String url) {
    print(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WebView(
        initialUrl: "about:blank",
        onPageFinished: _pageFinishedHandler,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
      bottomSheet: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: urlController,
              onEditingComplete: () {
                print(urlController.value.text);
              },
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.link),
                suffixIcon: Icon(FontAwesomeIcons.paste),
                labelText: "URL",
                hintText: "http://google.com",
              ),
            )
          ],
        ),
      ),
    );
  }
}
*/
