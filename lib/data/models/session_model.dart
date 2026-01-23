class Session {
  final int id;
  final String title;
  final String date;
  final String status;
  int progress;
  final int duration;
  final String? type;
  final String? videoUrl;
  final String? thumbnailUrl;

  Session({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    this.progress = 0,
    required this.duration,
    this.type,
    this.videoUrl,
    this.thumbnailUrl,
  });
}