import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';

class PayPalService {
  final String baseUrl;

  PayPalService({String? baseUrl})
    : baseUrl = baseUrl ?? '${Urls.appApiBaseUrl}/api';

  /// Create PayPal order
  /// This is the ONLY API call you need to make!
  /// Backend handles everything else automatically after user approves
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required double amount,
  }) async {
    try {
      AppUtils.log(
        'PayPal: Creating order for userId: $userId, amount: \$$amount',
      );

      // Attach JWT as Bearer token as required by protected endpoints.
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      final jwt = Preferences.authToken;
      if (jwt != null && jwt.isNotEmpty) {
        final bearer = jwt.bearer;
        if (bearer != null && bearer.isNotEmpty) {
          headers['Authorization'] = bearer;
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/paypal/create-order'),
        headers: headers,
        body: jsonEncode({
          'userId': userId,
          'amount': amount.toStringAsFixed(2),
        }),
      );

      AppUtils.log('PayPal: Response status: ${response.statusCode}');
      AppUtils.log('PayPal: Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {
          'success': true,
          'orderId': data['data']['orderId'],
          'approvalUrl': data['data']['approvalUrl'],
          'amount': data['data']['amount'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      AppUtils.log('PayPal Error: ${e.toString()}');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
