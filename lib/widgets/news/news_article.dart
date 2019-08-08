import 'package:flutter/material.dart';
import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/data/news/article_manager.dart';
import 'package:log_ride/data/news/news_structures.dart';
import 'package:log_ride/widgets/news/article_image.dart';
import 'package:log_ride/widgets/news/date_and_read_display.dart';
import 'package:log_ride/widgets/news/like_button.dart';
import 'package:log_ride/widgets/news/positioned_overlays.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsArticleEntry extends StatefulWidget {
  const NewsArticleEntry({Key key, this.news, this.userData}) : super(key: key);

  final BluehostNews news;
  final FirebaseNews userData;

  @override
  _NewsArticleEntryState createState() => _NewsArticleEntryState();
}

class _NewsArticleEntryState extends State<NewsArticleEntry> {
  GlobalKey<LikeButtonState> likeChild;
  ArticleManager manager;

  void _expandArticle(BuildContext context) {
    Navigator.push(
        context,
        SlideInRoute(
            direction: SlideInDirection.UP,
            dialogStyle: true,
            widget: NewsArticleExpanded(
              news: widget.news,
              userData: widget.userData,
              manager: manager,
            )));
  }

  @override
  void initState() {
    likeChild = GlobalKey<LikeButtonState>();
    super.initState();
  }

  @override
  void deactivate() {
    if (widget.userData.hasRead != true) {
      manager?.viewArticle(widget.news);
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    manager = Provider.of<ArticleManager>(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Image Display
              ArticleImage(
                  url: widget.news.photoLink,
                  likeFunction: () => likeChild.currentState.like(),
                  onTap: () => _expandArticle(context)),
              // Snippet / Data Display
              InkWell(
                onTap: () => _expandArticle(context),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Date/time Label
                          DateAndReadDisplay(
                            created: widget.news.dateCreated,
                            unread: !widget.userData.hasRead,
                          ),
                          // Snippet Display
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: Text(
                              widget.news.snippet,
                              maxLines: 4,
                              overflow: TextOverflow.fade,
                            ),
                          )
                        ],
                      ),
                      Positioned.fill(
                          child: Align(
                        child: Text(
                          "Read More...",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        alignment: Alignment.bottomRight,
                      ))
                    ],
                  ),
                ),
              ),
              // Accreditation display
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          text: "From ",
                          style: DefaultTextStyle.of(context)
                              .style
                              .apply(color: Colors.white, fontSizeDelta: -2.0),
                          children: <TextSpan>[
                            TextSpan(
                                text: widget.news.sourceName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0))
                          ]),
                    ),
                    if (widget.news.submittedBy != "")
                      RichText(
                        text: TextSpan(
                            text: "Posted By ",
                            style: DefaultTextStyle.of(context).style.apply(
                                color: Colors.white, fontSizeDelta: -2.0),
                            children: <TextSpan>[
                              TextSpan(
                                  text: widget.news.submittedBy,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0))
                            ]),
                      )
                  ],
                ),
              )
            ],
          ),
          // Park Label
          PositionedArticleOverlay(
            child: Text(
              widget.news.mainParkName,
              style: TextStyle(fontSize: 16.0),
            ),
            alignment: Alignment.topLeft,
          ),
          // Like block
          PositionedArticleOverlay(
            child: Column(
              children: <Widget>[
                LikeButton(
                  isLiked: widget.userData.hasLiked,
                  key: likeChild,
                  onTap: () async {
                    await manager.likeArticle(widget.news);
                    setState(() {});
                  },
                ),
                Text(
                  widget.news.numberOfLikes.toString() + " likes",
                ),
              ],
            ),
            alignment: Alignment.topRight,
          )
        ],
      ),
    );
  }
}

class NewsArticleExpanded extends StatefulWidget {
  const NewsArticleExpanded({Key key, this.news, this.userData, this.manager})
      : super(key: key);

  final BluehostNews news;
  final FirebaseNews userData;
  final ArticleManager manager;

  @override
  _NewsArticleExpandedState createState() => _NewsArticleExpandedState();
}

class _NewsArticleExpandedState extends State<NewsArticleExpanded> {
  GlobalKey<LikeButtonState> likeChild;

  @override
  void initState() {
    likeChild = GlobalKey<LikeButtonState>();
    super.initState();
  }

  @override
  void dispose() {
    if (widget.userData.hasRead != true) {
      widget.manager?.viewArticle(widget.news);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Dismissible(
          key: Key('key'),
          direction: DismissDirection.down,
          resizeDuration: null,
          onDismissed: (d) {
            Navigator.of(context).pop();
          },
          child: _buildBody(context),
        ));
  }

  Widget _buildBody(BuildContext context) {
    String partnerURL = widget.news.sourceLink;
    if (widget.news.sourceLink != "") {
      Uri partnerUri = Uri.parse(partnerURL);
      partnerURL = partnerUri.host;
    }

    return SafeArea(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: BoxConstraints.expand(),
              child: Container(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 56.0),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              ),
              margin: EdgeInsets.zero,
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      ArticleImage(
                        likeFunction: () => likeChild.currentState.like(),
                        url: widget.news.photoLink,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                DateAndReadDisplay(
                                  unread: !widget.userData.hasRead,
                                  created: widget.news.dateCreated,
                                ),
                                if (widget.news.submittedBy != "")
                                  Text(
                                    "Posted by " + widget.news.submittedBy,
                                    style: TextStyle(color: Colors.grey),
                                  )
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                widget.news.snippet,
                                style: TextStyle(height: 1.1, fontSize: 16.0),
                              ),
                            ),
                            if (partnerURL != "")
                              InterfaceButton(
                                text: "Continue Article on",
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                subtext: partnerURL,
                                onPressed: () async {
                                  if (await canLaunch(widget.news.sourceLink)) {
                                    await launch(widget.news.sourceLink);
                                  }
                                },
                              )
                          ],
                        ),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  ),
                  PositionedArticleOverlay(
                    alignment: Alignment.topRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        LikeButton(
                          isLiked: widget.userData.hasLiked,
                          key: likeChild,
                          onTap: () async {
                            await widget.manager.likeArticle(widget.news);
                            setState(() {});
                          },
                        ),
                        Text(
                          widget.news.numberOfLikes.toString() + " likes",
                        ),
                      ],
                    ),
                  ),
                  PositionedArticleOverlay(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.news.mainParkName,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
