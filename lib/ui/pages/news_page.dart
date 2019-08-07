import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/news/article_manager.dart';
import 'package:log_ride/data/news/news_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/widgets/news/news_article.dart';
import 'package:log_ride/widgets/shared/spinning_iconbutton.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  final WebFetcher wf;
  final BaseDB db;
  final Function(bool hasNews) newsNotifier;

  const NewsPage({Key key, this.wf, this.db, this.newsNotifier})
      : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final ScrollController _scrollController = ScrollController();
  static ArticleManager manager;

  List<BluehostNews> news;

  bool hasFirebase = false;
  bool hasBluehost = false;
  bool hasSentNotification = false;
  bool refreshing = false;

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

  Future<void> _refereshNews() async {
    setState(() => refreshing = true);
    List<BluehostNews> newNews = await widget.wf.getNews(true);

    setState(() {
      refreshing = false;
      news = newNews;
    });
  }

  List<BluehostNews> buildDisplayList(BuildContext context) {
    List<BluehostNews> displayList = <BluehostNews>[];
    bool filter = PrefService.getBool(
            preferencesKeyMap[PREFERENCE_KEYS.SHOW_MY_PARKS_NEWS]) ??
        true;

    List<int> myParksIDs = Provider.of<ParksManager>(context).userParkIDs;

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
    if (widget.newsNotifier != null && !hasSentNotification) {
      widget.newsNotifier(!manager.getData(news.first.newsID).hasRead);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BluehostNews> displayList;
    if (hasBluehost) displayList = buildDisplayList(context);

    return Provider<ArticleManager>.value(
      value: manager,
      child: Scaffold(
        appBar: AppBar(
          title: PadlessPageHeader(
            text: "NEWS",
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SpinningIconButton(
                icon: Icon(FontAwesomeIcons.sync),
                spinState: refreshing
                    ? SpinningIconButtonState.SPINNING
                    : SpinningIconButtonState.STOPPED,
                onTap: () {
                  _refereshNews();
                },
              ),
            )
          ],
        ),
        body: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: RefreshIndicator(
              onRefresh: (hasFirebase && hasBluehost)
                  ? () => _refereshNews()
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
