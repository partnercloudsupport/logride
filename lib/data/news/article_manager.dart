import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/news/news_structures.dart';
import 'package:log_ride/data/news/public_key.dart';
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
    // Send "like" to bluehost
    String payload = '{"newsID": ${article.newsID}';
    String signedString = await signString(payload, PRIVATE_KEY);

    Map body = {"payload": payload, "signature": signedString};

    http.Response request = await http.post(
        "http://www.beingpositioned.com/theparksman/LogRide/Version1.2.2/newsfeedLikeArticle.php",
        body: jsonEncode(body));

    // Store "like" in firebase
    db.setEntryAtPath(
        path: DatabasePath.USER_PERSONAL_NEWS,
        key: article.newsID.toString() + "/hasLiked",
        payload: true);

    // Update our local data
    FirebaseNews local = getData(article.newsID);
    local.hasLiked = true;

    article.numberOfLikes++;

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

    Map<String, dynamic> formatted = Map.from(result);

    Map<int, FirebaseNews> articles = Map<int, FirebaseNews>();
    formatted.forEach((i, d) {
      articles[num.parse(i)] = FirebaseNews.fromJson(num.parse(i), Map.from(d));
    });

    return articles;
  }
}
