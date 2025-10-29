// const String baseUrl = 'https://api.postman.com';

// const String baseUrl = 'https://1sg5b0hc-3003.inc1.devtunnels.ms';
// const String baseUrl = 'http://85.31.234.205:4004';
// const String baseUrl = 'https://rmpnyn-4004.csb.app';
// const String baseUrl = 'http://67.225.241.58:4004';
const String baseUrl = 'http://67.225.241.58:4004';

const String _apiUrl = baseUrl;
// const String _collectionUser = '/user';

//////////////////////////////agora //////////
// const String agoraAppId = "85968ab5e1cf498a9cebaba29d4dcac2";
const String agoraAppId = "1d34f3c04fe748049d660e3b23206f7a";
// const String agoraToken = "007eJxTYFjItXG+s6fHn55t315JeZhGbPP48nexafqOvqXmR45pNrAoMFiYWppZJCaZphomp5lYWiRaJqcmJSYlGlmmmKQkJyYbrZBWyWgIZGQw9jNjYWSAQBCfmaE4tYCBAQBx+B9Z";
const String agoraToken = "af707d9cf2ee4819b544571d71a3db93";
// const String agoraToken = "ca274cfde6564e7ba8a88aae08025a06";

const String AdroidAds = "ca-app-pub-3940256099942544/6300978111";
const String IosAds = "ca-app-pub-3940256099942544/2934735716";

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
}

class Urls {
  // static const String baseUrlApi = _apiUrl;
  static const String appApiBaseUrl = _apiUrl;

  // Helper method to convert relative image paths to absolute URLs
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // If it's a relative path starting with /, prepend base URL
    if (imagePath.startsWith('/')) {
      return '$baseUrl$imagePath';
    }

    // Otherwise, prepend base URL with /
    return '$baseUrl/$imagePath';
  }

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

  // User Product Management
  static const String createUserProduct = '/api/user-product';
  static const String updateUserProduct = '/api/user-product'; // PUT with ID
  static const String deleteUserProduct = '/api/user-product'; // DELETE with ID
  static const String getUserProducts =
      '/api/user-product'; // GET user's products

  // Public Product Endpoints
  static const String getAllProducts =
      '/api/user-product/all'; // GET all products from all users with pagination
  static const String getMyProducts =
      '/api/user-product/my-products'; // GET authenticated user's products with pagination
  static const String getProductsByShop =
      '/api/user-product/shop'; // GET products by shop ID
  static const String getProductDetails =
      '/api/user-product'; // GET single product by ID

  // Shop Management
  static const String createShop = '/api/shop';
  static const String updateShop = '/api/shop'; // PUT with ID
  static const String deleteShop = '/api/shop'; // DELETE /{shop_id}
  static const String getMyShop =
      '/api/shop/my-shop'; // GET authenticated user's shop

  // Public Shop Endpoints
  static const String getAllShops =
      '/api/shop'; // GET all shops with pagination
  static const String getShopById = '/api/shop'; // GET shop by ID

  // Order Management
  static const String createOrder = '/api/order/create';
  static const String getMyOrders = '/api/order/my-orders'; // GET buyer orders
  static const String getSellerOrders =
      '/api/order/seller-orders'; // GET seller orders
  static const String acceptOrder =
      '/api/order/accept'; // POST with orderId in body
  static const String rejectOrder =
      '/api/order/reject'; // POST with orderId in body
  static const String markShipped =
      '/api/order/mark-shipped'; // POST with orderId and trackingNumber
  static const String updateOrder = '/api/order'; // PUT with ID
  static const String getOrderById = '/api/order'; // GET with ID
  static const String cancelOrder =
      '/api/order/cancel'; // POST with orderId in body
  static const String markOrderCompleted =
      '/api/order/mark-completed'; // POST with orderId in body

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
  static const String agoraRecordingStart = '/api/agora/recording/start';
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

  // Token Purchase
  static const String tokenPurchase = '/api/tokenPurchase/purchase';
}
