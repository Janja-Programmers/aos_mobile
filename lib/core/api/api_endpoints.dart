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
  static final String searchAdByImageEndpoint =
      '/api/method/aos.api.ads.search_ads_by_image';
  static final String setAdStatusEndpoint =
      '/api/method/aos.api.ads.set_ad_status';
  static final String updateAdEndpoint = '/api/method/aos.api.ads.update_ad';
  static final String abandonAdDraftEndpoint =
      '/api/method/aos.api.ads.abandon_ad_draft';

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
      '/api/method/aos.api.sellers.get_seller';
  static final String listSellersEndpoint =
      '/api/method/aos.api.sellers.list_sellers';
  static final String getMySellerStatusEndpoint =
      '/api/method/aos.api.sellers.get_my_seller_status';
  static final String toggleSellerEndpoint =
      '/api/method/aos.api.sellers.toggle_follow';
  static final String submitVerificationEndpoint =
      '/api/method/aos.api.sellers.submit_verification';
  static final String getMyVerificationEndpoint =
      '/api/method/aos.api.sellers.get_my_verification';
  static final String updateMySellerEndpoint =
      '/api/method/aos.api.sellers.update_my_seller';

  // Localization Endpoints
  static final String getLocaleBundleEndpoint =
      '/api/method/aos.api.localization.get_locale_bundle';
  static final String getMyPreferencesEndpoint =
      '/api/method/aos.api.accounts.get_my_preference';
  static final String updatePreferencesEndpoint =
      '/api/method/aos.api.accounts.update_my_preference';

  // Chat Endpoints
  static final String openConversationEndpoint =
      '/api/method/aos.api.chat.open_conversation';
  static final String listConversationsEndpoint =
      '/api/method/aos.api.chat.list_conversations';
  static final String deleteConversationEndpoint =
      '/api/method/aos.api.chat.delete_conversation';
  static final String sendMessageEndpoint =
      '/api/method/aos.api.chat.send_message';
  static final String listMessagesEndpoint =
      '/api/method/aos.api.chat.list_messages';
  static final String markDeliveredEndpoint =
      '/api/method/aos.api.chat.mark_delivered';
  static final String markReadEndpoint = '/api/method/aos.api.chat.mark_read';
  static final String typingEndpoint = '/api/method/aos.api.chat.typing';

  // CALL Endpoints
  static final String initiateCallEndpoint =
      '/api/method/aos.api.calls.initiate_call';
  static final String rejectCallEndpoint =
      '/api/method/aos.api.calls.reject_call';
  static final String acceptCallEndpoint =
      '/api/method/aos.api.calls.accept_call';
  static final String getCallTokenEndpoint =
      '/api/method/aos.api.calls.get_call_token';
  static final String endCallEndpoint = '/api/method/aos.api.calls.end_call';
  static final String listCallsEndpoint =
      '/api/method/aos.api.calls.list_calls';
  static final String markCallRingingEndpoint =
      '/api/method/aos.api.calls.mark_call_ringing';
  static final String cancelCallEndpoint =
      '/api/method/aos.api.calls.cancel_call';

  // LIVE Endpoints
  static final String startLiveEndpoint = '/api/method/aos.api.live.start_live';
  static final String joinLiveEndpoint = '/api/method/aos.api.live.join_live';
  static final String endLiveEndpoint = '/api/method/aos.api.live.end_live';
  static final String getLiveEndpoint = '/api/method/aos.api.live.get_live';
  static const String trackLiveJoinEndpoint =
      '/api/method/aos.api.live.track_join';
  static const String trackLiveLeaveEndpoint =
      '/api/method/aos.api.live.track_leave';

  static const addLiveComment = '/api/method/aos.api.live.add_comment';
  static const replyLiveComment = '/api/method/aos.api.live.reply_comment';
  static const listLiveComments = '/api/method/aos.api.live.list_comments';
  static const listLiveReplies = '/api/method/aos.api.live.list_replies';
  static const deleteLiveComment = '/api/method/aos.api.live.delete_comment';

  // ───────────── SHORTS ─────────────

  // FEED
  static final String shortsFeedForYou =
      '/api/method/aos.api.shorts.feed_for_you';

  static final String shortsFeedFollowing =
      '/api/method/aos.api.shorts.feed_following';

  static final String shortsFeedByAd = '/api/method/aos.api.shorts.feed_by_ad';

  // MANAGEMENT
  static final String getShort = '/api/method/aos.api.shorts.get_short';

  static final String myShorts = '/api/method/aos.api.shorts.my_shorts';

  static final String deleteShort = '/api/method/aos.api.shorts.delete_short';

  static final String retryProcessing =
      '/api/method/aos.api.shorts.retry_processing';

  // UPLOAD
  static final String initShortUpload =
      '/api/method/aos.api.shorts.init_upload';

  static final String confirmShortUpload =
      '/api/method/aos.api.shorts.confirm_upload';

  static final String updateShortMetadata =
      '/api/method/aos.api.shorts.update_short_metadata';

  // ENGAGEMENT
  static final String toggleShortLike =
      '/api/method/aos.api.shorts.toggle_like';

  // COMMENTS
  static final String addShortComment =
      '/api/method/aos.api.shorts.add_comment';

  static final String replyShortComment =
      '/api/method/aos.api.shorts.reply_comment';

  static final String listShortComments =
      '/api/method/aos.api.shorts.list_comments';

  static final String listShortReplies =
      '/api/method/aos.api.shorts.list_replies';

  static final String deleteShortComment =
      '/api/method/aos.api.shorts.delete_comment';

  // TRACKING
  static final String trackShortImpression =
      '/api/method/aos.api.shorts.track_impression';

  static final String trackShortView = '/api/method/aos.api.shorts.track_view';

  // ───────────── NOTIFICATIONS ─────────────

  static final String markAllNotificationsRead =
      '/api/method/aos.api.notifications.mark_all_notifications_read';
  static final String markNotificationRead =
      '/api/method/aos.api.notifications.mark_notification_read';
  static final String listNotifications =
      '/api/method/aos.api.notifications.list_notifications';
  static final String deactivatePushToken =
      '/api/method/aos.api.notifications.deactivate_push_token';
  static final String registerPushToken =
      '/api/method/aos.api.notifications.register_push_token';
}
