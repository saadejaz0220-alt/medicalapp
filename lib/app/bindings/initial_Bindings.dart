import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:medicalapp/screens/account/account_controller.dart';

import '../../screens/account/edit_profile_controller.dart';
import '../../screens/auth/auth_controller.dart';
import '../../screens/calendar/calendar_controller.dart';
import '../../screens/home/home_controller.dart';
import '../../screens/media/media_controller.dart';
import '../../screens/session_detail/session_controller.dart';
import '../../widgets/bottom_nav/Navigation_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(NavController(), permanent: true);
    //Get.lazyPut(() => AuthController());
   // Get.lazyPut(() => NavController());
    Get.put(HomeController());
    Get.put(AccountController());
    Get.put(SessionDetailController());
    Get.put(MediaController());
    Get.put(CalendarController());
    Get.put(EditProfileController());

    // ... other permanent controllers
  }
}