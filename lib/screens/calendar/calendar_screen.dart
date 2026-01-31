// presentation/screens/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


import 'calendar_controller.dart';
import '../../../core/theme/app_colors.dart'; // your color palette

class CalendarScreen extends GetView<CalendarController> {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Recovery Calendar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro text
            const Text(
              'Green dots = days you completed a session',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => controller.changeMonth(-1),
                ),
                Obx(
                      () => Text(
                    controller.monthYearDisplay,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => controller.changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Day names
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map(
                    (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Calendar grid
            Obx(() => _buildCalendarGrid(context)),

            const SizedBox(height: 32),

            // Streak summary card
            Card(
              elevation: 0,
              color: Theme.of(context).cardColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Obx(
                          () => Text(
                        controller.streakText.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keep going — every completed session counts!',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(
      controller.currentYear.value,
      controller.currentMonth.value,
      1,
    );
    final weekdayOfFirst = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final daysInMonth = DateTime(
      controller.currentYear.value,
      controller.currentMonth.value + 1,
      0,
    ).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: weekdayOfFirst + daysInMonth,
      itemBuilder: (context, index) {
        if (index < weekdayOfFirst) {
          return const SizedBox.shrink(); // empty cells before month start
        }

        final day = index - weekdayOfFirst + 1;
        final dateStr = '${controller.currentYear.value}-'
            '${controller.currentMonth.value.toString().padLeft(2, '0')}-'
            '${day.toString().padLeft(2, '0')}';

        final isCompleted = controller.isCompleted(dateStr);
        final isToday = controller.isToday(day);

        return GestureDetector(
          onTap: () {
            if (isCompleted) {
              Get.snackbar(
                'Completed Day',
                'Session completed on ${DateFormat('MMM d, yyyy').format(DateTime.parse(dateStr))}',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.12)
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              )
                  : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      );
      }
}