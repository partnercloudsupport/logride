import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:log_ride/data/news/article_manager.dart';
import 'package:log_ride/data/news/news_structures.dart';
import 'package:log_ride/widgets/news/like_button.dart';
import 'package:log_ride/widgets/shared/no_image.dart';
import 'package:provider/provider.dart';

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
              GestureDetector(
                child: (widget.news.photoLink != "")
                    ? CachedNetworkImage(
                        imageUrl: widget.news.photoLink,
                        placeholder: (BuildContext context, String url) {
                          return NoImage(
                              label: "Loading Image",
                              child: CircularProgressIndicator());
                        },
                        placeholderFadeInDuration: Duration(milliseconds: 250),
                        height: 200.0,
                        fit: BoxFit.cover,
                      )
                    : NoImage(label: "No Image Avaliable"),
                onDoubleTap: () => likeChild.currentState.like(),
              ),
              // Snippet / Data Display
              InkWell(
                onTap: () => print("Read More"),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Date/time Label
                          Row(
                            children: <Widget>[
                              if (!widget.userData.hasRead)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle),
                                    constraints: BoxConstraints.expand(
                                        width: 8.0, height: 8.0),
                                  ),
                                ),
                              Text(
                                "Last Updated ${DateFormat.yMMMMd("en_US").format(widget.news.dateLastUpdated)}",
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.left,
                              ),
                            ],
                            mainAxisSize: MainAxisSize.min,
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
                                    fontSize: 16.0))
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
                                      fontSize: 16.0))
                            ]),
                      )
                  ],
                ),
              )
            ],
          ),
          // Park Label
          Align(
            alignment: Alignment.topLeft,
            child: Material(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(10.0))),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(widget.news.mainParkName),
                )),
          ),
          // Like block
          Align(
            alignment: Alignment.topRight,
            child: Material(
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(10.0))),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: <Widget>[
                    LikeButton(
                      isLiked: widget.userData.hasLiked,
                      key: likeChild,
                      onTap: () async {
                        await Provider.of<ArticleManager>(context)
                            .likeArticle(widget.news);
                        setState(() {});
                      },
                    ),
                    Text(
                      widget.news.numberOfLikes.toString() + " likes",
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NewsArticleExpanded extends StatefulWidget {
  const NewsArticleExpanded({Key key, this.news}) : super(key: key);

  final BluehostNews news;

  @override
  _NewsArticleExpandedState createState() => _NewsArticleExpandedState();
}

class _NewsArticleExpandedState extends State<NewsArticleExpanded> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
