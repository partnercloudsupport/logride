import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/news/news_structures.dart';
import 'package:log_ride/data/news/public_key.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:simple_rsa/simple_rsa.dart';

class ArticleManager {
  BaseDB db;
  Map<int, FirebaseNews> userData;

  ArticleManager({this.db});

  Future<void> init() async {
    userData = await getArticles();
    return;
  }

  Future<bool> likeArticle(
    BluehostNews article,
  ) async {
    // Like it first client-side
    article.numberOfLikes++;

    // Send "like" to bluehost
    String payload = '{"newsID": ${article.newsID}';
    String signedString = await signString(payload, PRIVATE_KEY);

    Map body = {"payload": payload, "signature": signedString};

    http.Response request = await http.post(
        "http://www.beingpositioned.com/theparksman/LogRide/$VERSION_URL/newsfeedLikeArticle.php",
        body: jsonEncode(body));

    // Store "like" in firebase
    db.setEntryAtPath(
        path: DatabasePath.USER_PERSONAL_NEWS,
        key: article.newsID.toString() + "/hasLiked",
        payload: true);

    // Update our local data
    FirebaseNews local = getData(article.newsID);
    local.hasLiked = true;

    return (request.statusCode == 200);
  }

  /// Safely gets the user's data. If we don't have data for that article before
  /// for that user, we create the data locally.
  FirebaseNews getData(int articleID) {
    if (userData.keys.contains(articleID)) return userData[articleID];
    print("We don't have data for $articleID");
    userData[articleID] =
        FirebaseNews(newsID: articleID, hasRead: false, hasLiked: false);
    return userData[articleID];
  }

  void viewArticle(BluehostNews article) async {
    getData(article.newsID).hasRead = true;

    db.setEntryAtPath(
        path: DatabasePath.USER_PERSONAL_NEWS,
        key: article.newsID.toString() + "/hasRead",
        payload: true);
  }

  Future<Map<int, FirebaseNews>> getArticles() async {
    dynamic result =
        await db.getEntryAtPath(path: DatabasePath.USER_PERSONAL_NEWS, key: "");

    if (result == null) return {};

    Map<int, FirebaseNews> articles;

    try {
      // Much like with the other Firebase thing, somehow/sometimes LogRide decides
      // that there's a bunch of null values in the database. When this happens, it gives
      // us a list instead of the map we want. We need to try/catch this, and
      // when the problem occurs, we just handle it like a list (with possible
      // nulls) instead

      Map<String, dynamic> formatted = Map.from(result);

      articles = Map<int, FirebaseNews>();
      formatted.forEach((i, d) {
        articles[num.parse(i)] =
            FirebaseNews.fromJsonWithID(num.parse(i), Map.from(d));
      });
    } catch (e) {
      List<dynamic> formatted = List.from(result);

      articles = Map<int, FirebaseNews>();
      formatted.forEach((i) {
        if (i == null) return;
        FirebaseNews news = FirebaseNews.fromJsonWithoutID(Map.from(i));
        articles[news.newsID] = news;
      });
    }

    return articles;
  }

  Future<bool> suggestArticle(NewsSubmission news) async {
    String suggestURL =
        "http://www.beingpositioned.com/theparksman/LogRide/$VERSION_URL/userSubmitNewArticle.php";
    http.Response result =
        await http.post(suggestURL, body: jsonEncode(news.toJson()));
    print("[${result.statusCode}]: ${result.body}");

    if (result.statusCode == 200) return true;
    return false;
  }
}
