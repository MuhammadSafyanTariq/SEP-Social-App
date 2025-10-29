import '../../../../../utils/appUtils.dart';

class TokenTransferHelper {
  /// Formats and displays a token transfer success message
  static void showTransferSuccessMessage(
    Map<String, dynamic>? responseData, {
    required int defaultTokenAmount,
    String recipientType = 'recipient', // 'recipient', 'host', etc.
  }) {
    if (responseData != null) {
      final tokensSent = responseData['tokenAmount'] ?? defaultTokenAmount;
      final commission = responseData['commissionTokens'] ?? 0;
      final netTokensToReceiver =
          responseData['netTokensToReceiver'] ?? (tokensSent - commission);
      final dollarValue = responseData['dollarValue'] ?? 0.0;
      final dollarCommission = responseData['dollarCommission'] ?? 0.0;

      String message =
          'Sent $tokensSent tokens (\$${dollarValue.toStringAsFixed(2)})';

      if (commission > 0) {
        message += '\n$recipientType receives $netTokensToReceiver tokens';
        message +=
            '\nCommission: $commission tokens (\$${dollarCommission.toStringAsFixed(2)})';
      } else {
        message += '\n$recipientType receives $netTokensToReceiver tokens';
      }

      AppUtils.toast(message);
    } else {
      AppUtils.toast('Tokens sent successfully!');
    }
  }

  /// Formats token transfer response for logging
  static String formatTransferResponse(Map<String, dynamic>? responseData) {
    if (responseData == null) return 'No response data';

    final tokenAmount = responseData['tokenAmount'] ?? 0;
    final commission = responseData['commissionTokens'] ?? 0;
    final netTokens = responseData['netTokensToReceiver'] ?? 0;
    final dollarValue = responseData['dollarValue'] ?? 0.0;
    final dollarCommission = responseData['dollarCommission'] ?? 0.0;

    return '''
Token Transfer Details:
- Tokens Sent: $tokenAmount
- Commission: $commission tokens (\$${dollarCommission.toStringAsFixed(2)})
- Net Tokens to Receiver: $netTokens
- Total Value: \$${dollarValue.toStringAsFixed(2)}
''';
  }
}
