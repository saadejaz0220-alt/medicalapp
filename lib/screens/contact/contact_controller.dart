import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class ContactController extends GetxController {
  final String phoneNumber = '+14242741550';
  final String email = 'hello@infinitywellnessmd.com';

  final RxString patientName = 'Patient'.obs;
  final RxString patientEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromGlobalState();
    _fetchPatientDetails(); 
  }

  void _loadFromGlobalState() {
    patientName.value = loggedInUserData?['name'] ?? 'Patient';
    patientEmail.value = loggedInUserData?['email'] ?? '';
  }

  Future<void> _fetchPatientDetails() async {
    // Already loaded from global state, but can refresh if needed
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('Patients').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          updateLoggedInUserData(data);
          _loadFromGlobalState();
        }
      }
    } catch (e) {
      print('Error fetching patient details for contact: $e');
    }
  }

  Future<void> launchSMS() async {
    final Uri smsUri = Uri.parse('sms:$phoneNumber');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      Get.snackbar(
        'Notice', 
        'Could not open SMS app directly. Please text $phoneNumber',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> launchEmail() async {
    final String subject = 'Support Request from Patient App';
    final String body = 'Hello,\n\nI would like to ask about...\n\nBest regards,\n${patientName.value}';
    
    // Construct the mailto URI manually to ensure correct percent-encoding (%20 for spaces)
    // using Uri.encodeComponent to handle special characters correctly.
    final String url = 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    final Uri emailUri = Uri.parse(url);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Notice', 
        'Could not open email app. Please email $email',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}