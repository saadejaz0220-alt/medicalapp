import 'package:get/get.dart';
import 'package:medicalapp/screens/account/edit_profile_screen.dart';

import '../../screens/account/account_screen.dart';
import '../../screens/account/edit_profile_controller.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup-screen.dart';
import '../../screens/calendar/calendar_screen.dart';
import '../../screens/contact/contact_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/media/media_library_screen.dart';
import '../../screens/media/youtube_player_screen.dart';
import '../../screens/roots/root_screen.dart';
import '../../screens/session_detail/session_detail_screen.dart';
import '../../screens/session_detail/session_player.dart';
import 'app_routes.dart';  // import all screens + controllers

class AppPages {
  static final routes = [
    GetPage(
      name: '/',
      page: () =>  RootScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignupScreen(),
    ),

    GetPage(name: AppRoutes.HOME, page: () => HomeScreen()),
    GetPage(
      name: AppRoutes.SESSION_DETAIL,
      page: () => SessionDetailScreen(),
    ),
    GetPage(
        name: AppRoutes.CALENDAR,
        page: () => CalendarScreen()
    ),
    GetPage(
        name: AppRoutes.MEDIA,
        page: () => MediaLibraryScreen()
    ),
    GetPage(
      name: AppRoutes.CONTACT,
      page: () => const ContactScreen(),
    ),
    GetPage(
      name: AppRoutes.ACCOUNT,
      page: () => const AccountScreen(),
    ),
    GetPage(
      name: AppRoutes.SESSION_PLAYER,
      page: () => const SessionPlayerScreen(),
    ),
    GetPage(name:AppRoutes.EditProfileController, page: () => EditProfileScreen()),
    GetPage(name: AppRoutes.YoutubePlayer, page: () => YoutubePlayerScreen()),


    // ... other pages
  ];
}