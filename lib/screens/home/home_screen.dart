import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import '../../app/routes/app_routes.dart';

import '../../data/models/media_item.dart';
import '../../widgets/common/embedded_media_player.dart';
import '../../widgets/common/image_gallary_grid.dart';
import '../../widgets/common/journey_progress_card.dart';
import '../../widgets/common/mediacard.dart';
import '../../widgets/common/motivational_quote_card.dart';
import '../../widgets/common/progress_card.dart';
import '../../widgets/common/recovery_journey_card.dart';
import '../../widgets/common/session_card.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.ACCOUNT),
          ),
        ],
      ),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Greeting + Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Good Day", style: Get.textTheme.bodySmall),
                  Text(
                    controller.username.value,
                    style: Get.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Streak", style: Get.textTheme.bodySmall),
                  Text(
                    "${controller.streak.value}",
                    style: TextStyle(
                      fontSize: 22,
                      color: Get.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const SimpleProgressCard(),
          const SizedBox(height: 16),
          const RecoveryQuoteCard(),




          const SizedBox(height: 16),
          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Next', 'Upcoming', 'Past', 'All']
                  .map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t),
                  selected: controller.selectedTab.value ==
                      t.toLowerCase(),
                  onSelected: (_) =>
                      controller.changeTab(t.toLowerCase()),
                ),
              ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),
          // Tab Content
          Obx(() {
            final tab = controller.selectedTab.value;
            List<MediaItem> displayList = [];
            String title = "";

            if (tab == 'next') {
              displayList = controller.postSessionMedias;
              title = "Post-Session Workouts";
            } else if (tab == 'upcoming') {
              displayList = controller.upcomingMedias;
              title = "Upcoming Sessions";
            } else if (tab == 'past') {
              displayList = controller.pastMedias;
              title = "Past Sessions";
            } else if (tab == 'all') {
              displayList = controller.allMedias;
              title = "All Sessions";
            }

            if (displayList.isEmpty) {
              String emptyMessage = "";
              if (tab == 'next') {
                emptyMessage = "No post-session workout available yet.";
              } else if (tab == 'upcoming') {
                emptyMessage = "No upcoming sessions on this journey.";
              } else if (tab == 'past') {
                emptyMessage = "No past sessions to show.";
              } else if (tab == 'all') {
                emptyMessage = "No sessions found in this journey.";
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      title,
                      style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.history_edu_rounded, size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          emptyMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                    style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ...displayList.map((media) => MediaCard(
                      media: media,
                      tagLabel: tab.capitalizeFirst,
                      onTap: () => controller.playMedia(media),
                      onPlay: () => controller.playMedia(media),
                    )),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),
              ],
            );
          }),


          // const SizedBox(height: 16),
          // const ImageGalleryCard(),
          const SizedBox(height: 16),
          const RecoveryJourneyCard(),
          const SizedBox(height: 16),
          const JourneyProgressCard(),
          const SizedBox(height: 16),
          const CompletedSessionsList(),


        ],
      )),

    );
  }}

