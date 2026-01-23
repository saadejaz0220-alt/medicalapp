// presentation/widgets/common/session_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../app/routes/app_routes.dart';

class SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final String title = session['title'] ?? 'Untitled Session';
    final String status = session['status'] ?? 'upcoming';
    final int progress = session['progress'] ?? 0;
    final int duration = session['duration'] ?? 10;
    final String date = session['date'] ?? '';
    final int id = session['id'];

    Color statusColor;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'next':
        statusColor = Theme.of(context).colorScheme.primary;
        statusText = 'Next';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Upcoming';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () => Get.toNamed(
      AppRoutes.SESSION_DETAIL,
      parameters: {'id': id.toString()},
    ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', // fallback
                      width: 160,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    ),
                    Container(
                      width: 160,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      size: 48,
                      color: Colors.white70,
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${duration}m',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (date.isNotEmpty)
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Progress badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$progress%',
                            style: TextStyle(
                              color: Colors.white,
                              //color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        // Buttons
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: onTap ?? () =>Get.toNamed(AppRoutes.SESSION_DETAIL, parameters: {'id': id.toString()}),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Open', style: TextStyle(fontSize: 13,color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: onPlay ?? () => Get.snackbar('Play', 'Playing $title'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Play', style: TextStyle(fontSize: 13,color: Colors.white),selectionColor: Colors.white,),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_monthName(date.month)}';
    } catch (e) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}