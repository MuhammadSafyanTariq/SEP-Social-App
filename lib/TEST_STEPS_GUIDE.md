# Test Steps — Wallet, Monetization & Gifting (per FRONTEND_INTEGRATION_GUIDE)

Use these steps to verify the Flutter app against the deployed backend. Ensure the app is pointed at the correct backend (e.g. `urls.dart` / `baseUrl`).

---

## Prerequisites

- **Two test accounts** (or more):
  - **Creator:** Should eventually be **monetized** (≥ 250 followers, account ≥ 30 days) to receive gifts.
  - **Viewer/Sender:** Used to buy coins and send gifts.
- Backend base URL and Socket.IO URL configured and reachable.
- For PayPal: use **PayPal Sandbox** accounts (buyer + merchant) if in dev.

---

## 1. Monetization (Guide §2)

**Goal:** Apply for monetization and see correct server message.

| Step | Action | Expected |
|------|--------|----------|
| 1.1 | Log in as **Creator**. Open **Profile** (own profile). | Profile screen loads. |
| 1.2 | Scroll to **Earnings / Monetization** section. | You see either **"Apply for Monetization"** (not yet monetized) or the full **Earnings** card (already monetized). |
| 1.3 | If you see **"Apply for Monetization"**, tap it. | Button shows "Applying...", then either: **(a)** Toast/success with message like *"Your account is monetized successfully"* or *"Your account is already monetized"*, or **(b)** Error toast with server message, e.g. *"Monetization request rejected: you have less followers than 250"*. |
| 1.4 | If rejected, note the message. | Message matches backend (followers / account age). No crash. |

**Backend:** `POST /api/monetize-account` with JWT; no body.

---

## 2. Wallet & Coins (Guide §3)

**Goal:** Add coins via PayPal and see balance update.

| Step | Action | Expected |
|------|--------|----------|
| 2.1 | Log in as **Viewer/Sender**. Open **Wallet** (from profile or menu). | Wallet screen shows **COINS** balance (single card). No USD balance card. |
| 2.2 | Note current **coin balance** (e.g. 0). Tap **"Add Coins"** (or similar). | PayPal top-up screen opens. |
| 2.3 | Enter amount (e.g. **10**), tap **Pay with PayPal**. | App calls backend; WebView/browser opens with PayPal checkout. |
| 2.4 | Complete PayPal approval in sandbox (log in, approve). | Redirect to backend success page; WebView closes; app shows success. |
| 2.5 | Return to **Wallet** (or stay on same screen). | **COINS** balance increased (e.g. $10 → 1000 coins). No crash. |
| 2.6 | (Optional) Open **Profile** and check any earnings/balance area. | If profile shows wallet/balance, it reflects the new state (or refreshes after a moment). |

**Backend:** `POST /api/paypal/create-order` (userId, amount); then GET `/api/paypal/process-payment?...`; success payload includes `topUpResult.newWalletTokens` and `newWalletBalance`.

---

## 3. Gifting on Feed / Video (Guide §4)

**Goal:** Send a gift on a feed post or reel; coins deduct; only monetized creators show gift option.

| Step | Action | Expected |
|------|--------|----------|
| 3.1 | Log in as **Viewer/Sender** (with enough coins). Go to **Home (feed)**. | Feed loads. |
| 3.2 | Find a post from **another user** who is **monetized**. | Post shows a **gift** icon/button and/or "X Gifts" row. |
| 3.3 | Find a post from a **non‑monetized** user (or your own). | **No** gift icon / "X Gifts" on that post. |
| 3.4 | On a **monetized** creator’s post, tap the **gift** icon. | Bottom sheet opens with gift catalog (Applause, Beating Heart, etc.) and **prices in coins**. |
| 3.5 | Select a gift (e.g. **Applause** – 1 coin). Confirm send. | Toast "Gift sent successfully"; gift animation if implemented; **coin balance decreases** by the gift cost. |
| 3.6 | Send a gift larger than your balance (e.g. VIP Jet). | Error toast, e.g. *"Insufficient tokens. Required: X, Available: Y"*. Balance unchanged. |
| 3.7 | Open **Reels**; open a **video** from a **monetized** creator. Tap gift, choose gift, send. | Same as feed: success toast, balance decreases; or insufficient-tokens error. |

**Backend:** `POST /api/gift/send` with `receiverId`, `giftName`, `contextType` (`feed` or `video`), `contentId`. Response includes `senderNewTokenBalance`.

---

## 4. Live Gifting (Guide §5)

**Goal:** Send a gift during a live stream via Socket.IO; balance updates from socket response.

| Step | Action | Expected |
|------|--------|----------|
| 4.1 | **Host:** Start a **live stream** (ensure host is **monetized**). | Live room is created; stream is visible to viewers. |
| 4.2 | **Viewer:** Join the same live as **Viewer/Sender** (with coins). | Live stream plays; UI shows "Send Gift" or gift icon. |
| 4.3 | Tap **Send Gift**; pick a gift (e.g. Beating Heart – 48 coins); send. | Toast e.g. "Gift sent successfully!"; **viewer’s coin balance** decreases (e.g. from socket `giftSent.senderNewTokenBalance`). |
| 4.4 | **Host:** Check notifications / overlay. | Host sees gift notification (e.g. `giftReceivedPersonal` / `liveGiftUpdate`). |
| 4.5 | Send a gift to a **non‑monetized** host (if you have one). | Error toast, e.g. *"You cannot send a gift because this account is not monetized"* (`giftError`). |
| 4.6 | Send a gift with **insufficient** coins. | Error toast from server; balance unchanged. |

**Backend:** Socket.IO `sendGiftLive` with `senderId`, `receiverId`, `roomId`, `giftName`. Server emits `giftSent` (with `senderNewTokenBalance`), `giftReceived`, `liveGiftUpdate`, `giftError`, etc.

---

## 5. Gift History (Guide §6.1)

**Goal:** View received gifts and optional filters.

| Step | Action | Expected |
|------|--------|----------|
| 5.1 | As **Creator** who has received gifts, open **Profile** → **Earnings** → **"View gift history"** (or equivalent). | Gift history screen opens. |
| 5.2 | Check list. | List shows received gifts (sender, gift name, amount, date, etc.). Data matches `GET /api/gift/received`. |
| 5.3 | (If UI has filters) Switch status to **active** or **cashedOut**. | List updates; request uses `status` and pagination params. |

**Backend:** `GET /api/gift/received?status=...&page=1&limit=20`.

---

## 6. Cashout Gifts (Guide §6.2)

**Goal:** Cash out when gifts balance ≥ $50; treat "No pending gifts" as success.

| Step | Action | Expected |
|------|--------|----------|
| 6.1 | As **Creator** with **Gifts balance &lt; $50**, open **Profile** → **Earnings**. | "Cashout gifts" is disabled or hidden; helper text like *"You can cash out once you have at least $50 in gifts balance."* |
| 6.2 | As **Creator** with **Gifts balance ≥ $50**, tap **"Cashout gifts"**. | Request sent; success toast; **Gifts balance** goes down; **Withdrawable** goes up (70% of cashed amount). |
| 6.3 | As Creator with **no active gifts** (e.g. already cashed out), tap **"Cashout gifts"** (if button is still shown). | Backend returns success with message like *"No pending gifts to cash out"*; app shows **friendly** message (e.g. "You have no active gifts to cash out") — **not** an error. |
| 6.4 | After cashout, open **Gift history**. | Cashed-out gifts show status or filter correctly. |

**Backend:** `POST /api/gift/cashout`; response includes `receiverGiftsBalance`, `receiverWithdrawalBalance`, etc.

---

## 7. Quick Sanity Checklist

- [ ] JWT sent as `Authorization: Bearer <token>` on all protected calls.
- [ ] **Wallet:** Single COINS balance; "Add Coins" opens PayPal; balance updates after success using `topUpResult.newWalletTokens`.
- [ ] **Monetization:** "Apply for Monetization" calls `POST /api/monetize-account`; server message shown on success/rejection.
- [ ] **Feed/Reels:** Gift icon only on **monetized** creators’ posts; gift catalog uses exact `giftName` codes; `POST /api/gift/send`; balance updates from `senderNewTokenBalance`.
- [ ] **Live:** `sendGiftLive` with correct payload; listeners for `giftSent`, `giftError`, etc.; balance updates from `giftSent.senderNewTokenBalance`.
- [ ] **Gift history:** `GET /api/gift/received` with status/page/limit.
- [ ] **Cashout:** Enabled when **gifts balance ≥ $50**; "No pending gifts" treated as success with friendly message.

---

## 8. Common Issues

| Symptom | Check |
|--------|--------|
| Gift icon never appears on posts | Backend must return `monetized: true` on the post’s user/author in feed API. |
| PayPal success but balance not updating | WebView must receive `PAYPAL_SUCCESS` and app must apply `topUpResult.newWalletTokens` (and optionally `newWalletBalance`). |
| "Insufficient tokens" when balance looks enough | Ensure UI uses same balance source as backend (`walletTokens`); refresh after PayPal or gift. |
| Live gift not updating balance | Ensure `giftSent` listener updates local profile from `senderNewTokenBalance`. |
| Cashout button always disabled | Profile API must return `giftsBalance`; cashout is enabled when `giftsBalance >= 50`. |

These test steps align with **FRONTEND_INTEGRATION_GUIDE.md** and the current Flutter implementation.
