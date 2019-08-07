import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/news/article_manager.dart';
import 'package:log_ride/data/news/news_structures.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/widgets/news/news_article.dart';
import 'package:log_ride/widgets/shared/spinning_iconbutton.dart';
import 'package:log_ride/widgets/stats/misc_headers.dart';
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

  void _checkNewNews() {
    if (widget.newsNotifier != null && !hasSentNotification) {
      widget.newsNotifier(!manager.getData(news.first.newsID).hasRead);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onRefresh:
                  (hasFirebase && hasBluehost) ? () => _refereshNews() : null,
              child: (hasFirebase && hasBluehost)
                  ? ListView.builder(
                      key: ValueKey(news.hashCode),
                      controller: _scrollController,
                      itemCount: news.length,
                      itemBuilder: (BuildContext context, int index) {
                        return NewsArticleEntry(
                          news: news[index],
                          userData: manager.getData(news[index].newsID),
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
