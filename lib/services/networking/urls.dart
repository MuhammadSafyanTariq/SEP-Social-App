// const String baseUrl = 'https://api.postman.com';

// const String baseUrl = 'https://1sg5b0hc-3003.inc1.devtunnels.ms';
// const String baseUrl = 'http://85.31.234.205:4004';
// const String baseUrl = 'https://rmpnyn-4004.csb.app';
const String baseUrl = 'http://67.225.241.58:4004';
const String _apiUrl = baseUrl;
// const String _collectionUser = '/user';

//////////////////////////////agora //////////
// const String agoraAppId = "85968ab5e1cf498a9cebaba29d4dcac2";
const String agoraAppId = "1d34f3c04fe748049d660e3b23206f7a";
// const String agoraToken = "007eJxTYFjItXG+s6fHn55t315JeZhGbPP48nexafqOvqXmR45pNrAoMFiYWppZJCaZphomp5lYWiRaJqcmJSYlGlmmmKQkJyYbrZBWyWgIZGQw9jNjYWSAQBCfmaE4tYCBAQBx+B9Z";
const String agoraToken = "af707d9cf2ee4819b544571d71a3db93";
// const String agoraToken = "ca274cfde6564e7ba8a88aae08025a06";

// ============================================================================
// GOOGLE ADMOB CONFIGURATION
// ============================================================================
// CURRENTLY USING: Production AdMob Account
// Publisher ID: ca-app-pub-5207710549768234
// App Package: com.app.sep
//
// Note: If ads don't show immediately after updating:
// 1. New ad units can take up to 24 hours to start serving ads
// 2. Verify the app is registered in AdMob with package: com.app.sep
// 3. Check that Application ID is correctly set in AndroidManifest.xml
// 4. Ensure billing/payment info is set up in AdMob account
//
// To revert to test ads for development, use:
// Android: ca-app-pub-3940256099942544/6300978111
// iOS: ca-app-pub-3940256099942544/2934735716
// ============================================================================

// http://85.31.234.205:4004/data/user/0/com.app.sep/cache/65b325a8-8233-4fbc-99c6-81b5fe8bfd22/IMG_1609079159072.jpg
class _Collection {
  static const String _baseUrl = '/api';
  static const String api = '$_baseUrl';
  // static const String _baseUrl = '${Urls.appApiBaseUrl}/api';
  static const String post = '$_baseUrl/post';
  static const String postComment = '$_baseUrl/likeComment';
  static const String product = '$_baseUrl';
  static const String profileBrowser = '$_baseUrl';
  static const String stripe = '$_baseUrl${"/stripe"}';
  static const String paypal = '$_baseUrl${"/paypal"}';
}

class Urls {
  // static const String baseUrlApi = _apiUrl;
  static const String appApiBaseUrl = _apiUrl;

  // ============================================================================
  // GOOGLE ADMOB AD UNIT IDs
  // ============================================================================
  static const String AdroidAds =
      "ca-app-pub-5207710549768234/6670450168"; // Production Ad
  static const String IosAds =
      "ca-app-pub-5207710549768234/6670450168"; // Production Ad
  // ============================================================================

  //user collection

  static const String emailvalid = '/api/checkEmail';

  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String forgotPassword = '/api/forgetPassword';
  static const String getUserDetails = '/api/getUser';
  static const String verifyOtp = '/api/verifyOtp';
  static const String resetPassword = '/api/resetPassword';
  static const String otpVerification = '/api/verifyOtp';
  static const String changeResetPassword = '/api/changeRsetPassword';
  static const String googleSocialLogin = '/api/socialLogin';
  static const String changepassword = '/api/changePassword';
  static const String updateProfile = '/api/update';
  static const String getcategory = '/api/category';

  static const String contactus = '/api/contact_us';
  static const String feedbackk = '/api/contact_us/feedBack';
  static const String faq = '/api/FAQ/getFaqInfo';
  static const String notification = '/api/getNotification';
  static const String sendPushNotification = '/api/sendPushNotification';

  static const String logout = '/api/logout';
  static const String uploadPhoto = '/fileupload';

  static const String Createpost = _Collection.post;
  static const String getPostList = '${_Collection.post}/getPostList';
  static const String editPost = '${_Collection.post}';
  static const String deleteUserPost = _Collection.post;
  static const String globalPostList = '${_Collection.post}/postListing';
  static const String updatePollAction = '${_Collection.post}/votePolles';
  static const String profileData = '${_Collection.post}/getProfileData';
  // static const String getFollowingList = '${_Collection.post}/getProfileData';
  static const String getFollowingList = '${_Collection.api}/getFollowingList';
  static const String removeFollowers = '${_Collection.api}/removeFollowers';
  static const String videoCount = '${_Collection.post}/videoCount';
  // ?userId=67a34e3bc7aea8a744b35519&type=following

  static const String deleteNotification =
      '${_Collection.api}/deleteNotification';

  static const String likepost = '${_Collection.postComment}/like';
  static const String commentpost = '${_Collection.postComment}/comment';
  static const String commentslists = '${_Collection.postComment}/getComments';
  static const String likeslists = '${_Collection.postComment}/getLikeList';

  static const String getProducts = '${_Collection.product}/product';

  static const String followUnfollowUserRequest =
      '${_Collection.profileBrowser}/followUnfollowUser';
  // {"followUserId":"679b081d3cdfb86bfb8d705f"}
  //Authorization

  static const String blockUnblockUserRequest =
      '${_Collection.profileBrowser}/blockUnblockUsers';
  // {"blockUserId":"679b081d3cdfb86bfb8d705f"}
  //Authorization

  static const String getBlockedUserList =
      '${_Collection.profileBrowser}/getBlockUsersList';
  // Authorization

  static const String reportUserRequest =
      '${_Collection.profileBrowser}/reportUser';
  static const String reportPostRequest = '${_Collection.post}/reportPost';
  //Authorization

  // /api/likeComment/comment?id=67b881c991120994ca6462a0
  // delete methos

  static const String deleteAccount = '/api/deleteAccount';
  static const String changePassword = '/changePassword';

  static const String termsAndCondition = '/api/pages/getPageInfo';

  static const String imageupload = '/fileUpload';
  static const String searchUser = '/api/getAllUsers?search';
  static const String getUserAgoraToken = '/api/agora/generate-token';

  static const String getPollList = '/api/post/getPoolList';

  static const String inviteFriendToLiveStream = '/api/inviteUserLive';

  // Agora Cloud Recording
  static const String agoraRecordingAcquire = '/api/agora/recording/acquire';
  static const String agoraRecordingStart = '/api/agora/recording/  ';
  static const String agoraRecordingStop = '/api/agora/recording/stop';

  // core.....

  static const String uploadFile = '/fileUpload';

  ///////////  Strip   ////////////

  static const String createAccountStripe =
      '${_Collection.stripe}/createAccount';
  static const String token = '${_Collection.stripe}/token';
  static const String getCardList = '${_Collection.stripe}/getCardList';
  static const String paymentTransactionList =
      '${_Collection.stripe}/paymentTransactions';
  static const String deleteCard = '${_Collection.stripe}/deleteCard';
  static const String payment = '${_Collection.stripe}/payment';

  static const String topUpWallet = '${_Collection.stripe}/topUpWallet';
  static const String createBankAccountToken =
      '${_Collection.stripe}/createBankAccountToken';
  static const String payoutToBank = '${_Collection.stripe}/payout-to-bank';
  static const String addBankAccountToCustomer =
      '${_Collection.stripe}/addBankAccountToCustomer';
  static const String addBankAccountToConnectedAccount =
      '${_Collection.stripe}/addBankAccountToConnectedAccount';
  static const String getExternalBankAccounts =
      '${_Collection.stripe}/getExternalBankAccounts';
  static const String createAccountLink =
      '${_Collection.stripe}/createAccountLink';
  static const String topUpAccount = '${_Collection.stripe}/topUpAccount';

  static const String moneyWalletTransaction = '/api/transactions';

  ///////////  PayPal   ////////////

  static const String paypalCreateOrder = '${_Collection.paypal}/create-order';
  static const String paypalProcessPayment =
      '${_Collection.paypal}/process-payment';
  static const String paypalCancel = '${_Collection.paypal}/cancel';

  // Token Purchase
  static const String tokenPurchase = '/api/tokenPurchase/purchase';
  static const String customTokenPurchase = '/api/tokenPurchase/custom';
  static const String deductBalance = '/api/tokenPurchase/deduct-balance';
  static const String deductTokens = '/api/tokenPurchase/deduct-tokens';

  // Game Tokens (deprecated - use deductTokens instead)
  static const String deductGameTokens = '/api/game/deduct-tokens';

  // User Product
  static const String userProduct = '/api/user-product';
  static const String getAllUserProducts = '/api/user-product/all';

  // Shop/Store
  static const String shop = '/api/shop';
  static const String getMyShop = '/api/shop/my-shop';

  // Get shop by ID
  static String getShopById(String shopId) => '/api/shop/$shopId';

  // Delete shop by ID
  static String deleteShop(String shopId) => '/api/shop/$shopId';

  // Orders
  static const String sellerOrders = '/api/order/seller-orders';

  // Jobs
  static const String jobs = '/api/jobs';
  static String getJobById(String jobId) => '/api/jobs/$jobId';
  static String deleteJob(String jobId) => '/api/jobs/$jobId';

  // Referral
  static const String referralStatus = '/api/referral/status';
  static const String referralParticipate = '/api/referral/participate';
  static const String referralLeaderboard = '/api/referral/leaderboard';
  static const String referralWinners = '/api/referral/winners';

  // Helper method to convert relative URLs to full URLs
  static String getFullImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url; // Already a full URL
    }
    // Add base URL if it's a relative path
    return '$appApiBaseUrl$url';
  }
}
