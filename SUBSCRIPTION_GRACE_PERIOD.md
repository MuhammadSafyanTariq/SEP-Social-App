# Subscription Expiration Warning - Grace Period Feature

## 📋 Overview

This feature implements a 3-day grace period warning system for sellers with expired subscriptions. Users are reminded to resubscribe when they open the app during this period.

---

## ✨ Features

- ✅ **Automatic Detection:** Checks subscription status on app launch
- ✅ **Smart Filtering:** Only shows to users who have a store
- ✅ **3-Day Grace Period:** Warning appears for 3 days after expiration
- ✅ **Non-Blocking:** Users can dismiss and continue using the app
- ✅ **Quick Resubscribe:** Direct button to subscription screen

---

## 🎯 How It Works

### Trigger Conditions

The warning dialog appears when ALL of the following are true:
1. ✅ User has a store (store exists)
2. ✅ Subscription status is "expired" (not "active" or "none")
3. ✅ Subscription expired within the last 3 days (0-3 days ago)

### User Experience

1. **User opens the app** → System checks subscription status
2. **If conditions met** → Warning dialog appears after 500ms delay
3. **User sees dialog** with:
   - Warning icon and title
   - Explanation that store is not visible
   - Days remaining counter (e.g., "2 days left to resubscribe")
   - Info about resubscribing
   - "Later" and "Resubscribe Now" buttons
4. **User can:**
   - Click "Resubscribe Now" → Goes to subscription screen
   - Click "Later" → Dismisses dialog, will appear next time app opens

---

## 🔧 Implementation Details

### Files Created

1. **`lib/feature/presentation/subscription/resubscribe_warning_dialog.dart`**
   - Warning dialog UI component
   - Static method `showIfNeeded()` to check and display
   - Beautiful, informative design with countdown

### Files Modified

1. **`lib/services/subscription/subscription_service.dart`**
   - Added `hasStore()` - Check if user has a store
   - Added `isInGracePeriod()` - Check if expired within 3 days
   - Added `shouldShowResubscribeWarning()` - Combined check

2. **`lib/feature/presentation/Home/homeScreen.dart`**
   - Added import for warning dialog
   - Added `_checkSubscriptionWarning()` method
   - Called in `initState()` after screen loads

---

## 📊 Grace Period Logic

### Time Calculation

```dart
Expiration Date: 2026-01-01 00:00 UTC
Current Date:    2026-01-03 10:00 UTC

Days Since Expiration = 2 days
Days Remaining = 3 - 2 = 1 day

Show Warning? YES (within 0-3 days)
```

### Examples

| Expiration Date | Current Date | Days Since | Days Left | Show? |
|----------------|--------------|------------|-----------|-------|
| Jan 1, 2026    | Jan 1, 2026  | 0 days     | 3 days    | ✅ YES |
| Jan 1, 2026    | Jan 2, 2026  | 1 day      | 2 days    | ✅ YES |
| Jan 1, 2026    | Jan 3, 2026  | 2 days     | 1 day     | ✅ YES |
| Jan 1, 2026    | Jan 4, 2026  | 3 days     | 0 days    | ✅ YES (last day) |
| Jan 1, 2026    | Jan 5, 2026  | 4 days     | -1 days   | ❌ NO  |

---

## 🎨 Dialog Design

### Visual Elements

**Header:**
- Orange warning icon in circular background
- "Subscription Expired" title

**Message:**
- Clear explanation: "Your store and products are currently not visible to other users"
- Days remaining badge with clock icon

**Info Box:**
- Blue information box
- Encouragement to resubscribe

**Buttons:**
- "Later" - Gray, bordered button (dismisses)
- "Resubscribe Now" - Primary color, prominent (navigates to subscription)

---

## 💻 Code Usage

### Checking Grace Period (Manual)

```dart
import 'package:sep/services/subscription/subscription_service.dart';

final subscriptionService = SubscriptionService();

// Check if should show warning
final shouldShow = await subscriptionService.shouldShowResubscribeWarning();
if (shouldShow) {
  // Show warning
}
```

### Showing Dialog (Automatic)

```dart
import 'package:sep/feature/presentation/subscription/resubscribe_warning_dialog.dart';

// Check and show if needed (includes all logic)
await ResubscribeWarningDialog.showIfNeeded(context);
```

### In App Initialization

```dart
@override
void initState() {
  super.initState();
  
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // Other initialization...
    
    // Check subscription warning
    _checkSubscriptionWarning();
  });
}

Future<void> _checkSubscriptionWarning() async {
  await Future.delayed(const Duration(milliseconds: 500));
  if (!mounted) return;
  await ResubscribeWarningDialog.showIfNeeded(context);
}
```

---

## 🔒 Backend Requirements

The backend must:
1. ✅ Return correct subscription status ("active", "expired", "none")
2. ✅ Include `subscriptionExpiresAt` field in ISO format
3. ✅ Hide products/stores from users with expired subscriptions in feed

### API Response Format

```json
{
  "success": true,
  "data": {
    "subscriptionStatus": "expired",
    "subscriptionExpiresAt": "2026-01-01T00:00:00.000Z",
    "isActive": false,
    "daysRemaining": -2
  }
}
```

---

## 🧪 Testing Checklist

### Scenarios to Test

- [ ] **User with no store:** Should NOT see warning (even if expired)
- [ ] **User with active subscription:** Should NOT see warning
- [ ] **User with expired subscription (Day 0):** Should see warning
- [ ] **User with expired subscription (Day 1):** Should see warning
- [ ] **User with expired subscription (Day 2):** Should see warning
- [ ] **User with expired subscription (Day 3):** Should see warning
- [ ] **User with expired subscription (Day 4+):** Should NOT see warning
- [ ] **User dismisses dialog:** Dialog doesn't block app usage
- [ ] **User clicks "Resubscribe Now":** Navigates to subscription screen
- [ ] **User resubscribes:** Warning doesn't appear on next app open

### Manual Testing

1. **Setup:**
   - Create a user account
   - Create a store
   - Subscribe to seller plan
   - Wait for or manually set expiration date in backend

2. **Test Day 0-3:**
   - Close and reopen app
   - Verify warning appears
   - Test both buttons

3. **Test Day 4+:**
   - Set expiration to 4+ days ago
   - Reopen app
   - Verify NO warning appears

---

## 📱 User Flow Diagram

```
User Opens App
      ↓
Check: Has Store?
      ↓
    YES → Check: Subscription Expired?
              ↓
            YES → Check: Within 3 days?
                      ↓
                    YES → SHOW WARNING DIALOG
                              ↓
                          User Choice
                          ↙         ↘
                      "Later"    "Resubscribe"
                         ↓            ↓
                    Dismiss    → Subscription Screen
                                      ↓
                                  Subscribe
                                      ↓
                              No Warning Next Time
```

---

## ⚙️ Configuration

### Adjusting Grace Period

To change the grace period from 3 days to X days, modify this line in `subscription_service.dart`:

```dart
// Change this value:
return daysSinceExpiration >= 0 && daysSinceExpiration <= 3;

// For 5 days:
return daysSinceExpiration >= 0 && daysSinceExpiration <= 5;

// For 7 days:
return daysSinceExpiration >= 0 && daysSinceExpiration <= 7;
```

### Adjusting Dialog Delay

To change the delay before showing the dialog, modify in `homeScreen.dart`:

```dart
// Current: 500ms
await Future.delayed(const Duration(milliseconds: 500));

// For 1 second:
await Future.delayed(const Duration(seconds: 1));

// For immediate:
// Remove or comment out the delay line
```

---

## 🐛 Troubleshooting

### Issue: Warning doesn't appear

**Checks:**
1. Does user have a store? Check `hasStore()` returns true
2. Is subscription expired? Check status is "expired"
3. Is it within 3 days? Check date calculation
4. Check console logs for errors

### Issue: Warning appears when it shouldn't

**Checks:**
1. Verify subscription status from backend
2. Check expiration date is correct
3. Ensure days calculation is accurate
4. Check system date/time is correct

### Issue: Warning appears every time even after resubscribe

**Solution:**
- Backend needs to update subscription status to "active"
- Clear app cache and restart
- Verify API returns updated status

---

## 📈 Future Enhancements

Potential improvements:

1. **Local Storage:** Remember if user dismissed today (don't show again same day)
2. **Push Notifications:** Send reminder notification
3. **Email Reminder:** Send email at day 2 of grace period
4. **Countdown Timer:** Show hours remaining on last day
5. **Preview Mode:** Let user preview their hidden store
6. **Analytics:** Track resubscribe conversion rate

---

## 📞 Support

For issues or questions:
1. Check console logs for subscription service errors
2. Verify backend API responses
3. Test with different subscription states
4. Review this documentation

---

## ✅ Summary

The grace period warning system ensures sellers are promptly notified about their expired subscription and given a 3-day window to resubscribe before losing visibility completely. The system:

- ✅ **Only shows to store owners** (not all users)
- ✅ **Only during 3-day grace period** (days 0-3)
- ✅ **Non-intrusive** (dismissible dialog)
- ✅ **Action-oriented** (direct resubscribe button)
- ✅ **Clear messaging** (explains consequences)

---

**Implementation Status:** ✅ Complete  
**Last Updated:** January 1, 2026  
**Version:** 1.0.0
