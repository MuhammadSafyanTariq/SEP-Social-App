# 🧩 Frontend Integration Guide — Wallet, Tokens, Monetization & Gifting

This guide explains how a **Flutter** frontend should integrate with the new:

- Wallet balance (USD) + token system
- Account monetization
- Token‑priced gifting (feed, video, live)
- Gift cashout (70% creator / 30% platform)
- Live gifting via **Socket.IO**

All examples assume:

- Backend base URL: `http://<backend-host>:4004`
- API base path: `http://<backend-host>:4004/api`
- Socket.IO endpoint: `http://<backend-host>:4004`

Replace `<backend-host>` with your actual host/IP.

---

## Token Flow Summary

1. **Recharge** → User pays (PayPal/Stripe) → `walletBalance` + `walletTokens` increased.
2. **Send gift** → Tokens deducted from `walletTokens`; receiver’s `giftsBalance` increased by 70% of gift value.
3. **Cashout gifts** (when `giftsBalance` ≥ $50) → Creator share moved from `giftsBalance` to `withdrawalBalance`.
4. **Withdraw** → User requests payout from `withdrawalBalance` to bank.

---

## 1. Authentication & Common Setup

### 1.1 JWT Handling

Most endpoints require a JWT (created at login). The Flutter app should:

- Store JWT securely (e.g. `flutter_secure_storage`).
- Attach it as a `Bearer` token on all protected requests.

**Common headers (Dart):**

```dart
Map<String, String> buildAuthHeaders(String jwt) {
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $jwt',
  };
}
```

### 1.2 Base URLs

```dart
const String baseUrl = 'http://<backend-host>:4004/api';
const String socketUrl = 'http://<backend-host>:4004';
```

---

## 2. User Monetization Flow

### 2.1 Business Rules

An account can be monetized **only if**:

- The user has **≥ 250 followers**.
- The account age is **≥ 30 days** (based on `createdAt`).

When monetized:

- `User.monetized` is set to `true`.
- The user can receive gifts (REST and live).

### 2.2 Endpoint

- **URL**: `POST /api/monetize-account`
- **Auth**: Required (`Authorization: Bearer <JWT>`)
- **Body**: _none_

### 2.3 Possible Responses

- **200 OK** – success or already monetized:

```json
{
  "status": true,
  "message": "Your account is monetized successfully",
  "data": {
    "monetized": true
  }
}
```

or

```json
{
  "status": true,
  "message": "Your account is already monetized",
  "data": {
    "monetized": true
  }
}
```

- **400 Bad Request** – requirements not met:

```json
{
  "status": false,
  "message": "Monetization request rejected: you have less followers than 250",
  "data": {}
}
```

Or (both conditions missing):

```json
{
  "status": false,
  "message": "Monetization request rejected: you have less followers than 250 and your account is not 1 month old",
  "data": {}
}
```

- **401 Unauthorized** – invalid or missing JWT.

### 2.4 Flutter Example

```dart
Future<void> monetizeAccount(String jwt) async {
  final uri = Uri.parse('$baseUrl/monetize-account');
  final res = await http.post(uri, headers: buildAuthHeaders(jwt));

  final body = jsonDecode(res.body);

  if (res.statusCode == 200 && body['status'] == true) {
    // Show success
  } else {
    // Show body['message'] as error to user
  }
}
```

### 2.5 Recommended UI

- Show a **“Apply for Monetization”** button on the profile/earnings page.
- On tap:
  - Call `POST /api/monetize-account`.
  - Show the server’s `message` directly (contains detailed reason).
- Disable gifting UI (send button) when the **receiver** is not monetized (see section 6 on how to check).

---

## 3. Wallet, Tokens & Balance (USD, via PayPal)

### 3.1 Concept

- **Base rule**: `1 token = $0.01` (one cent per token).
- `User.walletTokens` is the **primary wallet for gifts**:
  - Tokens are **deducted** when sending gifts.
  - Tokens are **added** when the user recharges (PayPal, Stripe, or token packages).
- `User.walletBalance` is updated on recharge (USD) and used for token packages, Stripe flows, orders, referrals.
- **Gifting is fully token‑based** — only `walletTokens` is used when sending gifts. The `balance` field has been removed.

### 3.2 PayPal Top-Up Flow (Create Order → Approve → Auto Capture)

Top‑up is a **two‑step PayPal flow**:

1. **Create Order** from your app.
2. User approves on PayPal, which then redirects back to the backend (`/api/paypal/process-payment`) and the backend:
   - Captures the payment.
   - Adds the amount (USD) to `User.balance`.
   - Converts the amount to tokens and **increments `User.walletTokens`**:
     - Example: `$10.00` → `1,000` tokens.
   - Creates a `WalletTransaction` with both `amount` (USD) and `tokenAmount` (tokens).

#### 3.2.1 Create PayPal Order

**Endpoint**

- `POST /api/paypal/create-order`

**Body**

```json
{
  "userId": "<currentUserId>",
  "amount": "20.00",
  "returnUrl": "yourapp://paypal/success",
  "cancelUrl": "yourapp://paypal/cancel",
  "preferGuestCheckout": true
}
```

- `amount` must be a positive decimal in dollars.
- `returnUrl`/`cancelUrl` are **optional**. If omitted, backend uses its own process/cancel URLs.
- **`preferGuestCheckout`** (optional, default from app: `true`): When `true`, the backend **must** create the PayPal order with settings that show **"Pay with Debit or Credit Card"** (guest checkout). See §3.2.1.1 below.

**§3.2.1.1 Enabling "Pay with Debit or Credit Card" (Guest Checkout)**

If users see only "Create an Account" and no "Pay with Debit or Credit Card" option:

1. **When calling PayPal Orders API v2** to create the order, include:
   - **`application_context`** (or `payment_source.paypal.experience_context`): set **`payment_method.payee_preferred`** = **`"IMMEDIATE_PAYMENT_REQUIRED"`**, **`landing_page`** = **`"NO_PREFERENCE"`**, **`user_action`** = **`"PAY_NOW"`**.
2. **PayPal Business account**: In Website payment preferences, enable **"PayPal Account Optional"** / **"Guest Checkout"** so buyers can pay with a card without creating a PayPal account.
3. When the client sends **`preferGuestCheckout: true`** in the create-order body, use the above settings when calling PayPal.

**Response (success, 200)** – simplified:

```json
{
  "status": true,
  "message": "PayPal order created successfully",
  "data": {
    "orderId": "PAYPAL_ORDER_ID",
    "approvalUrl": "https://www.sandbox.paypal.com/checkoutnow?token=...",
    "amount": 20,
    "userId": "<currentUserId>"
  }
}
```

Your Flutter app must open `approvalUrl` in a browser or WebView.

#### 3.2.2 Automatic Capture & Balance Update

When the user approves the payment, PayPal redirects back to:

- `GET /api/paypal/process-payment?token=<orderId>&userId=<userId>`

The backend:

- Captures the order.
- Reads `capture.amount.value` (USD).
- Uses `walletTopUp(userId, amount, { skipTransaction: true })`, which:
  - **increments `User.walletBalance`** by the dollar amount
  - **increments `User.walletTokens`** by `amount / 0.01` (floored)
  - sets `hasEverRecharged` / `lastRechargeDate`
- Creates a `WalletTransaction` with:
  - `type: "credit"`
  - `transactionType: "paypal_recharge"`
  - `amount`: capture amount in USD
  - `tokenAmount`: tokens minted (e.g. `1000` for `$10.00`)
  - `balance_after`: new `User.walletBalance`
- Renders an HTML success page that posts a `PAYPAL_SUCCESS` message back to the opener (useful for WebView/popup).

Client‑side, you’ll see a payload like:

```json
{
  "type": "PAYPAL_SUCCESS",
  "orderId": "<orderToken>",
  "paymentId": "<paypalCaptureId>",
  "amount": 20.0,
  "topUpResult": {
    "rechargeAmount": 20.0,
    "totalDollarAdded": 20.0,
    "newWalletBalance": 40.0,
    "newWalletTokens": 4000,
    "tokensEquivalent": 2000,
    ...
  },
  "transactionId": "<walletTransactionId>"
}
```

> **Important:** Use `topUpResult.newWalletTokens` to update the user’s **token balance** for gifting. Use `topUpResult.newWalletBalance` for the USD wallet display.

### 3.3 Flutter Integration Pattern (PayPal + WebView)

**Step 1 – Create order:**

```dart
Future<String?> createPaypalOrder({
  required String jwt,
  required String userId,
  required double amount,
}) async {
  final uri = Uri.parse('$baseUrl/paypal/create-order');
  final res = await http.post(
    uri,
    headers: buildAuthHeaders(jwt),
    body: jsonEncode({
      'userId': userId,
      'amount': amount.toStringAsFixed(2),
      // Optionally:
      // 'returnUrl': 'yourapp://paypal/success',
      // 'cancelUrl': 'yourapp://paypal/cancel',
    }),
  );

  final body = jsonDecode(res.body);
  if (res.statusCode == 200 && body['status'] == true) {
    return body['data']['approvalUrl'] as String;
  } else {
    // Show body['message']
    return null;
  }
}
```

**Step 2 – Open approval URL:**

- Use `url_launcher` or `webview_flutter` to open `approvalUrl`.
- If using WebView, listen for:
  - Your custom deep link (`yourapp://paypal/success`), or
  - The `postMessage` from the success HTML (`PAYPAL_SUCCESS`), depending on your setup.

**Step 3 – Receive success and refresh balance:**

When you receive the `PAYPAL_SUCCESS` payload (or your deep link hits), you should:

1. Update **token balance** UI using `topUpResult.newWalletTokens` (used for sending gifts).
2. Update **wallet balance** (USD) using `topUpResult.newWalletBalance` if displayed.
3. Optionally refetch a wallet/profile endpoint to confirm.

Example handler:

```dart
void onPaypalSuccess(Map<String, dynamic> payload) {
  final topUpResult = payload['topUpResult'] as Map<String, dynamic>?;
  final newTokens = topUpResult?['newWalletTokens'];
  final newBalance = topUpResult?['newWalletBalance'];
  if (newTokens != null) {
    // Update local token balance (for gifting)
  }
  if (newBalance != null) {
    // Update local wallet balance (USD)
  }
  if (newTokens == null && newBalance == null) {
    // Fallback: refetch wallet/profile from backend
  }
}
```

---

## 4. Gifting on Feed / Video (REST, Token-based)

### 4.1 Gift Catalog & Prices (Tokens)

The backend defines fixed gift types priced in **tokens** (1 token = $0.01):

| `giftName` code                      | Tokens | Approx. USD |
|--------------------------------------|--------|-------------|
| `Applause_Hands`                     | 1      | $0.01       |
| `Ascending_Smiling_Face_Heart_Eyes`  | 8      | $0.08       |
| `Beating_Heart`                      | 48     | $0.48       |
| `Blooming_Flowers`                   | 67     | $0.67       |
| `Popping_Champagne`                  | 197    | $1.97       |
| `Birthday_Cake`                      | 498    | $4.98       |
| `Falling_Gold_Coins`                 | 997    | $9.97       |
| `Floating_Cash`                      | 1998   | $19.98      |
| `Soaring_Eagle`                      | 4186   | $41.86      |
| `Verde_Mantis_Lamborghini`           | 29998  | $299.98     |
| `Boeing_747_8_VIP_Jet`               | 34998  | $349.98     |

- These `giftName` codes are **case-sensitive** and must match exactly.
- The backend converts tokens → USD using `user.tokenValue` (default `0.01`) and stores the USD value in `Gift.amount` for accounting.

### 4.2 Send Gift API

**Endpoint**

- `POST /api/gift/send`

**Auth**

- Required (`Authorization: Bearer <JWT>`).
- Sender is inferred from `req.user.userId` (the token).

**Request body**

```json
{
  "receiverId": "<creatorUserId>",
  "giftName": "Applause_Hands",
  "contextType": "feed",
  "contentId": "<postOrVideoId>"
}
```

Where:

- `receiverId`: the **creator’s User ID**.
- `giftName`: one of the gift codes in the table above.
- `contextType`: `"feed" | "video" | "live"`.
  - For standard feed posts use `"feed"`.
  - For normal videos use `"video"`.
  - `"live"` is supported but for live you should primarily use Socket.IO (see section 5).
- `contentId`:
  - For `feed` / `video`: the MongoDB ObjectId of the post/video.
  - For `live`: can be the live `roomId` string (optional).

**Response (success, 200)** – example:

```json
{
  "status": true,
  "message": "Gift sent successfully",
  "data": {
    "giftId": "6730b8...",
    "giftName": "Beating_Heart",
    "amount": 0.48,
    "tokenAmount": 48,
    "senderNewTokenBalance": 952,
    "receiverId": "672f...",
    "contextType": "feed",
    "contentId": "672e..."
  }
}
```

- `senderNewTokenBalance`: sender’s remaining token balance after deducting the gift.

**Error cases:**

- Receiver not monetized:

```json
{
  "status": false,
  "message": "You cannot send a gift because this account is not monetized",
  "data": {}
}
```

– Insufficient tokens:

```json
{
  "status": false,
  "message": "Insufficient tokens. Required: 48, Available: 12",
  "data": {}
}
```

### 4.3 Flutter Example

```dart
Future<void> sendGiftOnPost({
  required String jwt,
  required String receiverId,
  required String postId,
  required String giftName, // e.g. 'Applause_Hands'
}) async {
  final uri = Uri.parse('$baseUrl/gift/send');
  final res = await http.post(
    uri,
    headers: buildAuthHeaders(jwt),
    body: jsonEncode({
      'receiverId': receiverId,
      'giftName': giftName,
      'contextType': 'feed',
      'contentId': postId,
    }),
  );

  final body = jsonDecode(res.body);
  if (res.statusCode == 200 && body['status'] == true) {
    final data = body['data'];
    final newTokenBalance = data['senderNewTokenBalance'];
    // Update token balance UI and show gift animation
  } else {
    // Show body['message'] as error
  }
}
```

### 4.4 Per-Post Gift Summary

The backend stores per‑post gift summaries in the `Post` document:

- `Post.giftsSummary: [{ giftName, count, lastGiftId }]`

If you want to display **how many gifts a post has received**, you can:

1. Extend an existing post fetch API (e.g. feed listing) to return `giftsSummary`.
2. Or add a small endpoint (e.g. `/api/gift/content-total/:contentId`) following the example from `GIFTING_SYSTEM_IMPLEMENTATION_GUIDE.md`.

> At the moment, `giftsSummary` is updated whenever `/api/gift/send` is called with `contextType = 'feed'|'video'` and a `contentId`.

---

## 5. Live Gifts (Socket.IO, Token-based)

Live streams already use Socket.IO (`socket/socket.js`). We added dedicated events for real‑time gifting.

### 5.1 Events Overview

**Client → Server**

- `sendGiftLive`

**Server → Client**

- `giftReceived` – broadcast to entire live room.
- `liveGiftUpdate` – updated gift totals for current live room.
- `giftSent` – confirmation to sender only.
- `giftReceivedPersonal` – personal notification to host.
- `giftError` – error back to sender.

### 5.2 Connecting from Flutter

Use `socket_io_client` (already used in the project).

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

late IO.Socket liveSocket;

void connectLiveSocket() {
  liveSocket = IO.io(
    socketUrl,
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build(),
  );

  liveSocket.onConnect((_) {
    print('Live socket connected');
  });

  liveSocket.onDisconnect((_) {
    print('Live socket disconnected');
  });

  _registerGiftListeners();
}
```

### 5.3 Registering Gift Listeners

```dart
void _registerGiftListeners() {
  liveSocket.on('giftReceived', (data) {
    // Trigger gift animation for all viewers
    // data['senderName'], data['giftName'], data['amount'], data['message']
  });

  liveSocket.on('liveGiftUpdate', (data) {
    // Update aggregate counters on live UI
    // totalGifts (double), totalGiftCount (int)
  });

  liveSocket.on('giftSent', (data) {
    // Sender confirmation: data['senderNewTokenBalance'], data['giftName'], data['amount'], data['tokensSpent']
  });

  liveSocket.on('giftReceivedPersonal', (data) {
    // Host-only popup/notification
  });

  liveSocket.on('giftError', (data) {
    // Show error: data['message']
  });
}
```

### 5.4 Sending a Live Gift

**Payload for `sendGiftLive`:**

```json
{
  "senderId": "<viewerUserId>",
  "receiverId": "<hostUserId>",
  "roomId": "<live_room_id>",
  "giftName": "Applause_Hands"
}
```

**Flutter:**

```dart
void sendLiveGift({
  required String senderId,
  required String receiverId,
  required String roomId,
  required String giftName,
}) {
  liveSocket.emit('sendGiftLive', {
    'senderId': senderId,
    'receiverId': receiverId,
    'roomId': roomId,
      'giftName': giftName, // must match one of the catalog codes
  });
}
```

**Server-side validation:**

– Checks `senderId`, `receiverId`, `roomId`, `giftName` present.
– Validates `giftName` from the same token catalog as REST.
– Verifies:
  - Sender exists.
  - Receiver exists.
  - **Receiver is monetized** (otherwise emits `giftError` with `type: "RECEIVER_NOT_MONETIZED"`).
  - Sender has **enough tokens** in `walletTokens` to cover the gift.

### 5.5 Data Structures from Socket Events

**`giftReceived` (to room):**

```json
{
  "giftId": "...",
  "senderId": "...",
  "senderName": "Viewer",
  "senderImage": "https://...",
  "receiverId": "...",
  "receiverName": "Host",
  "giftName": "Beating_Heart",
  "amount": 0.48,
  "timestamp": "2024-01-01T00:00:00.000Z",
  "message": "Viewer sent Beating_Heart ($0.48)"
}
```

**`liveGiftUpdate`:**

```json
{
  "roomId": "live_<hostId>_<timestamp>",
  "totalGifts": 25.5,
  "totalGiftCount": 13
}
```

**`giftSent`:**

```json
{
  "giftId": "...",
  "amount": 0.48,
  "tokensSpent": 48,
  "senderNewTokenBalance": 952,
  "receiverName": "Host",
  "giftName": "Beating_Heart",
  "message": "Gift sent successfully!"
}
```

**`giftReceivedPersonal`:**

```json
{
  "giftId": "...",
  "senderId": "...",
  "senderName": "Viewer",
  "senderImage": "https://...",
  "giftName": "Beating_Heart",
  "amount": 0.48,
  "message": "Viewer sent you Beating_Heart ($0.48)"
}
```

**`giftError`:**

```json
{
  "message": "You cannot send a gift because this account is not monetized",
  "type": "RECEIVER_NOT_MONETIZED"
}
```

> Frontend should treat `giftError.message` as user‑facing text.

---

## 6. Listing and Cashing Out Received Gifts

### 6.1 List Received Gifts

**Endpoint**

- `GET /api/gift/received`
- Optional query params:
  - `status`: `"all" | "active" | "cashedOut"` (default: `"all"`).
  - `page`: default `1`.
  - `limit`: default `20`.

**Example URL**

- `/api/gift/received?status=active&page=1&limit=20`

**Response example**

```json
{
  "status": true,
  "message": "Received gifts retrieved successfully",
  "data": {
    "gifts": [
      {
        "_id": "6730b8...",
        "senderId": {
          "_id": "672f...",
          "name": "Alice",
          "image": "https://..."
        },
        "receiverId": "6730...",
        "amount": 0.48,
        "tokenAmount": 48,
        "giftName": "Beating_Heart",
        "contextType": "feed",
        "contentId": "672e...",
        "commissionPercent": 30,
        "creatorShare": 0,
        "platformShare": 0,
  "status": "active",
        "senderBalanceAfter": 952,
        "createdAt": "...",
        "updatedAt": "..."
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "totalCount": 3,
      "totalPages": 1
    }
  }
}
```

**Flutter example**

```dart
Future<void> loadReceivedGifts({
  required String jwt,
  String status = 'all',
}) async {
  final query = <String, String>{
    if (status != 'all') 'status': status,
    'page': '1',
    'limit': '20',
  };

  final uri = Uri.parse('$baseUrl/gift/received').replace(
    queryParameters: query,
  );

  final res = await http.get(uri, headers: buildAuthHeaders(jwt));
  final body = jsonDecode(res.body);

  if (res.statusCode == 200 && body['status'] == true) {
    final gifts = body['data']['gifts'] as List<dynamic>;
    // Map to models and show in UI
  } else {
    // Show body['message']
  }
}
```

### 6.2 Cashout Gifts (70/30 Split, $50 Minimum)

**Business logic**

- For the **receiver**:
  - Every time a gift is received, the backend:
    - Computes USD value from tokens (`Gift.amount`).
    - Calculates 70% creator share and 30% platform share.
    - Increments `User.giftsBalance` by the **creator share** (USD).
  - `User.giftsBalance` therefore represents **un‑cashed‑out gift earnings**.
- Cashout endpoint:
  - Sums all `Gift` entries with:
    - `receiverId = current user`
    - `status = "active"`.
  - Splits total amount:
    - `70%` → Creator.
    - `30%` → Platform.
  - Requires **`giftsBalance >= $50`** before cashout is allowed.
  - On successful cashout:
    - All those gifts are set to `status = "cashedOut"`.
    - Creator:
      - `giftsBalance -= creatorShareTotal` (never below 0)
      - `withdrawalBalance += creatorShareTotal`
    - Platform (admin user):
      - `walletBalance += platformShareTotal`
    - Creates wallet transactions and a commission log entry.

**Endpoint**

- `POST /api/gift/cashout`

**Response example**

```json
{
  "status": true,
  "message": "Gifts cashed out successfully",
  "data": {
    "totalGifts": 5,
    "totalAmount": 25.0,
    "creatorShare": 17.5,
    "platformShare": 7.5,
    "receiverGiftsBalance": 0,
    "receiverWithdrawalBalance": 17.5,
    "platformWalletBalance": 500.0
  }
}
```

**Flutter example**

```dart
Future<void> cashoutGifts(String jwt) async {
  final uri = Uri.parse('$baseUrl/gift/cashout');
  final res = await http.post(uri, headers: buildAuthHeaders(jwt));
  final body = jsonDecode(res.body);

  if (res.statusCode == 200 && body['status'] == true) {
    final data = body['data'];
    final creatorShare = data['creatorShare'];
    final newWithdrawalBalance = data['receiverWithdrawalBalance'];
    // Update earnings UI and show success
  } else {
    // Show body['message']
  }
}
```

**Error / empty case**

– If there are no active gifts:

```json
{
  "status": true,
  "message": "No pending gifts to cash out",
  "data": {
    "totalGifts": 0,
    "totalAmount": 0,
    "creatorShare": 0,
    "platformShare": 0
  }
}
```

> Treat this as a non-error and show a friendly message like “You have no active gifts to cashout”.

---

## 7. Recommended Frontend UX Flow

### 7.1 Creator Profile

- Show:
  - Monetization status (monetized / not).
  - **Token balance** (`walletTokens`) — used for sending gifts.
  - **Wallet balance** (USD, `walletBalance`) — from recharges.
  - **Gifts balance** (USD, `giftsBalance`) — creator share of un‑cashed gifts.
  - **Withdrawal balance** (USD, `withdrawalBalance`) — available for bank payout.
- Buttons:
  - “Apply for monetization” → `POST /api/monetize-account`.
  - “Cashout gifts” → `POST /api/gift/cashout` (enabled only when `giftsBalance >= 50`).

### 7.2 Feed / Video Detail Screen

- If viewing **another user’s** content:
  - Show a **gift button** only if:
    - The **creator is monetized** (you can get this from user profile API).
  - On click:
    - Open a gift picker (Applause_Hands, Beating_Heart, etc.).
    - Call `POST /api/gift/send`.
    - Animate gift and update local wallet.

### 7.3 Live Stream Screen

- On join:
  - Connect Socket.IO.
  - Register gift listeners.
- Viewer:
  - Tap “Send Gift” → choose gift → emit `sendGiftLive`.
- Host:
  - Listens to `giftReceivedPersonal` for focused notifications.
  - Uses `liveGiftUpdate` to show running totals.

---

## 8. Quick Checklist for Frontend Dev

- [ ] Always send `Authorization: Bearer <JWT>` on protected endpoints.
- [ ] Use **`/api/monetize-account`** for monetization.
- [ ] Use **`/api/stripe/simpleTopUp`** (dev) or Stripe Checkout endpoints (prod) to add USD to `walletBalance`.
- [ ] Use **`/api/gift/send`** for feed/video gifting with correct `giftName`, `contextType`, `contentId`.
- [ ] Integrate Socket.IO:
  - [ ] Emit `sendGiftLive` for live gifts.
  - [ ] Handle `giftReceived`, `giftSent`, `giftError`, `giftReceivedPersonal`, `liveGiftUpdate`.
- [ ] Use **`/api/gift/received`** to show gift history.
- [ ] Use **`/api/gift/cashout`** to cashout all pending gifts (creator gets 70%, platform 30%).
- [ ] Update token / wallet UI using `senderNewTokenBalance` (after send gift), `newWalletTokens` (after recharge), `receiverGiftsBalance`, `receiverWithdrawalBalance` (after cashout).

This guide should be enough for a Flutter engineer to integrate **all wallet/monetization/gifting features** end‑to‑end with the existing backend. If you add or change any backend endpoints later, keep this file updated so the frontend team can rely on it as the single source of truth.