# PayPal Duplicate Transaction Issue - Backend Fix Required

## Problem Description
When a user tops up their wallet via PayPal, **two transaction records** are being created instead of one:
1. "Paypal wallet top up"
2. "Wallet recharged"

## Root Cause
This is a **backend issue**. The backend API endpoint `/api/paypal/process-payment` or related transaction creation logic is likely creating duplicate transaction entries in the database.

## What Needs to be Fixed on Backend

### Check These Backend Files/Endpoints:

1. **PayPal Process Payment Endpoint** (`/api/paypal/process-payment`)
   - This endpoint is called automatically after PayPal approval
   - It should only create **ONE** transaction record with description like "PayPal Wallet Top-Up"
   - Currently it may be calling transaction creation twice

2. **Wallet Top-Up Logic**
   - Check if `topUpWallet` function is creating an additional "Wallet recharged" transaction
   - The wallet balance update should NOT create a separate transaction if PayPal already created one

### Recommended Backend Fix:

```javascript
// BACKEND - PayPal Process Payment Endpoint (Example)
// File: routes/paypal.js or similar

router.post('/process-payment', async (req, res) => {
  try {
    const { orderId } = req.body;
    
    // 1. Capture the PayPal payment
    const capture = await capturePayPalOrder(orderId);
    
    if (capture.status === 'COMPLETED') {
      const amount = parseFloat(capture.amount);
      const userId = capture.userId;
      
      // 2. Update wallet balance
      await User.findByIdAndUpdate(userId, {
        $inc: { walletBalance: amount }
      });
      
      // 3. Create ONLY ONE transaction record
      const transaction = await Transaction.create({
        userId: userId,
        type: 'credit',
        amount: amount,
        description: 'PayPal Wallet Top-Up', // Single unified description
        stripePaymentId: null,
        related_order_id: orderId,
        balance_after: updatedUser.walletBalance
      });
      
      // ❌ DO NOT create another transaction here
      // ❌ DO NOT call topUpWallet() which might create duplicate
      
      return res.json({
        success: true,
        transaction: transaction,
        newBalance: updatedUser.walletBalance
      });
    }
  } catch (error) {
    console.error('PayPal process payment error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});
```

### What to Look For:

1. **Duplicate Transaction Creation**
   ```javascript
   // ❌ WRONG - Creating transaction twice
   await Transaction.create({ description: 'PayPal wallet top up' });
   await Transaction.create({ description: 'Wallet recharged' });
   
   // ✅ CORRECT - Create only once
   await Transaction.create({ description: 'PayPal Wallet Top-Up' });
   ```

2. **Calling topUpWallet After PayPal**
   ```javascript
   // ❌ WRONG - If topUpWallet also creates transaction
   await capturePayPalPayment(orderId);
   await topUpWallet(userId, amount); // This might create 2nd transaction
   
   // ✅ CORRECT - Update balance directly, create transaction once
   await capturePayPalPayment(orderId);
   await updateWalletBalance(userId, amount);
   await createTransaction(userId, amount, 'PayPal Wallet Top-Up');
   ```

3. **Middleware or Hooks**
   - Check if there's a database hook (like Mongoose middleware) that auto-creates transactions on wallet updates
   - Check if there's middleware that creates a transaction before the main handler

## Frontend Changes Made

### ✅ Fixed: Profile Picture in Transaction List
**File**: `lib/feature/presentation/wallet/wallet_screen.dart`

**Change**: Updated `TransactionTile` widget to show user's actual profile picture instead of dummy image:

```dart
CircleAvatar(
  radius: 24.sdp,
  backgroundImage: (profileImage != null && profileImage.isNotEmpty)
      ? NetworkImage(profileImage)
      : const AssetImage(AppImages.dummyProfile) as ImageProvider,
),
```

## Testing After Backend Fix

Once the backend is fixed, test:

1. ✅ Top up wallet with PayPal
2. ✅ Check wallet_screen.dart - should show only ONE transaction
3. ✅ Transaction should show correct amount
4. ✅ Transaction should show user's profile picture
5. ✅ Balance should update correctly

## API Endpoints Involved

- `POST /api/paypal/create-order` - Creates PayPal order (frontend calls this)
- `GET /api/paypal/process-payment` - Processes payment after approval (automatic redirect)
- `GET /api/stripe/paymentTransactions` - Fetches transaction list (frontend calls this)

## Backend Files to Check

1. `routes/paypal.js` or `controllers/paypal.controller.js`
2. `routes/stripe.js` or `controllers/stripe.controller.js` (for topUpWallet)
3. `models/Transaction.js` (check for any hooks/middleware)
4. Any wallet utility functions that might create transactions

---

## Summary

- ✅ **Frontend fix applied**: Profile picture now shows in transactions
- ⚠️ **Backend fix needed**: Remove duplicate transaction creation in PayPal payment processing
- 🎯 **Goal**: One PayPal top-up = One transaction record with user's profile picture

