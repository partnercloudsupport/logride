import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/news/article_manager.dart';
import 'package:log_ride/data/news/news_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/ui/submission/submit_article_page.dart';
import 'package:log_ride/widgets/news/news_article.dart';
import 'package:log_ride/widgets/shared/spinning_iconbutton.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  final WebFetcher wf;
  final BaseDB db;
  final ParksManager pm;
  final Function(bool hasNews) newsNotifier;

  const NewsPage({Key key, this.wf, this.db, this.newsNotifier, this.pm})
      : super(key: key);

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends State<NewsPage> {
  final ScrollController _scrollController = ScrollController();
  static ArticleManager manager;

  List<BluehostNews> news;

  bool hasFirebase = false;
  bool hasBluehost = false;
  bool hasSentNotification = false;
  bool refreshing = false;

  double scrollExtent = 0.0;

  @override
  void initState() {
    manager = ArticleManager(db: widget.db);
    manager.init().then((v) {
      setState(() => hasFirebase = true);
      if (hasBluehost) _checkNewNews();
    });
    widget.wf.getNews(true).then((l) {
      setState(() {
        news = l;
        hasBluehost = true;
      });
      if (hasFirebase) _checkNewNews();
    });
    super.initState();
  }

  Future<void> _refreshNews() async {
    setState(() => refreshing = true);
    List<BluehostNews> newNews = await widget.wf.getNews(true);

    setState(() {
      hasBluehost = true;
      refreshing = false;
      news = newNews;
    });
  }

  List<BluehostNews> _buildDisplayList() {
    List<BluehostNews> displayList = <BluehostNews>[];
    bool filter = PrefService.getBool(
            preferencesKeyMap[PREFERENCE_KEYS.SHOW_MY_PARKS_NEWS]) ??
        true;

    List<int> myParksIDs = widget.pm.userParkIDs;

    for (BluehostNews n in news) {
      if (!filter)
        displayList.add(n);
      else {
        if (myParksIDs.contains(n.parkId)) displayList.add(n);
      }
    }

    return displayList;
  }

  void _checkNewNews() {
    List<BluehostNews> ourNews = _buildDisplayList();
    if (widget.newsNotifier != null && !hasSentNotification) {
      print("First news: ${ourNews.first.newsID}");
      print("First read? ${manager.getData(ourNews.first.newsID)}");
      print("First poster: ${ourNews.first.submittedBy}");
      widget.newsNotifier(!manager.getData(ourNews.first.newsID).hasRead);
    }
  }

  void jumpTap() {
    double position = _scrollController.offset;
    double target = 0.0;
    if (position == target) {
      target = scrollExtent;
    } else {
      scrollExtent = position;
    }

    _scrollController.animateTo(target,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _handleSubmission(BuildContext context) async {
    dynamic result = await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return SubmitArticlePage();
        });

    if (result == null) return;

    NewsSubmission article = result as NewsSubmission;

    // Add in our username
    LogRideUser user = Provider.of<LogRideUser>(context);
    article.username = user.username;

    // We've got a valid submission - send it to the server.
    bool success = await manager.suggestArticle(article);
    if (success) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StyledDialog(
              title: "Article Submitted",
              body: "The article you have submitted is now up for review",
              actionText: "OK",
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StyledDialog(
              title: "Submission Error",
              body:
                  "We were unable to submit your article - please try again later",
              actionText: "OK",
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BluehostNews> displayList;
    if (hasBluehost) displayList = _buildDisplayList();

    return Provider<ArticleManager>.value(
      value: manager,
      child: Scaffold(
        appBar: AppBar(
          title: PadlessPageHeader(
            text: "NEWS",
          ),
          actions: <Widget>[
            // FontAwesomeIcons are slightly misaligned at normal sizes
            // This padding is to fix that.
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: IconButton(
                icon: Icon(FontAwesomeIcons.edit),
                onPressed: () => _handleSubmission(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SpinningIconButton(
                icon: Icon(FontAwesomeIcons.sync),
                spinState: refreshing
                    ? SpinningIconButtonState.SPINNING
                    : SpinningIconButtonState.STOPPED,
                onTap: () {
                  _refreshNews();
                },
              ),
            )
          ],
        ),
        body: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: RefreshIndicator(
              onRefresh: (hasFirebase && hasBluehost)
                  ? () => _refreshNews()
                  : () {
                      return;
                    },
              child: (hasFirebase && hasBluehost)
                  ? ListView.builder(
                      key: ValueKey(news.hashCode),
                      controller: _scrollController,
                      itemCount: displayList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return NewsArticleEntry(
                          news: displayList[index],
                          userData: manager.getData(displayList[index].newsID),
                        );
                      })
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            )),
      ),
    );
  }
}
