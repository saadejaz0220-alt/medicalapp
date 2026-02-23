import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class ContactController extends GetxController {
  final String phoneNumber = '+14242741550';
  final RxString patientName = 'Patient'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromGlobalState();
    _fetchPatientDetails(); 
  }

  void _loadFromGlobalState() {
    patientName.value = loggedInUserData?['name'] ?? 'Patient';
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

}