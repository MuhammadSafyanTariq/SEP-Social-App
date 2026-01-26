# Deep Link Implementation for SEP Media

## Overview
This implementation adds deep linking functionality to SEP Media, allowing posts to be shared externally and opened directly in the app.

## Features
- **External Sharing**: Share posts to WhatsApp, Instagram, SMS, and other apps
- **Deep Link Handling**: Open posts directly in the app via custom URL scheme
- **Fallback**: If app is not installed, users can be directed to install it

## URL Scheme
Custom scheme: `sepmedia://`

### Supported Deep Links

#### Post Links
- Format: `sepmedia://post/{postId}`
- Example: `sepmedia://post/507f1f77bcf86cd799439011`
- Opens the post detail screen for the specified post

#### Profile Links (Coming Soon)
- Format: `sepmedia://profile/{userId}`
- Example: `sepmedia://profile/507f1f77bcf86cd799439011`
- Opens the profile screen for the specified user

## How It Works

### 1. Sharing a Post
When a user taps the "Share" button on a post:
1. A dialog appears with two options:
   - **Share Outside App**: Opens the system share sheet with a deep link
   - **Share to Chat**: Share directly to app chats (existing functionality)

2. When sharing externally:
   - A deep link is generated: `sepmedia://post/{postId}`
   - Post caption is included (max 200 chars)
   - Share message includes app install instructions
   - User can share via WhatsApp, Instagram, SMS, etc.

### 2. Receiving a Deep Link
When a user taps a deep link:
1. **App Installed**:
   - App opens automatically
   - Deep link service parses the URL
   - User is navigated to the post detail screen
   
2. **App Not Installed**:
   - System prompts user to install the app
   - After installation, the link can be tapped again

## Implementation Details

### Files Created/Modified

#### New Files
1. `lib/services/deep_link_service.dart`
   - Core deep link handling service
   - URL parsing and navigation logic
   - Link generation utilities

#### Modified Files
1. `lib/feature/presentation/Home/homeScreenComponents/post_components.dart`
   - Updated share dialog UI
   - Added external share function
   - Added share_plus import

2. `android/app/src/main/AndroidManifest.xml`
   - Added intent filters for deep links
   - Supports `sepmedia://` custom scheme

3. `ios/Runner/Info.plist`
   - Added URL scheme registration
   - Supports `sepmedia://` custom scheme

4. `lib/main.dart`
   - Initialized deep link service on app startup

5. `pubspec.yaml`
   - Added `app_links: ^6.3.2` dependency

### Code Examples

#### Generate a Deep Link
```dart
import 'package:sep/services/deep_link_service.dart';

String postId = '507f1f77bcf86cd799439011';
String deepLink = DeepLinkService.generatePostLink(postId);
// Returns: sepmedia://post/507f1f77bcf86cd799439011
```

#### Generate Share Text
```dart
String shareText = DeepLinkService.generatePostShareText(
  postId,
  caption: 'Check out this amazing post!',
);
```

#### Manual Navigation (Testing)
```dart
// Test deep link handling
Uri testUri = Uri.parse('sepmedia://post/507f1f77bcf86cd799439011');
DeepLinkService.instance._handleDeepLink(testUri);
```

## Testing

### Android Testing
```bash
# Test deep link from command line
adb shell am start -W -a android.intent.action.VIEW -d "sepmedia://post/507f1f77bcf86cd799439011" com.sepmedia.app

# Or use the following URL in a browser/SMS
sepmedia://post/507f1f77bcf86cd799439011
```

### iOS Testing
```bash
# Test deep link from command line
xcrun simctl openurl booted "sepmedia://post/507f1f77bcf86cd799439011"

# Or use the following in Safari/Notes
sepmedia://post/507f1f77bcf86cd799439011
```

### Manual Testing Steps
1. Share a post using the "Share Outside App" option
2. Send the link to yourself via SMS, WhatsApp, or Email
3. Tap the link:
   - If app is installed: Opens post detail screen
   - If not installed: Shows system prompt to install

## Universal Links (Optional)
For a better user experience, you can set up Universal Links:

### Requirements
1. A web domain (e.g., sepmedia.app)
2. HTTPS hosting
3. Apple App Site Association file (iOS)
4. Android App Links verification (Android)

### Benefits
- Opens app directly without confirmation dialog
- Falls back to web page if app not installed
- More professional appearance
- Works with social media preview cards

### Implementation (When Ready)
1. Update `DeepLinkService.generatePostWebLink()` with your domain
2. Set up web hosting at that domain
3. Configure App Links in AndroidManifest
4. Create Apple App Site Association file
5. Update deep link service to handle both schemes

## Troubleshooting

### Deep Links Not Opening
1. Ensure app is installed
2. Check intent filters in AndroidManifest.xml
3. Check URL scheme in Info.plist
4. Verify deep link service is initialized in main.dart

### App Opens But Doesn't Navigate
1. Check logs for deep link parsing errors
2. Verify postId format is correct
3. Ensure post detail screen exists

### Share Dialog Not Showing
1. Check imports in post_components.dart
2. Verify share_plus package is installed
3. Run `flutter pub get`

## Future Enhancements
- [ ] Universal Links support
- [ ] Profile deep links
- [ ] Chat/Message deep links
- [ ] Store/Product deep links
- [ ] Live stream deep links
- [ ] Analytics tracking for shared links
- [ ] Link preview generation
- [ ] QR code generation for posts

## Dependencies
- `app_links: ^6.3.2` - Deep link handling
- `share_plus: ^11.0.0` - Native sharing (already installed)

## Support
For issues or questions, please contact the development team.
