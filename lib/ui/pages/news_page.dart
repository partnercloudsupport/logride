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
  List<BluehostNews> displayList;

  bool hasFirebase = false;
  bool hasBluehost = false;
  bool hasSentNotification = false;
  bool refreshing = false;

  double scrollExtent = 0.0;

  @override
  void initState() {
    manager = ArticleManager(db: widget.db);
    manager.init().then((v) {
      if (hasBluehost) {
        displayList = _buildDisplayList();
        _checkNewNews();
      }
      setState(() => hasFirebase = true);
    });
    widget.wf.getNews(true).then((l) {
      news = l;
      if (hasFirebase) {
        displayList = _buildDisplayList();
        _checkNewNews();
      }
      setState(() {
        hasBluehost = true;
      });
    });
    super.initState();
  }

  Future<void> _refreshNews() async {
    setState(() => refreshing = true);
    List<BluehostNews> newNews = await widget.wf.getNews(true);

    displayList = _buildDisplayList();

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
    if (widget.newsNotifier != null &&
        !hasSentNotification &&
        displayList.isNotEmpty) {
      print("First news: ${displayList.first.newsID}");
      print("First read? ${manager.getData(displayList.first.newsID)}");
      print("First poster: ${displayList.first.submittedBy}");
      widget.newsNotifier(!manager.getData(displayList.first.newsID).hasRead);
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
    Widget content = Container();
    if (hasFirebase && hasBluehost) {
      int value;
      if (displayList.isEmpty) {
        // User has no news, thanks to not having parks. We need to let them know
        // their options to solve this problem.
        value = "newsPageEmpty".hashCode;
        content = Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            child: Text(
              "There's no news to display - add more parks or turn off the 'My Parks' filter in 'News Settings' to view more",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title,
            ),
          ),
        );
      } else {
        value = news.hashCode;
        content = ListView.builder(
            controller: _scrollController,
            itemCount: displayList.length,
            itemBuilder: (BuildContext context, int index) {
              return NewsArticleEntry(
                news: displayList[index],
                userData: manager.getData(displayList[index].newsID),
              );
            });
      }
      content = RefreshIndicator(
          key: ValueKey(value),
          onRefresh: (hasFirebase && hasBluehost)
              ? () => _refreshNews()
              : () {
                  return;
                },
          child: content);
    } else {
      content = Center(
        child: CircularProgressIndicator(),
      );
    }

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
            duration: Duration(milliseconds: 250), child: content),
      ),
    );
  }
}
