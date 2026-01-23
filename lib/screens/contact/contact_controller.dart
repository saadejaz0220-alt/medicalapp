// presentation/screens/contact/contact_controller.dart
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactController extends GetxController {
  final String phoneNumber = '+14242741550'; // from your original (424) 274-1550
  final String email = 'hello@infinitywellnessmd.com';

  Future<void> launchSMS() async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      // You can prefill message if desired:
      // queryParameters: {'body': 'Hi, I need help with my account...'},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      Get.snackbar('Error', 'Could not open SMS app');
    }
  }

  Future<void> launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Support Request from Patient App',
        'body': 'Hello,\n\nI would like to ask about...\n\nBest regards,\n[Your Name]',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar('Error', 'Could not open email app');
    }
  }
}