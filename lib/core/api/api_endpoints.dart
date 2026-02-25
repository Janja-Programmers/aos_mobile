class ApiEndpoints {
  // Authentication Endpoints
  static final String loginEndpoint = '/api/method/aos.api.auth.login';
  static final String registerEndpoint = '/api/method/aos.api.auth.register';
  static final String verifyOtpEndpoint =
      '/api/method/aos.api.auth.verify_email_otp';
  static final String resendOtpEndpoint =
      '/api/method/aos.api.auth.resend_email_otp';
  static final String forgotPasswordRequestEndpoint =
      '/api/method/aos.api.auth.forgot_password_request';
  static final String forgotPasswordVerifyOtpEndpoint =
      '/api/method/aos.api.auth.forgot_password_verify_otp';
  static final String forgotPasswordResetEndpoint =
      '/api/method/aos.api.auth.forgot_password_reset';
  static final String meEndpoint = '/api/method/aos.api.auth.me';
  static final String logoutEndpoint = '/api/method/aos.api.auth.logout';
  static final String changePasswordEndpoint =
      '/api/method/aos.api.auth.change_password';
  static final String googleLoginEndpoint =
      '/api/method/aos.api.auth.google_login';

  // Accounts Endpoints
  static final String getProfileEndpoint =
      '/api/method/aos.api.accounts.get_profile';
  static final String updateProfileEndpoint =
      '/api/method/aos.api.accounts.update_profile';
  static final String uploadFileEndpoint = '/api/method/upload_file';

  // Catalog Endpoints
  static final String getCategoriesEndpoint =
      '/api/method/aos.api.catalog.get_categories';

  // Ads / Listings Endpoints
  static final String getLocationsEndpoint =
      '/api/method/aos.api.localization.get_locations';
  static final String getCategorySchemaEndpoint =
      '/api/method/aos.api.attributes.get_category_schema';
  static final String createAdEndpoint = '/api/method/aos.api.ads.create_ad';
  static final String saveAdDraftEndpoint =
      '/api/method/aos.api.ads.save_ad_draft';

  // Reviews Endpoints
  static final String createAdReviewEndpoint =
      '/api/method/aos.api.reviews.create_review';
  static final String getAdReviewsEndpoint =
      '/api/method/aos.api.reviews.list_reviews';
  static final String toggleAdReviewEndpoint =
      '/api/method/aos.api.reviews.toggle_reaction';

  // Wishlist Endpoints
  static final String listWishlistEndpoint =
      '/api/method/aos.api.wishlist.list_wishlist';
  static final String toggleWishlistEndpoint =
      '/api/method/aos.api.wishlist.toggle_wishlist';

  // Read Ads
  static final String listAdsEndpoint = '/api/method/aos.api.ads.list_ads';
  static final String myAdsEndpoint = '/api/method/aos.api.ads.my_ads';
  static final String getAdEndpoint = '/api/method/aos.api.ads.get_ad';

  // Seller Endpoints
  static final String getSellerEndpoint =
      '/api/method/aos.api.sellers.get_seller';
  static final String toggleSellerEndpoint =
      '/api/method/aos.api.sellers.toggle_follow';

  // Localization Endpoints
  static final String getLocaleBundleEndpoint =
      '/api/method/aos.api.localization.get_locale_bundle';
  static final String getMyPreferencesEndpoint =
      '/api/method/aos.api.accounts.get_my_preference';
  static final String updatePreferencesEndpoint =
      '/api/method/aos.api.accounts.update_my_preference';
}
