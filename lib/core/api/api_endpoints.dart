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
      '/api/method/aos.api.ads.get_ad_draft';
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
  static final String reportShortEndpoint =
      '/api/method/aos.api.reports.report_short';

  // Reviews Endpoints
  static final String createAdReviewEndpoint =
      '/api/method/aos.api.reviews.create_review';
  static final String getAdReviewsEndpoint =
      '/api/method/aos.api.reviews.list_reviews';
  static final String toggleAdReviewEndpoint =
      '/api/method/aos.api.reviews.toggle_reaction';
  static final String getReviewViewerState =
      '/api/method/aos.api.reviews.get_review_viewer_state';

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
  static final String updateMySellerEndpoint =
      '/api/method/aos.api.sellers.update_my_seller';

  // Social Endpoints
  static final String toggleFollowEndpoint =
      '/api/method/aos.api.social.toggle_follow';
  static final String getFollowsEndpoint =
      '/api/method/aos.api.social.get_followers';
  static final String getFollowingEndpoint =
      '/api/method/aos.api.social.get_following';
  static final String getFriendsEndpoint =
      '/api/method/aos.api.social.get_friends';
  static final String getRelationshipStatusEndpoint =
      '/api/method/aos.api.social.get_relationship_status';

  // Verification Endpoints
  static final String submitVerificationEndpoint =
      '/api/method/aos.api.verification.submit_verification';
  static final String getMyVerificationEndpoint =
      '/api/method/aos.api.verification.get_my_verification';

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
  static final String editMessageEndpoint =
      '/api/method/aos.api.chat.edit_message';
  static final String deleteMessagesEndpoint =
      '/api/method/aos.api.chat.delete_messages';
  static final String clearChatEndpoint = '/api/method/aos.api.chat.clear_chat';
  static final String toggleMessageStarEndpoint =
      '/api/method/aos.api.chat.toggle_message_star';
  static final String listStarredMessagesEndpoint =
      '/api/method/aos.api.chat.list_starred_messages';
  static final String toggleMessageReactionEndpoint =
      '/api/method/aos.api.chat.toggle_message_reaction';
  static final String forwardMessageEndpoint =
      '/api/method/aos.api.chat.forward_message';
  static final String translateMessageEndpoint =
      '/api/method/aos.api.chat.translate_message';
  static final String markDeliveredEndpoint =
      '/api/method/aos.api.chat.mark_delivered';
  static final String markReadEndpoint = '/api/method/aos.api.chat.mark_read';
  static final String typingEndpoint =
      '/api/method/aos.api.chat.send_typing_event';

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
  static final String getCallStatusEndpoint =
      '/api/method/aos.api.calls.get_call_status';
  static final String getCallGroupDetailsEndpoint =
      '/api/method/aos.api.calls.get_call_group_details';
  static final String deleteCallLogsEndpoint =
      '/api/method/aos.api.calls.delete_call_logs';
  static final String clearCallHistoryEndpoint =
      '/api/method/aos.api.calls.clear_call_history';
  static final String requestVideoUpgradeEndpoint =
      '/api/method/aos.api.calls.request_video_upgrade';
  static final String respondVideoUpgradeEndpoint =
      '/api/method/aos.api.calls.respond_video_upgrade';

  // LIVE Endpoints
  static final String startLiveEndpoint = '/api/method/aos.api.live.start_live';
  static final String joinLiveEndpoint = '/api/method/aos.api.live.join_live';
  static final String endLiveEndpoint = '/api/method/aos.api.live.end_live';
  static final String getLiveEndpoint = '/api/method/aos.api.live.get_live';
  static const String trackLiveJoinEndpoint =
      '/api/method/aos.api.live.track_join';
  static const String trackLiveLeaveEndpoint =
      '/api/method/aos.api.live.track_leave';
  // Live extras
  static const String listLiveStreamsEndpoint =
      '/api/method/aos.api.live.list_live_streams';
  static const String getLiveTokenEndpoint =
      '/api/method/aos.api.live.get_live_token';

  static const addLiveComment = '/api/method/aos.api.live.add_live_message';
  static const replyLiveComment = '/api/method/aos.api.live.reply_live_message';
  static const listLiveComments = '/api/method/aos.api.live.list_live_messages';
  static const listLiveReplies = '/api/method/aos.api.live.list_live_replies';
  static const deleteLiveComment =
      '/api/method/aos.api.live.delete_live_message';
  static const String sendLiveReaction =
      '/api/method/aos.api.live.send_reaction';

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
  static final String userShorts = '/api/method/aos.api.shorts.user_shorts';
  static final String savedShorts = '/api/method/aos.api.shorts.saved_shorts';
  static final String likedShorts = '/api/method/aos.api.shorts.liked_shorts';
  static final String repostedShorts =
      '/api/method/aos.api.shorts.reposted_shorts';
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
  static final String toggleShortSave =
      '/api/method/aos.api.shorts.toggle_save_short';
  static final String toggleShortRepost =
      '/api/method/aos.api.shorts.toggle_repost';

  // COMMENTS
  static final String addShortComment =
      '/api/method/aos.api.shorts.add_comment';
  static final String replyShortComment =
      '/api/method/aos.api.shorts.reply_comment';
  static final String listShortComments =
      '/api/method/aos.api.shorts.list_comments';
  static final String listShortReplies =
      '/api/method/aos.api.shorts.list_replies';
  static const String toggleShortCommentLike =
      '/api/method/aos.api.shorts.toggle_comment_like';
  static final String deleteShortComment =
      '/api/method/aos.api.shorts.delete_comment';

  // SHARING / DOWNLOAD
  static final String createShortShareLink =
      '/api/method/aos.api.shorts.create_short_share_link';
  static final String shareShortToChat =
      '/api/method/aos.api.shorts.share_short_to_chat';
  static final String downloadShort =
      '/api/method/aos.api.shorts.download_short';

  // ANALYTICS
  static final String getShortAnalytics =
      '/api/method/aos.api.shorts.get_short_analytics';
  static final String myShortsAnalytics =
      '/api/method/aos.api.shorts.my_shorts_analytics';
  static final String userShortAnalytics =
      '/api/method/aos.api.shorts.user_short_analytics';
  static final String generalShortAnalytics =
      '/api/method/aos.api.shorts.general_short_analytics';
  static final String listActivity =
      '/api/method/aos.api.activity.list_activity';

  // MUSIC / SOUNDS
  static final String initShortSoundUpload =
      '/api/method/aos.api.shorts.init_sound_upload';
  static final String confirmShortSoundUpload =
      '/api/method/aos.api.shorts.confirm_sound_upload';
  static final String listShortSounds =
      '/api/method/aos.api.shorts.list_sounds';
  static final String searchShortSounds =
      '/api/method/aos.api.shorts.search_sounds';
  static final String getShortSound = '/api/method/aos.api.shorts.get_sound';
  static final String favoriteShortSound =
      '/api/method/aos.api.shorts.favorite_sound';
  static final String myFavoriteShortSounds =
      '/api/method/aos.api.shorts.my_favorite_sounds';
  static final String soundShorts = '/api/method/aos.api.shorts.sound_shorts';
  static final String changeShortSound =
      '/api/method/aos.api.shorts.change_short_sound';
  static final String removeShortSound =
      '/api/method/aos.api.shorts.remove_short_sound';

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
  static const String deleteNotification =
      '/api/method/aos.api.notifications.delete_notification';
  static const String clearNotifications =
      '/api/method/aos.api.notifications.clear_notifications';
  static final String deactivatePushToken =
      '/api/method/aos.api.notifications.deactivate_push_token';
  static final String registerPushToken =
      '/api/method/aos.api.notifications.register_push_token';

  // Live Co-host
  static const String inviteLiveCohost =
      '/api/method/aos.api.live.invite_live_cohost';
  static const String requestLiveCohost =
      '/api/method/aos.api.live.request_live_cohost';
  static const String respondLiveCohost =
      '/api/method/aos.api.live.respond_live_cohost';
  static const String cancelLiveCohost =
      '/api/method/aos.api.live.cancel_live_cohost';
  static const String activateLiveCohost =
      '/api/method/aos.api.live.activate_live_cohost';
  static const String endLiveCohost =
      '/api/method/aos.api.live.end_live_cohost';
  static const String getLiveCohost =
      '/api/method/aos.api.live.get_live_cohost';
  static const String listLiveCohosts =
      '/api/method/aos.api.live.list_live_cohosts';
  static const String getLiveCohostToken =
      '/api/method/aos.api.live.get_live_cohost_token';

  // Maps
  static const String searchPlaces = '/api/method/aos.api.maps.search_places';
  static const String reverseGeocode =
      '/api/method/aos.api.maps.reverse_geocode';
  static const String getRoute = '/api/method/aos.api.maps.get_route';

  // Seller Location
  static const String setMySellerLocation =
      '/api/method/aos.api.sellers.set_my_seller_location';
  static const String getSellerLocation =
      '/api/method/aos.api.sellers.get_seller_location';
  static const String removeMySellerLocation =
      '/api/method/aos.api.sellers.remove_my_seller_location';

  // Activity Center
  static const String hideActivity =
      '/api/method/aos.api.activity.hide_activity';
  static const String clearActivity =
      '/api/method/aos.api.activity.clear_activity';

  // Social safety/discovery
  static const String searchUsers = '/api/method/aos.api.social.search_users';
  static const String blockUser = '/api/method/aos.api.social.block_user';
  static const String unblockUser = '/api/method/aos.api.social.unblock_user';
  static const String getBlockStatus =
      '/api/method/aos.api.social.get_block_status';
  static const String listBlockedUsers =
      '/api/method/aos.api.social.list_blocked_users';
  static const String reportUser = '/api/method/aos.api.reports.report_user';

  // Account deletion / restore
  static const String deleteAccount = '/api/method/aos.api.auth.delete_account';
  static const String requestRestoreAccount =
      '/api/method/aos.api.auth.request_restore_account';
  static const String restoreAccount =
      '/api/method/aos.api.auth.restore_account';

  // Saved Searches
  static const String saveSearchEndpoint =
      '/api/method/aos.api.saved_search.save_search';
  static const String listSavedSearchesEndpoint =
      '/api/method/aos.api.saved_search.list_saved_searches';
  static const String deleteSavedSearchEndpoint =
      '/api/method/aos.api.saved_search.delete_saved_search';
}
