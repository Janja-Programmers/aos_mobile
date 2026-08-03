class AppRoutes {
  // Core
  static const splash = '/splash';
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
  static const passwordSecurity = '/account/security';
  static const preference = '/account/preference';
  static const userVerification = '/account/verification';
  static const activityCenter = '/account/activity';
  static const deleteAccount = '/account/delete';
  static const restoreAccount = '/account/restore';

  // Learn
  static const photoTips = '/photoTips';
  static const marketTips = '/marketTips';
  static const rankTips = '/rankTips';
  static const sellerTips = '/sellerTips';

  // Search
  static const search = '/search';

  // Maps
  static const maps = '/maps';
  static const nMaps = 'maps';
  static const mapPicker = '/maps/picker';
  static const nMapPicker = 'mapPicker';

  // Seller
  static const startSelling = '/seller';
  static const sellerVerification = '/seller/verification';
  static const sellerCustomizeStore = '/seller/customize/:sellerId';
  static const sellerStore = '/seller/store-detail/:sellerId';
  static const myStoreFront = '/seller/detail/:sellerId';
  static const sellerLocation = '/seller/location';
  static const nSellerLocation = 'sellerLocation';

  // Reports
  static const reportAdBase = '/report-ad';
  static const reportAd = '/report-ad/:adId';

  // Reviews
  static const reviewAdBase = '/review/create-review';
  static const review = '/review';
  static const createReview = '/review/create-review/:adId';

  // Ads - static paths first
  static const allAds = '/ads/all';
  static const adList = '/ads/list';
  static const myAds = '/ads/my';
  static const createAd = '/ads/create';
  static const editListing = '/ads/edit/:adId';
  static const selectCategory = '/ads/select-category';
  static const selectLocation = '/ads/select-location';

  // Ads - MOST generic dynamic route LAST
  static const adDetails = '/ads/detail/:id';

  // NAMED Route names (use pushNamed/goNamed)
  static const nSplash = 'splash';
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
  static const nPasswordSecurity = 'passwordSecurity';
  static const nPreference = 'preference';
  static const nUserVerification = 'userVerification';
  static const nActivityCenter = 'activityCenter';
  static const nDeleteAccount = 'deleteAccount';
  static const nRestoreAccount = 'restoreAccount';

  static const nMyAds = 'myAds';
  static const nCreateAd = 'createAd';
  static const nEditListing = 'editListing';
  static const nSelectCategory = 'selectCategory';
  static const nSelectLocation = 'selectLocation';

  static const nTerms = 'terms';
  static const nPrivacy = 'privacy';

  static const nSellerCustomizeStore = 'sellerCustomizeStore';
  static const nMyStoreFront = 'myStoreFront';
  static const nSellerStore = 'sellerStore';
  static const nSellerVerification = 'sellerVerification';
  static const nStartSelling = 'seller';
  static const nReview = 'review';
  static const nReportAd = 'reportAd';
  static const nCreateReview = 'createReview';

  // CONNECT routes
  static const connect = '/connect';
  static const nConnect = 'connect';

  static const connectNewConversation = '/connect/new';
  static const nConnectNewConversation = 'connectNewConversation';

  static const connectStarredMessages = '/connect/starred';
  static const nConnectStarredMessages = 'connectStarredMessages';

  static const connectChatSettings = '/connect/chat-settings';
  static const nConnectChatSettings = 'connectChatSettings';

  static const connectStoryCreate = '/connect/story/create';
  static const nConnectStoryCreate = 'connectStoryCreate';

  static const connectStoryConfirm = '/connect/story/confirm';
  static const nConnectStoryConfirm = 'connectStoryConfirm';

  static const connectStoryViewer = '/connect/story/:storyId';
  static const nConnectStoryViewer = 'connectStoryViewer';

  // CHATLIST routes
  static const chatsList = '/chats/list';
  static const nChatsList = 'chatsList';

  // CHAT routes
  static const messages = '/chats/view/:conversationId';
  static const nMessages = 'chatMessage';

  // CHATMESSAGE routes
  static const newMessage = '/chats/new';
  static const nNewMessage = 'chatNewMessage';

  // SHORTS routes
  static const nShortDetail = 'short-detail';
  static const shortDetail = '/shorts/detail';

  static const feeds = '/feeds';
  static const nFeeds = 'feeds';

  // CREATE SHORT route
  static const postShort = '/shorts/post';
  static const nPostShort = 'postShort';

  static const postShortDetails = '/shorts/post/details';
  static const nPostShortDetails = 'postShortDetail';

  // CALLS routes
  static const callsList = '/calls/list';
  static const nCallsList = 'callsList';

  static const newCall = '/calls/new';
  static const nNewCall = 'newCall';

  static const callSession = '/calls/session';
  static const nCallSession = 'callSession';

  // LIVE routes
  static const liveRoom = '/live/room';
  static const nLiveRoom = 'liveRoom';

  static const goLive = '/live/goLive';
  static const nGoLive = 'goLive';

  // CONTACT routes
  static const contact = '/contact';
  static const nContact = 'contact';

  // NAVIGATION routes
  static const notification = '/notification';
  static const nNotification = 'notification';

  // PROFILE routes
  static const profile = '/profile';
  static const nProfile = 'profile';

  //SOCIALCONNECTIONS routes
  static const socialConnections = '/social/connections';
  static const nSocialConnections = 'social-connections';
  static const socialUserSearch = '/social/search';
  static const nSocialUserSearch = 'social-user-search';
  static const blockedUsers = '/social/blocked';
  static const nBlockedUsers = 'blocked-users';
}
