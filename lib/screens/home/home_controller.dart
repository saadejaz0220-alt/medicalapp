import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/routes/app_routes.dart';
import '../../data/dummy_data/dummy_data.dart';

class HomeController extends GetxController {
  var selectedTab = 'next'.obs;
  var streak = 7.obs;
  var username = 'Amna khan'.obs;
  var completedSessions = <Map<String, dynamic>>[].obs;
  var currentJourney = 'Mind–Body \nRenewal Journey'.obs;
  var currentSession = <String, dynamic>{}.obs;



  final sessions = DummyData.sessions.obs;

  var galleryImages = <String>[].obs;
  void addImage() {
    galleryImages.add("https://via.placeholder.com/150");
    galleryImages.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    // load from storage if needed
    username.value = GetStorage().read('username') ?? 'AMINA KHAN';

  }

  List<Map<String, dynamic>> get filteredSessions {
    switch (selectedTab.value) {
      case 'next':
        return sessions.where((s) => s['status'] == 'next').toList();
      case 'upcoming':
        return sessions.where((s) => s['status'] == 'upcoming').toList();
      case 'past':
        return sessions.where((s) => s['status'] == 'completed').toList();
      default:
        return sessions;
    }
  }

  void changeTab(String tab) => selectedTab.value = tab;

  void openSession(int id) {
    Get.toNamed('${AppRoutes.SESSION_DETAIL}?id=$id');
  }
}