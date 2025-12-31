import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sep/utils/appUtils.dart';

class PayPalWebView extends StatefulWidget {
  final String approvalUrl;
  final Function(Map<String, dynamic>) onPaymentSuccess;
  final Function(String) onPaymentError;
  final Function() onCancelled;

  const PayPalWebView({
    Key? key,
    required this.approvalUrl,
    required this.onPaymentSuccess,
    required this.onPaymentError,
    required this.onCancelled,
  }) : super(key: key);

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late WebViewController controller;
  bool isLoading = true;
  bool isProcessing = false;
  bool _hasReceivedResult = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            AppUtils.log('PayPal WebView: Page started - $url');
            setState(() => isLoading = true);

            // Check if payment is being processed (automatic)
            if (url.contains('/api/paypal/process-payment')) {
              setState(() => isProcessing = true);
              AppUtils.log('PayPal: Processing payment automatically...');
            }

            // Handle payment success page - DON'T close yet, wait for data
            if (url.contains('/payment-success') || url.contains('/success')) {
              AppUtils.log(
                'PayPal: Success page detected - waiting for data...',
              );
              // Let the JavaScript message listener handle the actual data
              // Don't set _hasReceivedResult here, wait for the data
            }

            // Handle cancellation
            if (url.contains('/api/paypal/cancel') || url.contains('/cancel')) {
              AppUtils.log('PayPal: Payment cancelled');
              widget.onCancelled();
              Navigator.pop(context);
            }
          },
          onPageFinished: (String url) {
            AppUtils.log('PayPal WebView: Page finished - $url');
            setState(() {
              isLoading = false;
              // Stop showing processing indicator once page loads
              if (url.contains('/api/paypal/process-payment')) {
                isProcessing = false;
              }
            });

            // Setup message listener on payment-related pages
            if (url.contains('/api/paypal/')) {
              _setupMessageListener();
            }
          },
          onWebResourceError: (WebResourceError error) {
            AppUtils.log('PayPal WebView Error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterPayPal',
        onMessageReceived: (JavaScriptMessage message) {
          if (_hasReceivedResult) {
            AppUtils.log('PayPal: Duplicate result ignored');
            return;
          }
          _hasReceivedResult = true;

          try {
            AppUtils.log(
              'PayPal: Message received from backend - ${message.message}',
            );
            final data = jsonDecode(message.message);

            if (data['type'] == 'PAYPAL_SUCCESS') {
              AppUtils.log('PayPal: Payment successful!');
              AppUtils.log('PayPal: Received data structure: $data');
              AppUtils.log('PayPal: Data keys: ${data.keys.toList()}');
              AppUtils.log('PayPal: Full JSON: ${jsonEncode(data)}');

              // Show success toast
              Fluttertoast.showToast(
                msg: "Payment Successful!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );

              AppUtils.log('PayPal: Closing WebView NOW');

              // Close FIRST, then call callback
              Navigator.pop(context);

              // Call callback after closing
              Future.microtask(() {
                AppUtils.log(
                  'PayPal: Calling onPaymentSuccess with data: $data',
                );
                widget.onPaymentSuccess(data);
              });

              AppUtils.log('PayPal: Pop executed');
            } else if (data['type'] == 'PAYPAL_ERROR') {
              AppUtils.log('PayPal: Payment error - ${data['message']}');
              widget.onPaymentError(data['message'] ?? 'Payment failed');
              Future.microtask(() {
                if (mounted) Navigator.of(context).pop();
              });
            }
          } catch (e) {
            AppUtils.log('Error parsing payment result: $e');
            widget.onPaymentError('Failed to process payment response');
            Future.microtask(() {
              if (mounted) Navigator.of(context).pop();
            });
          }
        },
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  Future<void> _setupMessageListener() async {
    if (!mounted || _hasReceivedResult) return;

    try {
      // Inject JavaScript to listen for postMessage from backend
      await controller.runJavaScript('''
        (function() {
          console.log('=== PayPal JS v2.0 - WITH AMOUNT EXTRACTION ===');
          console.log('Setting up postMessage listener...');
          
          // Listen for messages from the backend page
          window.addEventListener('message', function(event) {
            console.log('Received postMessage:', event.data);
            
            if (event.data && typeof event.data === 'object') {
              // Forward the message to Flutter
              if (window.FlutterPayPal) {
                window.FlutterPayPal.postMessage(JSON.stringify(event.data));
              }
            }
          }, false);
          
          console.log('postMessage listener ready');
          
          // Function to check page content
          function checkPageContent() {
            try {
              // Try to get result from page content
              var bodyText = document.body.innerText || document.body.textContent;
              console.log('Checking page content:', bodyText.substring(0, 200));
              
              // Check for success/error text in HTML pages
              var lowerText = bodyText.toLowerCase();
              
              // FIRST: Try to extract JSON data from script tags or data attributes
              var scripts = document.querySelectorAll('script[type="application/json"], script[data-payment-result]');
              for (var script of scripts) {
                try {
                  var scriptData = JSON.parse(script.textContent);
                  console.log('Found data in script tag:', scriptData);
                  if (scriptData.type === 'PAYPAL_SUCCESS' || scriptData.status === true) {
                    if (window.FlutterPayPal) {
                      window.FlutterPayPal.postMessage(JSON.stringify({
                        type: 'PAYPAL_SUCCESS',
                        ...scriptData
                      }));
                    }
                    return true;
                  }
                } catch (e) {}
              }
              
              // Check if body contains JSON response (full page JSON)
              var trimmed = bodyText.trim();
              if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
                try {
                  var data = JSON.parse(trimmed);
                  console.log('Found JSON data in page body:', data);
                  
                  // Check if response already has the type field from backend
                  if (data.type === 'PAYPAL_SUCCESS') {
                    console.log('Payment success detected from JSON!');
                    if (window.FlutterPayPal) {
                      window.FlutterPayPal.postMessage(JSON.stringify(data));
                    }
                    return true;
                  } else if (data.type === 'PAYPAL_ERROR') {
                    console.log('Payment error detected from JSON!');
                    if (window.FlutterPayPal) {
                      window.FlutterPayPal.postMessage(JSON.stringify(data));
                    }
                    return true;
                  }
                  // Fallback for old format
                  else if (data.status === true || data.success === true) {
                    console.log('Payment success detected (legacy format)!');
                    if (window.FlutterPayPal) {
                      window.FlutterPayPal.postMessage(JSON.stringify({
                        type: 'PAYPAL_SUCCESS',
                        ...data
                      }));
                    }
                    return true;
                  } else if (data.status === false || data.error) {
                    console.log('Payment error detected (legacy format)!');
                    if (window.FlutterPayPal) {
                      window.FlutterPayPal.postMessage(JSON.stringify({
                        type: 'PAYPAL_ERROR',
                        message: data.message || data.error || 'Payment failed'
                      }));
                    }
                    return true;
                  }
                } catch (e) {
                  console.log('Error parsing JSON:', e);
                }
              }
              
              // LAST RESORT: Detect from HTML text but try to extract amounts
              if (lowerText.includes('payment successful') || lowerText.includes('topped up successfully')) {
                console.log('Payment success detected from text - extracting amounts...');
                console.log('Full body text:', bodyText.substring(0, 500));
                
                // Try to extract amount and balance from HTML
                var amountMatch = bodyText.match(/Amount:\s*\$?([\d,.]+)/i);
                var balanceMatch = bodyText.match(/(?:New\s+)?Balance:\s*\$?([\d,.]+)/i);
                
                console.log('amountMatch:', amountMatch);
                console.log('balanceMatch:', balanceMatch);
                
                var amount = amountMatch ? parseFloat(amountMatch[1].replace(/,/g, '')) : 0;
                var newBalance = balanceMatch ? parseFloat(balanceMatch[1].replace(/,/g, '')) : 0;
                
                console.log('Extracted values: amount=' + amount + ', balance=' + newBalance);
                
                var paymentData = {
                  type: 'PAYPAL_SUCCESS',
                  message: 'Payment completed successfully',
                  amount: amount,
                  topUpResult: {
                    newWalletBalance: newBalance,
                    amount: amount,
                    isFirstTopUp: false
                  }
                };
                
                console.log('Sending payment data:', JSON.stringify(paymentData));
                
                if (window.FlutterPayPal) {
                  window.FlutterPayPal.postMessage(JSON.stringify(paymentData));
                }
                return true;
              } else if (lowerText.includes('payment failed') || lowerText.includes('payment error')) {
                console.log('Payment error detected from text!');
                if (window.FlutterPayPal) {
                  window.FlutterPayPal.postMessage(JSON.stringify({
                    type: 'PAYPAL_ERROR',
                    message: 'Payment failed'
                  }));
                }
                return true;
              }
              return false;
            } catch (e) {
              console.log('Error parsing page content:', e);
              return false;
            }
          }
          
          // Check immediately
          if (!checkPageContent()) {
            // Check again after 500ms
            setTimeout(function() {
              if (!checkPageContent()) {
                // Check one more time after 1500ms
                setTimeout(checkPageContent, 1000);
              }
            }, 500);
          }
        })();
      ''');

      AppUtils.log('PayPal: Message listener setup complete');

      // Failsafe: After 5 seconds, check one more time manually
      Future.delayed(const Duration(seconds: 5), () async {
        if (!mounted || _hasReceivedResult) return;

        try {
          final content = await controller.runJavaScriptReturningResult(
            'document.body.innerText',
          );
          AppUtils.log('Failsafe check - Page content: $content');

          // Try to parse as JSON or check for success text
          final contentStr = content.toString().replaceAll('"', '');
          final lowerContent = contentStr.toLowerCase();

          // Check for success/error text in HTML pages
          if (lowerContent.contains('payment successful') ||
              lowerContent.contains('topped up successfully')) {
            AppUtils.log('Failsafe: Payment success detected from text');
            if (!_hasReceivedResult) {
              _hasReceivedResult = true;

              // Show success toast
              Fluttertoast.showToast(
                msg: "Payment Successful!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );

              AppUtils.log('Failsafe: Closing WebView...');
              if (mounted) Navigator.pop(context);

              Future.microtask(() {
                widget.onPaymentSuccess({
                  'type': 'PAYPAL_SUCCESS',
                  'message': 'Payment completed successfully',
                });
              });
            }
          } else if (lowerContent.contains('payment failed') ||
              lowerContent.contains('payment error')) {
            AppUtils.log('Failsafe: Payment error detected from text');
            if (!_hasReceivedResult) {
              _hasReceivedResult = true;
              widget.onPaymentError('Payment failed');
              if (mounted) Navigator.of(context).pop();
            }
          }
          // Try to parse as JSON
          else if (contentStr.trim().startsWith('{')) {
            try {
              final data = jsonDecode(contentStr);

              // Check for response with type field first
              if (data['type'] == 'PAYPAL_SUCCESS') {
                AppUtils.log('Failsafe: Payment success detected from JSON');
                if (!_hasReceivedResult) {
                  _hasReceivedResult = true;

                  // Show success toast
                  Fluttertoast.showToast(
                    msg: "Payment Successful!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  if (mounted) Navigator.pop(context);
                  Future.microtask(() {
                    widget.onPaymentSuccess(data);
                  });
                }
              } else if (data['type'] == 'PAYPAL_ERROR') {
                AppUtils.log('Failsafe: Payment error detected from JSON');
                if (!_hasReceivedResult) {
                  _hasReceivedResult = true;
                  widget.onPaymentError(data['message'] ?? 'Payment failed');
                  if (mounted) Navigator.of(context).pop();
                }
              }
              // Fallback for legacy format
              else if (data['status'] == true || data['success'] == true) {
                AppUtils.log('Failsafe: Payment success detected (legacy)');
                if (!_hasReceivedResult) {
                  _hasReceivedResult = true;

                  // Show success toast
                  Fluttertoast.showToast(
                    msg: "Payment Successful!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  if (mounted) Navigator.pop(context);
                  Future.microtask(() {
                    widget.onPaymentSuccess(data);
                  });
                }
              } else if (data['status'] == false || data['error'] != null) {
                AppUtils.log('Failsafe: Payment error detected (legacy)');
                if (!_hasReceivedResult) {
                  _hasReceivedResult = true;
                  widget.onPaymentError(data['message'] ?? 'Payment failed');
                  if (mounted) Navigator.of(context).pop();
                }
              }
            } catch (e) {
              AppUtils.log('Failsafe: Error parsing JSON - $e');
            }
          }
        } catch (e) {
          AppUtils.log('Failsafe check error: $e');
        }
      });
    } catch (e) {
      AppUtils.log('Error setting up message listener: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PayPal Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            widget.onCancelled();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading || isProcessing)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0CD03D), // AppColors.btnColor
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isProcessing
                          ? 'Processing your payment...'
                          : 'Loading PayPal...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    if (isProcessing) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Please wait, this may take a moment',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
