import 'package:get/get.dart';
import '../../widgets/bottom_nav/Navigation_controller.dart';
import '../../screens/home/home_controller.dart';
import '../../screens/media/media_controller.dart';
import '../../screens/calendar/calendar_controller.dart';
import '../../screens/account/account_controller.dart';
import '../../screens/account/edit_profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavController());
    Get.put(HomeController());
    Get.put(MediaController());
    Get.put(CalendarController());
    Get.put(AccountController());
    Get.put(EditProfileController());
  }
}
