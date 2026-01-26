import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/postDetail/post_deeplink_loader_screen.dart';
import 'package:sep/utils/appUtils.dart';

/// Deep Link Service
/// Handles incoming deep links for the app
/// Supports: sepmedia://post/{postId}
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static DeepLinkService get instance => _instance;

  final AppLinks _appLinks = AppLinks();
  bool _isInitialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;
  String? _pendingPostId;

  /// Initialize deep link handling
  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey}) async {
    if (_isInitialized) return;

    _navigatorKey = navigatorKey;

    try {
      AppUtils.log('🔗 Initializing Deep Link Service...');

      // Handle deep link when app is already open
      _appLinks.uriLinkStream.listen((Uri? uri) async {
        if (uri != null) {
          AppUtils.log('🔗 Received deep link (app running): $uri');
          await _handleDeepLink(uri);
        }
      }, onError: (Object err) {
        AppUtils.log('🔗 Error handling deep link: $err');
      });

      // Get the initial link if app was opened from a deep link
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        AppUtils.log('🔗 App opened with deep link: $initialUri');
        // Important: Splash screen also waits ~3 seconds before routing.
        // We store the pending postId immediately, and try opening after a short delay.
        Future.delayed(const Duration(seconds: 4), () async {
          await _handleDeepLink(initialUri);
        });
      }

      _isInitialized = true;
      AppUtils.log('✅ Deep Link Service initialized');
    } catch (e) {
      AppUtils.log('❌ Error initializing Deep Link Service: $e');
    }
  }

  /// Called from screens like Home after app is ready.
  /// If a deep link arrived during splash/login, this will open it.
  Future<void> tryOpenPendingPost() async {
    final postId = _pendingPostId;
    if (postId == null || postId.isEmpty) return;
    await _openPostById(postId);
  }

  /// Handle incoming deep link
  Future<void> _handleDeepLink(Uri uri) async {
    AppUtils.log('🔗 Processing deep link: $uri');
    AppUtils.log('   Scheme: ${uri.scheme}');
    AppUtils.log('   Host: ${uri.host}');
    AppUtils.log('   Path: ${uri.path}');
    AppUtils.log('   Query: ${uri.query}');

    try {
      // Handle different deep link types
      if (uri.host == 'post' || uri.pathSegments.contains('post')) {
        await _handlePostDeepLink(uri);
      } else if (uri.host == 'profile' || uri.pathSegments.contains('profile')) {
        _handleProfileDeepLink(uri);
      } else {
        AppUtils.log('⚠️ Unknown deep link type');
        AppUtils.toast('Link opened');
      }
    } catch (e) {
      AppUtils.log('❌ Error processing deep link: $e');
      AppUtils.toastError('Failed to open link');
    }
  }

  /// Handle post deep link: sepmedia://post/{postId}
  Future<void> _handlePostDeepLink(Uri uri) async {
    String? postId;

    AppUtils.log('🔍 Parsing post ID from deep link...');
    AppUtils.log('   URI pathSegments: ${uri.pathSegments}');
    AppUtils.log('   URI queryParameters: ${uri.queryParameters}');

    // Try to get post ID from different URI formats
    if (uri.pathSegments.isNotEmpty) {
      // Format: sepmedia://post/123 or sepmedia://post?id=123
      if (uri.pathSegments.contains('post')) {
        final postIndex = uri.pathSegments.indexOf('post');
        if (postIndex + 1 < uri.pathSegments.length) {
          postId = uri.pathSegments[postIndex + 1];
          AppUtils.log('   📍 PostId from pathSegments[post+1]: $postId');
        }
      } else {
        postId = uri.pathSegments.last;
        AppUtils.log('   📍 PostId from pathSegments.last: $postId');
      }
    }

    // Fallback to query parameter
    if (postId == null || postId.isEmpty) {
      postId = uri.queryParameters['id'] ?? uri.queryParameters['postId'];
      AppUtils.log('   📍 PostId from query params: $postId');
    }

    if (postId == null || postId.isEmpty) {
      AppUtils.log('⚠️ No post ID found in deep link');
      AppUtils.toastError('Invalid post link');
      return;
    }

    AppUtils.log('✅ Parsed postId: $postId');
    AppUtils.log('📬 Opening post with ID: $postId');

    // Always store, so we can open later from HomeScreen if routing clears navigation.
    _pendingPostId = postId;

    // Try opening now (if possible). If Splash clears routes, HomeScreen will retry.
    await _openPostById(postId);
  }

  Future<void> _openPostById(String postId) async {
    // Guard
    final navKey = _navigatorKey;
    if (navKey == null) return;

    // Wait until navigator is available (app might still be starting up)
    for (int i = 0; i < 10; i++) {
      if (navKey.currentState != null && navKey.currentContext != null) break;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (navKey.currentState == null || navKey.currentContext == null) {
      AppUtils.log('⚠️ Navigator not ready yet; will retry from HomeScreen');
      return;
    }

    // Push a loader that fetches the post and then opens PostDetailScreen.
    try {
      AppUtils.log('✅ Pushing PostDeepLinkLoaderScreen for postId: $postId');
      navKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => PostDeepLinkLoaderScreen(postId: postId),
        ),
      );
    } catch (e) {
      AppUtils.log('❌ Failed to push deeplink loader: $e');
    }
  }

  /// Handle profile deep link: sepmedia://profile/{userId}
  void _handleProfileDeepLink(Uri uri) {
    String? userId;

    if (uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.contains('profile')) {
        final profileIndex = uri.pathSegments.indexOf('profile');
        if (profileIndex + 1 < uri.pathSegments.length) {
          userId = uri.pathSegments[profileIndex + 1];
        }
      } else {
        userId = uri.pathSegments.last;
      }
    }

    if (userId == null || userId.isEmpty) {
      userId = uri.queryParameters['id'] ?? uri.queryParameters['userId'];
    }

    if (userId == null || userId.isEmpty) {
      AppUtils.log('⚠️ No user ID found in deep link');
      AppUtils.toastError('Invalid profile link');
      return;
    }

    AppUtils.log('👤 Opening profile with ID: $userId');
    AppUtils.toast('Opening profile...');
    // TODO: Navigate to profile screen
    // Get.to(() => ProfileScreen(userId: userId!));
  }

  /// Generate share link for a post
  static String generatePostLink(String postId) {
    // Use custom scheme for deep linking
    return 'sepmedia://post/$postId';
  }

  /// Generate universal link for a post (if you have a web domain)
  /// This would open in browser if app is not installed
  static String generatePostWebLink(String postId) {
    // Replace with your actual domain
    return 'https://sepmedia.app/post/$postId';
  }

  /// Generate share text with link
  static String generatePostShareText(String postId, {String? caption}) {
    final link = generatePostLink(postId);
    if (caption != null && caption.isNotEmpty) {
      return 'Check out this post on SEP Media!\n\n"$caption"\n\nOpen in app: $link';
    }
    return 'Check out this post on SEP Media!\n\nOpen in app: $link';
  }
}
