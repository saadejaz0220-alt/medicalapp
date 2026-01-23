import 'package:medicalapp/screens/account/edit_profile_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

abstract class AppRoutes {
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const HOME = '/home';
  static const String SESSION_DETAIL = '/session-detail/:id';
  static const ROOT = '/root';
  static const SESSION_PLAYER = '/session-player';
  static const CALENDAR = '/calendar';
  static const MEDIA = '/media';
  static const ACCOUNT = '/account';
  static const CONTACT = '/contact';
  static const EditProfileController = '/edit-profile';
  static const YoutubePlayer = '/youtube-player';
}

