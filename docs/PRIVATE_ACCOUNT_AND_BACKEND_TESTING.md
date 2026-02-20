# Private Account & Backend Integration – Testing Guide

Use this guide to verify that the app works correctly with the updated backend (private accounts, follow requests, remove follower, token packages, etc.).

---

## Prerequisites

- Backend deployed with the latest API (private account checks, remove follower, token packages).
- App points to that backend (`lib/services/networking/urls.dart` → `baseUrl`).
- Two test accounts (e.g. **User A** = private account owner, **User B** = follower/requester).

---

## 1. Private account toggle

| Step | Action | Expected |
|------|--------|----------|
| 1.1 | Log in as **User A** → Profile → **Settings**. | Settings screen opens. |
| 1.2 | In **Privacy & Security**, find **Private account** (lock icon) and subtitle: *"Only approved followers can see your posts, stories and profile"*. | Toggle is visible and clearly described. |
| 1.3 | Turn **Private account** ON. | Switch turns on; no error. |
| 1.4 | Leave Settings and re-open. | Toggle stays ON. |
| 1.5 | Turn **Private account** OFF. | Switch turns off; behaviour works for public account. |

---

## 2. Follow request flow (private account)

| Step | Action | Expected |
|------|--------|----------|
| 2.1 | **User A**: Settings → **Private account** ON. | Account is private. |
| 2.2 | **User B**: Search or open **User A**’s profile. | Profile loads. |
| 2.3 | **User B**: Tap **Link Up**. | Toast e.g. "Follow request sent"; button changes to **Requested** (disabled). |
| 2.4 | **User A**: Open **Notifications**. | Notification type "Follow request" from User B with **Approve** and **Reject**. |
| 2.4b | **User A**: **Or** Profile → tap **Requests** (when private). | **Follow requests** screen opens; list with **Approve** / **Reject** per requester. |
| 2.5 | **User A**: Tap **Approve** (notification or Follow requests screen). | Toast e.g. "Follow request approved"; notification disappears; User B is now follower. |
| 2.6 | **User B**: Open **User A**’s profile again (or refresh). | Button shows **Linked** (and **Message**). User B can see posts. |
| 2.7 | Repeat 2.2–2.3 with **User C**. Then **User A**: In notifications, tap **Reject** for User C. | Toast e.g. "Follow request rejected"; notification disappears. **User C** still sees **Requested** or can send another request later. |

---

## 3. Remove follower (immediate revoke)

| Step | Action | Expected |
|------|--------|----------|
| 3.1 | **User A** (private): Has **User B** as approved follower. **User B** can see A’s profile and posts. | — |
| 3.2 | **User A**: Profile → **Link Ups** (or Followers) → open **followers** list. | List shows User B. |
| 3.3 | **User A**: Tap **Remove** (or similar) for **User B** → confirm. | Toast: "Follower removed. They can no longer see your posts."; User B disappears from list. |
| 3.4 | **User B**: Pull-to-refresh **feed** or reopen **User A**’s profile. | A’s posts disappear from feed. Profile shows **access denied** (e.g. "Only approved followers can view this profile...") or **Link Up** again. |
| 3.5 | **User B**: Try to open **User A**’s profile again. | No access to posts/profile (backend + frontend enforce private). |

This confirms that removing a follower revokes access immediately (backend + frontend).

---

## 4. Profile visibility (private = only followers)

| Step | Action | Expected |
|------|--------|----------|
| 4.1 | **User A**: Private account, **User B** is **not** a follower (never approved or already removed). | — |
| 4.2 | **User B**: Open **User A**’s profile (e.g. from search). | Access denied screen: "Only approved followers can view this profile. Send a follow request to request access." and **Go Back**. |
| 4.3 | **User B**: Tap **Link Up** (if shown on a preview or from another entry point). | Request sent; button becomes **Requested**. |
| 4.4 | **User A**: Approve **User B**. **User B** reopens A’s profile. | Full profile and posts visible; **Linked** + **Message**. |

---

## 5. Notifications (follow request)

| Step | Action | Expected |
|------|--------|----------|
| 5.1 | **User B** sends follow request to private **User A**. | — |
| 5.2 | **User A**: Notifications. | One entry: type **Follow request**, message about User B, **Approve** and **Reject** buttons. |
| 5.3 | Tap the notification (not the buttons). | Navigates to User B’s profile. |
| 5.4 | Use **Approve** or **Reject** on another request. | Corresponding toast; that notification is removed from list. |

---

## 6. Token packages (backend alignment)

| Step | Action | Expected |
|------|--------|----------|
| 6.1 | Open **Wallet** / **Token packages** (or Buy tokens). | Only **3** packages: **$10 (1,000 tokens)**, **$20 (2,500)**, **$50 (10,000)**. No Enterprise. |
| 6.2 | Enter custom amount e.g. **15.50**. | Shows ≈ **1,550** tokens (15.50 × 100). |
| 6.3 | Select **$10** package and purchase (if wallet has balance). | Request sends `amount: 10`; success and balance update. |

---

## 7. Platform fee (no fee in UI)

| Step | Action | Expected |
|------|--------|----------|
| 7.1 | Send tokens (e.g. tip in live stream). | Success message shows tokens sent and amount received; **no** "Commission" or fee line. |

---

## 8. Deep links

| Step | Action | Expected |
|------|--------|----------|
| 8.1 | From browser or another app open: `sepmedia://notifications` or `sepmedia://pending-requests`. | App opens and shows **Notifications** screen. |

(Optional) On Android:  
`adb shell am start -a android.intent.action.VIEW -d "sepmedia://notifications" <your.package.name>`

---

## 9. Quick checklist

- [ ] Private account toggle visible and works (ON/OFF).
- [ ] **Follow requests screen**: Profile (when private) shows **Requests** count; tapping opens list of pending requesters with Approve/Reject.
- [ ] Follow request sent → **Requested**; Approve → **Linked**; Reject → request removed.
- [ ] Remove follower → toast; removed user loses access to profile/posts immediately.
- [ ] Non-follower sees access denied on private profile; message mentions "approved followers".
- [ ] Notifications: followRequest has Approve/Reject; tapping opens profile.
- [ ] Token packages: 3 packages $10/$20/$50; custom amount ≈ amount × 100 tokens.
- [ ] No commission/fee in token transfer success message.
- [ ] Deep link `sepmedia://notifications` opens Notifications.

---

## API alignment (reference)

- **Remove follower:** `POST /api/removeFollowers` with body `{ "followerId": "<userId>" }` — frontend already uses this.
- **Private account:** Frontend sends `isPrivate` in `PUT /api/update` and enforces "only approved followers" in profile visibility.
- **Follow request:** Frontend uses `approveFollowRequest`, `rejectFollowRequest`, `getPendingFollowRequests` and handles "Follow request sent" for button state.

If any step fails, check backend logs and app logs (e.g. `AppUtils.log`) for the corresponding API calls and responses.
