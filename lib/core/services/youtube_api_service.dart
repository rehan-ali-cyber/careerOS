import 'dart:convert';
import 'package:http/http.dart' as http;

/**
 * YoutubeApiService: The bridge to Google's Data API.
 * Fetches playlist metadata and video lists for The Scholar Stream.
 */
class YoutubeApiService {
  static const String _apiKey = "AIzaSyCKI0uhM86QrNXtOr42yiHzdETj1vkuc5U";

  /// Extracts the Playlist ID from a standard YouTube URL.
  static String? extractPlaylistId(String url) {
    final regExp = RegExp(r"list=([a-zA-Z0-9_-]+)");
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Fetches all videos within a given playlist.
  static Future<List<Map<String, String>>> fetchPlaylistVideos(String playlistId) async {
    final url = Uri.parse(
      "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=$playlistId&key=$_apiKey"
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['items'];

        return items.map<Map<String, String>>((item) {
          final snippet = item['snippet'];
          return {
            'id': snippet['resourceId']['videoId'] as String,
            'title': snippet['title'] as String,
            'thumbnail': snippet['thumbnails']['medium']['url'] as String,
          };
        }).toList();
      } else {
        throw Exception("Sovereign Engine: API Error ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Sovereign Engine: Network Failure");
    }
  }
}
