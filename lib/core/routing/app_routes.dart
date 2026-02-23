class AppRoutes {
  // Core
  static const home = '/';
  static const categories = '/categories';
  static const notifications = '/notifications';

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

  // Search
  static const search = '/search';

  // Ads - static paths first
  static const allAds = '/ads/all';
  static const adList = '/ads/list';
  static const myAds = '/ads/my';
  static const createAd = '/ads/create';
  static const selectCategory = '/ads/select-category';
  static const selectLocation = '/ads/select-location';

  // Ads - MOST generic dynamic route LAST
  static const adDetails = '/ads/detail/:id';

  // ✅ Route names (use pushNamed/goNamed)
  static const nHome = 'home';
  static const nAdList = 'adList';
  static const nAllAds = 'allAds';
  static const nAdDetails = 'adDetails';
  static const nPhotoTips = 'photoTips';
  static const nMarketTips = 'marketTips';
  static const nRankTips = 'rankTips';

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
}
