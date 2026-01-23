import 'package:get/get.dart';

class NavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final List<String> screens = [
    '/home',
    '/calendar',
    '/media',
    '/contact',
    '/account',
  ];

  void changeIndex(int index) {
    if (index == currentIndex.value) return;
    Get.offAllNamed(screens[index]);
    currentIndex.value = index;
  }
}