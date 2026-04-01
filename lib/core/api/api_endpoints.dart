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
  static final String appleLoginEndpoint =
      '/api/method/aos.api.auth.apple_login';

  // Accounts Endpoints
  static final String getProfileEndpoint =
      '/api/method/aos.api.accounts.get_profile';
  static final String updateProfileEndpoint =
      '/api/method/aos.api.accounts.update_profile';
  static final String uploadFileEndpoint = '/api/method/upload_file';
  static final String deleteFileEndpoint =
      '/api/method/aos.api.files.delete_file';
  static final String removeBackgroundEndpoint =
      '/api/method/aos.api.files.remove_background';

  // Catalog Endpoints
  static final String getCategoriesEndpoint =
      '/api/method/aos.api.catalog.get_categories';
  static final String getCategorySchemaEndpoint =
      '/api/method/aos.api.catalog.get_category_schema';

  // Ads / Listings Endpoints
  static final String getLocationsEndpoint =
      '/api/method/aos.api.localization.get_locations';
  static final String createAdEndpoint = '/api/method/aos.api.ads.create_ad';
  static final String upsertAdDraftEndpoint =
      '/api/method/aos.api.ads.upsert_ad_draft';
  static final String getAdDraftEndpoint =
      '/api/method/aos.api.ads.get_my_ad_draft';
  static final String listAdDraftsEndpoint =
      '/api/method/aos.api.ads.list_my_ad_drafts';
  static final String submitAdDraftEndpoint =
      '/api/method/aos.api.ads.submit_ad_draft';
  static final String setAdStatusEndpoint =
      '/api/method/aos.api.ads.set_ad_status';
  static final String updateAdEndpoint = '/api/method/aos.api.ads.update_ad';

  // Report Endpoints
  static final String listReportReasonsEndpoint =
      '/api/method/aos.api.reports.list_report_reasons';
  static final String reportAdEndpoint =
      '/api/method/aos.api.reports.report_ad';

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
  static final String myAdsEndpoint = '/api/method/aos.api.ads.list_my_ads';
  static final String getAdEndpoint = '/api/method/aos.api.ads.get_ad';
  static final String getMyAdEndpoint = '/api/method/aos.api.ads.get_my_ad';

  // Seller Endpoints
  static final String getSellerEndpoint =
      '/api/method/aos.api.sellers.get_seller_profile';
  static final String toggleSellerEndpoint =
      '/api/method/aos.api.sellers.toggle_follow';
  static final String updateMySellerEndpoint =
      '/api/method/aos.api.sellers.update_my_seller';

  // Localization Endpoints
  static final String getLocaleBundleEndpoint =
      '/api/method/aos.api.localization.get_locale_bundle';
  static final String getMyPreferencesEndpoint =
      '/api/method/aos.api.accounts.get_my_preference';
  static final String updatePreferencesEndpoint =
      '/api/method/aos.api.accounts.update_my_preference';
}
