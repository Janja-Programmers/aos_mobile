class AppRoutes {
  static const home = '/';
  static const categories = '/categories';
  static const notifications = '/notifications';
  static const login = '/login';
  static const register = '/register';
  static const verifyOtp = '/verify-otp';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const account = '/account';
  static const updateProfile = '/account/update-profile';
  static const passwordSecurity = '/account/security';
  static const preference = '/account/preference';
  static const terms = '/terms';
  static const privacy = '/privacy';

  // Ads / Listings
  static const adList = '/ads/list';
  static const createAd = '/ads/create';
  static const myAds = '/ads/my';

  static const selectCategory = '/ads/select-category';
  static const selectLocation = '/ads/select-location';

  static const adDetails = '/ads/:id';
  static String adDetailsPath(String id) => '/ads/$id';
}
