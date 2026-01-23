
// data/models/media_item.dart
class MediaItem {
  final String id;
  final String title;
  final String tag; // e.g. Breathing, Gratitude, Sleep
  final bool unlocked;
  final int duration;
  final String thumbnailUrl;
  final String youtubeId;
  final int fromSession;
  final DateTime? unlockDate;

  MediaItem({
    required this.id,
    required this.title,
    required this.tag,
    required this.unlocked,
    required this.duration,
    required this.thumbnailUrl,
    required this.youtubeId,
    required this.fromSession,
    this.unlockDate,
  });

  List<MediaItem>? operator [](String other) {}
}
