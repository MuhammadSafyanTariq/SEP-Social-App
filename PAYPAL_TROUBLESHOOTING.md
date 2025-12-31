# PayPal Integration Troubleshooting

## ✅ Current Status

Based on your logs, here's what's **working**:

1. ✅ PayPal order creation successful (Order ID: `2HW849541H6389932`)
2. ✅ WebView loading PayPal sandbox correctly
3. ✅ User successfully approving payment
4. ✅ Redirect to process-payment endpoint successful
5. ✅ JavaScript message listener set up correctly

## ❌ The Issue

The Flutter app is NOT receiving the success/error message from the backend after payment processing.

### Expected Flow:
```
1. User approves payment ✅
2. Backend processes payment ✅  
3. Backend returns HTML with postMessage ❌ (MISSING)
4. Flutter WebView receives message ❌ (NOT HAPPENING)
5. App shows success dialog ❌ (NOT HAPPENING)
```

## 🔧 Solution

Your backend's `/api/paypal/process-payment` endpoint needs to return an HTML page that sends a `postMessage` to the WebView.

### Backend Fix (Node.js/Express Example):

```javascript
router.get('/process-payment', async (req, res) => {
  try {
    const { token, userId, PayerID } = req.query;
    
    // Process the payment...
    const result = await capturePayPalPayment(token, PayerID);
    
    // Top up wallet...
    const topUpResult = await topUpWallet(userId, amount);
    
    // ⚠️ CRITICAL: Return HTML page with postMessage
    return res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Payment Successful</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          }
          .container {
            text-align: center;
            color: white;
            padding: 20px;
          }
          .checkmark {
            font-size: 80px;
            animation: scaleIn 0.5s ease-in-out;
          }
          @keyframes scaleIn {
            from { transform: scale(0); }
            to { transform: scale(1); }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="checkmark">✓</div>
          <h1>Payment Successful!</h1>
          <p>Processing your top-up...</p>
        </div>
        
        <script>
          console.log('Sending success message to Flutter...');
          
          // Send message to Flutter WebView
          window.postMessage({
            type: 'PAYPAL_SUCCESS',
            orderId: '${token}',
            amount: ${amount},
            topUpResult: ${JSON.stringify(topUpResult)}
          }, '*');
          
          console.log('Success message sent!');
        </script>
      </body>
      </html>
    `);
    
  } catch (error) {
    console.error('PayPal processing error:', error);
    
    // Return error page with postMessage
    return res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Payment Failed</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
          }
          .container {
            text-align: center;
            color: white;
            padding: 20px;
          }
          .error-icon {
            font-size: 80px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="error-icon">✗</div>
          <h1>Payment Failed</h1>
          <p>${error.message || 'Something went wrong'}</p>
        </div>
        
        <script>
          console.log('Sending error message to Flutter...');
          
          window.postMessage({
            type: 'PAYPAL_ERROR',
            message: '${error.message || 'Payment processing failed'}'
          }, '*');
          
          console.log('Error message sent!');
        </script>
      </body>
      </html>
    `);
  }
});
```

## 🧪 Testing the Fix

After updating your backend:

1. **Test the payment flow again**
2. **Check the logs for**:
   ```
   I/flutter: 🐛 PayPal: Message received from backend
   I/flutter: 🐛 PayPal: Payment successful!
   ```
3. **Verify the success dialog appears**
4. **Check wallet balance is updated**

## 🔍 Additional Debugging

If the issue persists, add more logging to your backend:

```javascript
router.get('/process-payment', async (req, res) => {
  console.log('📍 Process-payment endpoint hit');
  console.log('Query params:', req.query);
  
  try {
    // ... payment processing
    
    console.log('✅ Payment processed successfully');
    console.log('💰 Sending HTML response with postMessage...');
    
    // Return HTML...
  } catch (error) {
    console.error('❌ Payment processing failed:', error);
    // Return error HTML...
  }
});
```

## 📝 Key Points

1. **DO NOT** return JSON from `/api/paypal/process-payment`
2. **MUST** return HTML page with `postMessage`
3. **postMessage** must include `type: 'PAYPAL_SUCCESS'` or `type: 'PAYPAL_ERROR'`
4. Flutter's JavaScript channel (`FlutterPayPal`) listens for these messages
5. The WebView automatically closes after receiving the message

## ⚠️ Common Mistakes

❌ **Wrong:** Returning JSON
```javascript
res.json({ success: true, message: 'Payment successful' });
```

✅ **Correct:** Returning HTML with postMessage
```javascript
res.send(`<html>...<script>window.postMessage({...})</script></html>`);
```

## 📚 Related Files

- Flutter WebView: `lib/components/widgets/paypal_webview.dart`
- PayPal Service: `lib/services/paypal_service.dart`
- Top-up Screen: `lib/feature/presentation/wallet/paypal_topup_screen.dart`

---

**Next Steps:** Update your backend's `/api/paypal/process-payment` endpoint to return HTML with postMessage instead of JSON.
