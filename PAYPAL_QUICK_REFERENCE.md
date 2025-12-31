# PayPal Integration - Quick Reference

## 🚀 Quick Start

### 1. Navigate to PayPal Top-Up
```dart
import 'package:sep/feature/presentation/wallet/paypal_topup_screen.dart';
import 'package:sep/services/storage/preferences.dart';

// Navigate to top-up screen
final userId = Preferences.uid ?? "";
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PayPalTopUpScreen(
      userId: userId,
      onBalanceUpdated: (newBalance) {
        // Handle balance update
      },
    ),
  ),
);
```

### 2. Already Integrated Locations
- ✅ Wallet Screen → "Add Balance" button
- ✅ Add Card Screen → "Top Up Wallet with PayPal" button

---

## 📁 File Structure

```
lib/
├── services/
│   └── paypal_service.dart          ← PayPal API service
├── components/
│   └── widgets/
│       └── paypal_webview.dart      ← PayPal WebView widget
└── feature/
    └── presentation/
        └── wallet/
            └── paypal_topup_screen.dart  ← Top-up screen UI
```

---

## 🔌 API Endpoints

**Base URL:** `http://67.225.241.58:4004/api`

1. **Create Order**
   - Endpoint: `POST /api/paypal/create-order`
   - You call: ✅ Yes
   - Backend processes: Payment capture, bonus, wallet update

2. **Process Payment**
   - Endpoint: `GET /api/paypal/process-payment`
   - You call: ❌ No (PayPal calls automatically)
   - Backend handles: Everything automatically

3. **Cancel Payment**
   - Endpoint: `GET /api/paypal/cancel`
   - You call: ❌ No (PayPal calls automatically)
   - Backend handles: Cleanup

---

## 💰 Payment Amounts

### Preset Amounts:
- $10
- $25
- $50
- $100

### Custom Amount:
- Minimum: $1.00
- No maximum (set by your backend)

### First-Time Bonus:
- Automatic $5 bonus on first payment only
- Example: Pay $10 → Get $15 total

---

## 🎨 Theme Colors

```dart
AppColors.greenlight  // Primary green (#0CD03D)
AppColors.green       // Secondary green
Colors.grey[50]       // Background
Colors.white          // Cards
Colors.black87        // Text
Colors.grey[600]      // Secondary text
```

---

## ✅ Success Response Structure

```dart
{
  "type": "PAYPAL_SUCCESS",
  "orderId": "ORDER_ID",
  "paymentId": "PAYMENT_ID",
  "amount": 10.00,
  "topUpResult": {
    "rechargeAmount": 10.00,
    "firstTimeBonusAmount": 5.00,     // 0 if not first time
    "totalDollarAdded": 15.00,
    "newWalletBalance": 25.00,
    "isFirstTopUp": true              // false if not first time
  }
}
```

---

## 🔧 Testing Commands

### Run App:
```bash
flutter run
```

### Check for Errors:
```bash
flutter analyze
```

### Format Code:
```bash
flutter format .
```

---

## 🐛 Debug Logs

The integration includes comprehensive logging:

```dart
AppUtils.log('PayPal: Creating order...');
AppUtils.log('PayPal: Response - $data');
AppUtils.log('PayPal: Success - $successData');
AppUtils.log('PayPal: Error - $error');
```

View logs in:
- VS Code: Debug Console
- Android Studio: Logcat
- Command line: Terminal output

---

## ⚠️ Error Messages

### User-Facing Messages:
- "Please enter a valid amount"
- "Minimum amount is $1.00"
- "User ID not found"
- "Failed to create order"
- "Payment failed: [reason]"
- "Payment was cancelled"

### Backend Errors:
Backend should return descriptive error messages in:
```json
{
  "status": false,
  "message": "Error description here"
}
```

---

## 🔄 State Management

The integration uses:
- `setState()` for local UI updates
- `ProfileCtrl` (GetX) for global profile/wallet balance
- Callbacks for parent screen updates

---

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ❌ Web (WebView not supported)
- ❌ Desktop (WebView limited support)

---

## 🎯 Key Features

1. **Automatic Processing** - Backend handles everything
2. **First-Time Bonus** - $5 bonus on first payment
3. **Quick Amounts** - Fast selection buttons
4. **Custom Amounts** - User can enter any amount
5. **Validation** - Minimum amount check
6. **Loading States** - Visual feedback during processing
7. **Success Dialog** - Detailed payment confirmation
8. **Error Handling** - Comprehensive error management
9. **Theme Matching** - Follows your app's design
10. **Auto Refresh** - Balance updates automatically

---

## 🔐 Security Notes

- All sensitive operations on backend
- No PayPal credentials in app
- User authentication via backend
- HTTPS recommended for production
- Token-based user identification

---

## 📊 User Journey

**Simple 6-Step Process:**
1. Click "Add Balance"
2. Enter amount
3. Click "Pay with PayPal"
4. Approve on PayPal
5. Wait for processing (automatic)
6. See success message

**Total Time:** ~30 seconds

---

## 💡 Pro Tips

### For Testing:
- Use PayPal Sandbox accounts
- Test first payment for bonus
- Test subsequent payments (no bonus)
- Test with different amounts
- Test cancellation flow

### For Production:
- Switch to live PayPal credentials in backend
- Update base URL if needed
- Test with real small amounts first
- Monitor backend logs
- Set up error tracking

### For Debugging:
- Check `AppUtils.log()` output
- Verify user ID is valid
- Ensure backend is running
- Check network connectivity
- Review backend response format

---

## 📞 Need Help?

**Check:**
1. Backend logs
2. Flutter console
3. Network requests
4. PayPal dashboard
5. Database records

**Common Solutions:**
- Restart backend server
- Clear app data
- Check PayPal credentials
- Verify API endpoints
- Test network connection

---

## 🎉 You're Ready!

Integration is complete and ready to use! Just:

1. ✅ Backend has PayPal endpoints
2. ✅ PayPal credentials configured
3. ✅ Test with sandbox first
4. ✅ Then deploy to production

**Happy coding!** 🚀
