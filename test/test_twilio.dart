import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Standalone script to test Twilio credentials.
/// Run this with: dart test/test_twilio.dart
void main() async {
  // Update these to test different credentials
  final String accountSid = 'YOUR_TWILIO_ACCOUNT_SID'.trim();
  final String authToken = 'YOUR_TWILIO_AUTH_TOKEN'.trim(); 
  final String fromNumber = 'YOUR_TWILIO_FROM_NUMBER'.trim();
  final String toNumber = '+923168636206'; // Change this to your test number for a real test

  print('--- Twilio Diagnostic Tool ---');
  print('Account SID: ${accountSid.substring(0, 5)}... (Length: ${accountSid.length})');
  print('Auth Token: ${authToken.substring(0, 3)}... (Length: ${authToken.length})');
  print('URL: https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

  if (accountSid.isEmpty || authToken.isEmpty) {
    print('ERROR: Account SID or Auth Token is empty.');
    exit(1);
  }

  final url = Uri.https('api.twilio.com', '/2010-04-01/Accounts/$accountSid/Messages.json');
  final authString = base64Encode(utf8.encode('$accountSid:$authToken'));

  try {
    print('Sending request...');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $authString',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': toNumber,
        'From': fromNumber,
        'Body': 'Twilio Diagnostic Test Message',
      },
    );

    print('\nResponse Status Code: ${response.statusCode}');
    print('Response Body:');
    print(response.body);

    if (response.statusCode == 201) {
      print('\nSUCCESS: Credentials are valid and SMS was queued.');
    } else if (response.statusCode == 401) {
      print('\nFAILURE: 401 Unauthorized.');
      print('This means the Account SID and Auth Token do not match.');
      print('1. Ensure you are using the AUTH TOKEN, not an API Key Secret (unless using API Key SID as username).');
      print('2. Ensure there are no leading/trailing spaces.');
      print('3. Check if the Account SID in the URL matches the one used for Auth.');
    } else {
      print('\nFAILURE: Received status code ${response.statusCode}');
    }
  } catch (e) {
    print('EXCEPTION: $e');
  }
}
