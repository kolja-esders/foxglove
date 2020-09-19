import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

import 'package:insta_html_parser/insta_html_parser.dart';

typedef OnPostCallback = void Function(String imageUrl);

class InstagramClient {
  InstagramClient({this.username}) : profileUrl = _getProfileUrl(username);

  final String username;

  final String profileUrl;

  Future<String> getMostRecentPostUrl() async {
    List<String> postsUrls = await InstaParser.postsUrlsFromProfile(profileUrl);
    if (postsUrls.isEmpty) {
      return null;
    }

    final response = await http.get(postsUrls.first);
    if (response.statusCode != 200) {
      return null;
    }

    return _parseImageUrlFromPost(response);
  }

  String _parseImageUrlFromPost(http.Response response) {
    final document = parse(response.body);

    final imageMeta = document.querySelector('meta[property=\'og:image\']');

    return imageMeta?.attributes['content'];
  }

// void pollChanges(String username, OnPostCallback onPost) async {}

  static String _getProfileUrl(String username) => 'https://www.instagram.com/$username';
}
