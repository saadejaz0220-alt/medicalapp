// data/models/media_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MediaItem {
  final String id;
  final String title;
  final String duration;
  final String thumbnailUrl;
  final String url;
  final String? youtubeId;
  final String uploadType;
  final String format;
  final String fromSession;
  final String fromSessionId;
  final int progress;

  MediaItem({
    required this.id,
    required this.title,
    required this.duration,
    required this.thumbnailUrl,
    required this.url,
    this.youtubeId,
    required this.uploadType,
    required this.format,
    required this.fromSession,
    required this.fromSessionId,
    this.progress = 0,
  });

  bool get isYoutube => youtubeId != null;

  factory MediaItem.fromFirestore(Map<String, dynamic> data, String id) {
    final String url = data['url'] ?? '';
    final String type = data['uploadType'] ?? 'Audio';
    String thumb = '';
    String? yid;

    // Extract YouTube ID if applicable
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      final regExp = RegExp(
          r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*');
      final match = regExp.firstMatch(url);
      yid = (match != null && match.group(7)!.length == 11)
          ? match.group(7)
          : null;
      
      if (yid != null) {
        thumb = 'https://img.youtube.com/vi/$yid/mqdefault.jpg';
      }
    }

    // Parse length: "0:14:44.633000" -> "14:44"
    String lengthStr = data['length'] ?? '0:00';
    if (lengthStr.contains('.')) {
      lengthStr = lengthStr.split('.').first;
    }
    if (lengthStr.startsWith('0:')) {
      lengthStr = lengthStr.substring(2);
    }

    return MediaItem(
      id: id,
      title: data['title'] ?? 'Untitled',
      duration: lengthStr,
      thumbnailUrl: thumb,
      url: url,
      youtubeId: yid,
      uploadType: type,
      format: data['format'] ?? '',
      fromSession: data['fromSession'] ?? 'Unknown Session',
      fromSessionId: data['fromSessionId'] ?? '',
      progress: data['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'thumbnailUrl': thumbnailUrl,
      'url': url,
      'youtubeId': youtubeId,
      'uploadType': uploadType,
      'format': format,
      'fromSession': fromSession,
      'fromSessionId': fromSessionId,
      'progress': progress,
    };
  }

  MediaItem copyWith({
    String? id,
    String? title,
    String? duration,
    String? thumbnailUrl,
    String? url,
    String? youtubeId,
    String? uploadType,
    String? format,
    String? fromSession,
    String? fromSessionId,
    int? progress,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      url: url ?? this.url,
      youtubeId: youtubeId ?? this.youtubeId,
      uploadType: uploadType ?? this.uploadType,
      format: format ?? this.format,
      fromSession: fromSession ?? this.fromSession,
      fromSessionId: fromSessionId ?? this.fromSessionId,
      progress: progress ?? this.progress,
    );
  }
}

