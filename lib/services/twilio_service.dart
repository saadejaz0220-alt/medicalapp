import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TwilioService {
  final String _accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
  final String _authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
  final String _fromNumber = dotenv.env['TWILIO_FROM_NUMBER'] ?? '';

  Future<bool> sendSms(String to, String body) async {
    final client = http.Client();
    final url = Uri.https('api.twilio.com', '/2010-04-01/Accounts/$_accountSid/Messages.json');
    
    String formattedTo = to.trim();
    if (!formattedTo.startsWith('+')) {
      formattedTo = '+$formattedTo';
    }

    // Safety check for empty credentials
    if (_accountSid.isEmpty || _authToken.isEmpty) {
      debugPrint('Twilio Error: AccountSid or AuthToken is empty');
      return false;
    }

    try {
      final authString = base64Encode(utf8.encode('$_accountSid:$_authToken'));
      
      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Basic $authString',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': formattedTo,
          'From': _fromNumber,
          'Body': body,
        },
      );

      if (response.statusCode == 201) {
        debugPrint('Twilio Success: Code sent to $formattedTo');
        return true;
      } else {
        // Detailed log of exactly what Twilio says is wrong
        debugPrint('Twilio Error (${response.statusCode}):');
        debugPrint('Body: ${response.body}');
        
        // Try to get Twilio Request ID for support
        final requestId = response.headers['x-twilio-request-id'] ?? 
                          response.headers['twilio-request-id'] ?? 
                          response.headers['x-request-id'] ?? 
                          'None Found';
        debugPrint('Twilio Request ID: $requestId');
        
        if (response.statusCode == 401) {
          debugPrint('--- AUTHENTICATION TROUBLESHOOTING ---');
          debugPrint('1. Account SID: ${_accountSid.substring(0, 5)}... (Length: ${_accountSid.length})');
          debugPrint('2. Auth Token: ${_authToken.substring(0, 3)}... (Length: ${_authToken.length})');
          debugPrint('3. URL: $url');
          debugPrint('Check if your Account SID and Auth Token match EXACTLY what is in the Twilio Console.');
          debugPrint('If using an API Key, you must use the API Key SID as the username and API Secret as password, but the URL must still have the Account SID.');
          debugPrint('---------------------------------------');
        }
        return false;
      }
    } catch (e) {
      debugPrint('Twilio Exception: $e');
      return false;
    } finally {
      client.close();
    }
  }
}
