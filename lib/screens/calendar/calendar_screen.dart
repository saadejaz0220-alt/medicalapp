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
    // Refresh activity data whenever the screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchActivityData();
    });

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

            // Session History Section
            Obx(() {
              final activities = controller.getActivitiesForSelectedDate();
              final selectedDateDisplay = DateFormat('MMMM d, yyyy').format(
                DateTime.parse(controller.selectedDate.value.isEmpty 
                    ? DateFormat('yyyy-MM-dd').format(DateTime.now()) 
                    : controller.selectedDate.value)
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sessions for $selectedDateDisplay',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (activities.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'No sessions completed on this day.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ...activities.map((activity) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: activity['type'] == 'clinical' 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.blue.withOpacity(0.1),
                          child: Icon(
                            activity['type'] == 'clinical' 
                                ? Icons.health_and_safety_rounded 
                                : Icons.play_circle_fill_rounded,
                            color: activity['type'] == 'clinical' 
                                ? Colors.green 
                                : Colors.blue,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          activity['title'],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          activity['type'] == 'clinical' ? 'Clinical Session' : 'Media Workout',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ),
                    )),
                ],
              );
            }),

            const SizedBox(height: 32),

            // Streak summary card
            Card(
              elevation: 0,
              borderOnForeground: false,
              color: Theme.of(context).cardColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
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
        final isSelected = controller.selectedDate.value == dateStr;
        final hasClinical = controller.hasClinicalSession(dateStr);

        return GestureDetector(
          onTap: () => controller.onDateSelected(dateStr),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : (isCompleted ? AppColors.success.withOpacity(0.08) : null),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : (hasClinical 
                        ? AppColors.success 
                        : (isToday ? Theme.of(context).colorScheme.primary.withOpacity(0.4) : Colors.transparent)),
                width: (isSelected || hasClinical) ? 2.0 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                    color: isSelected || isToday
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
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