# Firebase Hosting – Post share landing

This folder is deployed to Firebase Hosting so shared post links (e.g. from WhatsApp) work as follows:

- **App installed**: Link opens in the SEP Media app (App Links / Universal Links).
- **App not installed**: User sees a landing page that tries to open the app, then shows “Get the app” with Play Store and App Store buttons.

## Deploy

From the project root:

```bash
firebase deploy --only hosting
```

Requires Firebase CLI and `firebase login`. If the project is not linked:

```bash
firebase use sep-app-9b95e
```

## Android App Links (optional but recommended)

So that `https://sep-app-9b95e.web.app/post/ID` opens directly in the app on Android:

1. Get your app’s SHA-256 fingerprint:
   - **Play App Signing**: Play Console → Release → Setup → App integrity → App signing.
   - **Local keystore**:  
     `keytool -list -v -keystore path/to/keystore -alias your_alias | findstr SHA256`
2. Edit `public/.well-known/assetlinks.json` and replace `REPLACE_WITH_YOUR_SHA256_FINGERPRINT` with that value (e.g. `E6:5A:5D:37:...`).
3. Redeploy: `firebase deploy --only hosting`.

## iOS Universal Links

The file `public/.well-known/apple-app-site-association` is used for Universal Links. The `appID` must be your **Apple Team ID** + `.com.app.sep` (e.g. `ABCDE12345.com.app.sep`). Get Team ID from [Apple Developer](https://developer.apple.com/account) → Membership. Edit the `appID` in that file, then deploy. The app already has the Associated Domains entitlement for `applinks:sep-app-9b95e.web.app`.
