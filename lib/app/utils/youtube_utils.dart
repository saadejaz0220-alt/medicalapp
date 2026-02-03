import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeUtils {
  /// Extracts the 11-character video ID from various YouTube URL formats.
  /// Returns null if no valid ID is found.
  static String? convertUrlToId(String url) {
    if (url.isEmpty) return null;
    
    // Use the built-in utility from youtube_player_flutter first
    String? id = YoutubePlayer.convertUrlToId(url);
    if (id != null && id.length == 11) return id;

    // Fallback regex for formats like shorts or others that might not be handled
    final regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?)|(shorts\/))\??v?=?([^#&?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 8) {
      final potentialId = match.group(8);
      if (potentialId != null && potentialId.length == 11) {
        return potentialId;
      }
    }

    return null;
  }
}
