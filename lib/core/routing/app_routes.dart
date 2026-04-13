class AppRoutes {
  // Core
  static const String splash = '/splash';
  static const home = '/';
  static const categories = '/categories';
  static const notifications = '/notifications';
  static const onboarding = '/onboarding';

  // Legal
  static const terms = '/terms';
  static const privacy = '/privacy';

  // Auth
  static const login = '/login';
  static const register = '/register';
  static const verifyOtp = '/verify-otp';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // Account
  static const account = '/account';
  static const updateProfile = '/account/update-profile';
  static const passwordSecurity = '/account/security';
  static const preference = '/account/preference';

  // Learn
  static const photoTips = '/photoTips';
  static const marketTips = '/marketTips';
  static const rankTips = '/rankTips';
  static const sellerTips = '/sellerTips';

  // Search
  static const search = '/search';

  // Seller
  static const startSelling = '/seller';
  static const sellerVerification = '/seller/verification';
  static const sellerCustomizeStore = '/seller/customize/:sellerId';
  static const sellerStore = '/seller/detail/:sellerId';

  // Reports
  static const reportAdBase = '/report-ad';
  static const reportAd = '/report-ad/:adId';

  // Reviews
  static const reviewAdBase = '/review/create-review';
  static const review = '/review';
  static const createReview = '/review/create-review/:adId';

  // Chat
  static const chats = '/chats';
  static const messages = '/chats/message/:conversationId';

  // Ads - static paths first
  static const allAds = '/ads/all';
  static const adList = '/ads/list';
  static const myAds = '/ads/my';
  static const createAd = '/ads/create';
  static const selectCategory = '/ads/select-category';
  static const selectLocation = '/ads/select-location';

  // Ads - MOST generic dynamic route LAST
  static const adDetails = '/ads/detail/:id';

  // NAMED Route names (use pushNamed/goNamed)
  static const String nSplash = 'splash';
  static const nHome = 'home';
  static const nOnboarding = 'onboarding';
  static const nAdList = 'adList';
  static const nAllAds = 'allAds';
  static const nAdDetails = 'adDetails';
  static const nPhotoTips = 'photoTips';
  static const nMarketTips = 'marketTips';
  static const nRankTips = 'rankTips';
  static const nSellerTips = 'sellerTips';

  static const nSearch = 'search';

  static const nCategories = 'categories';
  static const nNotifications = 'notifications';

  static const nLogin = 'login';
  static const nRegister = 'register';
  static const nVerifyOtp = 'verifyOtp';
  static const nForgotPassword = 'forgotPassword';
  static const nResetPassword = 'resetPassword';

  static const nAccount = 'account';
  static const nUpdateProfile = 'updateProfile';
  static const nPasswordSecurity = 'passwordSecurity';
  static const nPreference = 'preference';

  static const nMyAds = 'myAds';
  static const nCreateAd = 'createAd';
  static const nSelectCategory = 'selectCategory';
  static const nSelectLocation = 'selectLocation';

  static const nTerms = 'terms';
  static const nPrivacy = 'privacy';

  static const nSellerCustomizeStore = 'sellerCustomizeStore';
  static const nSellerStore = 'sellerStore';
  static const nSellerVerification = 'sellerVerification';
  static const nStartSelling = 'seller';
  static const nReview = 'review';
  static const nReportAd = 'reportAd';
  static const nCreateReview = 'createReview';

  static const nChats = 'chats';
  static const nMessages = 'chatMessage';

  // SHORTS routes
  static const String shorts = '/shorts';
  static const String nShorts = 'shorts';

  // CREATE SHORT
  static const String createShort = '/shorts/create';
  static const String nCreateShort = 'createShort';

  // CALLS routes
  static const String calls = '/calls';
  static const String nCalls = 'calls';

  static const String incomingCall = '/calls/incoming';
  static const String nIncomingCall = 'incomingCall';

  static const String outgoingCall = '/calls/outgoing';
  static const String nOutgoingCall = 'outgoingCall';

  static const String activeCall = '/calls/active';
  static const String nActiveCall = 'activeCall';

  static const String rejectedCall = '/calls/rejected';
  static const String nRejectedCall = 'rejectedCall';

  static const String callNotAnswered = '/calls/unanswered';
  static const String nCallNotAnswered = 'unansweredCall';

  // LIVE routes
  static const String liveRoom = '/live/room';
  static const String nLiveRoom = 'liveRoom';

  // static const String liveLoading = '/live/loading';
  // static const String nLiveLoading = 'liveLoading';
  // static const String liveEnded = '/live/ended';
  // static const String nLiveEnded = 'liveEnded';
  // static const String liveError = '/live/error';
  // static const String nLiveError = 'liveError';

  // CONTACT routes
  static const String contact = '/contact';
  static const String nContact = 'contact';
}
