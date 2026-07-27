class ApiEndpoints {
  // Authentication Endpoints
  static const String loginEndpoint = '/api/method/aos.api.v1.auth.login';
  static const String registerEndpoint = '/api/method/aos.api.v1.auth.register';
  static const String verifyOtpEndpoint =
      '/api/method/aos.api.v1.auth.verify_email_otp';
  static const String resendOtpEndpoint =
      '/api/method/aos.api.v1.auth.resend_email_otp';
  static const String forgotPasswordRequestEndpoint =
      '/api/method/aos.api.v1.auth.forgot_password_request';
  static const String forgotPasswordVerifyOtpEndpoint =
      '/api/method/aos.api.v1.auth.forgot_password_verify_otp';
  static const String forgotPasswordResetEndpoint =
      '/api/method/aos.api.v1.auth.forgot_password_reset';
  static const String meEndpoint = '/api/method/aos.api.v1.auth.me';
  static const String logoutEndpoint = '/api/method/aos.api.v1.auth.logout';
  static const String changePasswordEndpoint =
      '/api/method/aos.api.v1.auth.change_password';
  static const String googleLoginEndpoint =
      '/api/method/aos.api.v1.auth.google_login';
  static const String appleLoginEndpoint =
      '/api/method/aos.api.v1.auth.apple_login';

  // Accounts Endpoints
  static const String getProfileEndpoint =
      '/api/method/aos.api.v1.accounts.get_profile';
  static const String updateProfileEndpoint =
      '/api/method/aos.api.v1.accounts.update_profile';

  // Media Endpoints
  static const String initMediaUploadEndpoint =
      '/api/method/aos.api.v1.media.init_upload';
  static const String confirmMediaUploadEndpoint =
      '/api/method/aos.api.v1.media.confirm_upload';
  static const String deleteMediaEndpoint =
      '/api/method/aos.api.v1.media.delete_media';
  static const String removeBackgroundEndpoint =
      '/api/method/aos.api.v1.media.remove_background';

  // Catalog Endpoints
  static const String getCategoriesEndpoint =
      '/api/method/aos.api.v1.catalog.get_categories';
  static const String getCategorySchemaEndpoint =
      '/api/method/aos.api.v1.catalog.get_category_schema';

  // Ads / Listings Endpoints
  static const String getLocationsEndpoint =
      '/api/method/aos.api.v1.localization.get_locations';
  static const String createAdEndpoint = '/api/method/aos.api.v1.ads.create_ad';
  static const String upsertAdDraftEndpoint =
      '/api/method/aos.api.v1.ads.upsert_ad_draft';
  static const String getAdDraftEndpoint =
      '/api/method/aos.api.v1.ads.get_ad_draft';
  static const String listAdDraftsEndpoint =
      '/api/method/aos.api.v1.ads.list_my_ad_drafts';
  static const String submitAdDraftEndpoint =
      '/api/method/aos.api.v1.ads.submit_ad_draft';
  static const String searchAdByImageEndpoint =
      '/api/method/aos.api.v1.ads.search_ads_by_image';
  static const String setAdStatusEndpoint =
      '/api/method/aos.api.v1.ads.set_ad_status';
  static const String updateAdEndpoint = '/api/method/aos.api.v1.ads.update_ad';
  static const String abandonAdDraftEndpoint =
      '/api/method/aos.api.v1.ads.abandon_ad_draft';

  // Report Endpoints
  static const String listReportReasonsEndpoint =
      '/api/method/aos.api.v1.reports.list_report_reasons';
  static const String reportAdEndpoint =
      '/api/method/aos.api.v1.reports.report_ad';
  static const String reportShortEndpoint =
      '/api/method/aos.api.v1.reports.report_short';

  // Reviews Endpoints
  static const String createAdReviewEndpoint =
      '/api/method/aos.api.v1.reviews.create_review';
  static const String getAdReviewsEndpoint =
      '/api/method/aos.api.v1.reviews.list_reviews';
  static const String toggleAdReviewEndpoint =
      '/api/method/aos.api.v1.reviews.toggle_reaction';
  static const String getReviewViewerState =
      '/api/method/aos.api.v1.reviews.get_review_viewer_state';

  // Wishlist Endpoints
  static const String listWishlistEndpoint =
      '/api/method/aos.api.v1.wishlist.list_wishlist';
  static const String toggleWishlistEndpoint =
      '/api/method/aos.api.v1.wishlist.toggle_wishlist';

  // Read Ads
  static const String listAdsEndpoint = '/api/method/aos.api.v1.ads.list_ads';
  static const String myAdsEndpoint = '/api/method/aos.api.v1.ads.list_my_ads';
  static const String getAdEndpoint = '/api/method/aos.api.v1.ads.get_ad';
  static const String getMyAdEndpoint = '/api/method/aos.api.v1.ads.get_my_ad';

  // Seller Endpoints
  static const String getSellerEndpoint =
      '/api/method/aos.api.v1.sellers.get_seller';
  static const String listSellersEndpoint =
      '/api/method/aos.api.v1.sellers.list_sellers';
  static const String getMySellerStatusEndpoint =
      '/api/method/aos.api.v1.sellers.get_my_seller_status';
  static const String updateMySellerEndpoint =
      '/api/method/aos.api.v1.sellers.update_my_seller';

  // Social Endpoints
  static const String toggleFollowEndpoint =
      '/api/method/aos.api.v1.social.toggle_follow';
  static const String getFollowsEndpoint =
      '/api/method/aos.api.v1.social.get_followers';
  static const String getFollowingEndpoint =
      '/api/method/aos.api.v1.social.get_following';
  static const String getFriendsEndpoint =
      '/api/method/aos.api.v1.social.get_friends';
  static const String getRelationshipStatusEndpoint =
      '/api/method/aos.api.v1.social.get_relationship_status';

  // Verification Endpoints
  static const String submitVerificationEndpoint =
      '/api/method/aos.api.v1.verification.submit_verification';
  static const String getMyVerificationEndpoint =
      '/api/method/aos.api.v1.verification.get_my_verification';

  // Localization Endpoints
  static const String getLocaleBundleEndpoint =
      '/api/method/aos.api.v1.localization.get_locale_bundle';
  static const String resolveLocaleContextEndpoint =
      '/api/method/aos.api.v1.localization.resolve_locale_context';
  static const String getMyPreferencesEndpoint =
      '/api/method/aos.api.v1.accounts.get_my_preference';
  static const String updatePreferencesEndpoint =
      '/api/method/aos.api.v1.accounts.update_my_preference';

  // Chat Endpoints
  static const String openConversationEndpoint =
      '/api/method/aos.api.v1.chat.open_conversation';
  static const String listConversationsEndpoint =
      '/api/method/aos.api.v1.chat.list_conversations';
  static const String deleteConversationEndpoint =
      '/api/method/aos.api.v1.chat.delete_conversation';
  static const String sendMessageEndpoint =
      '/api/method/aos.api.v1.chat.send_message';
  static const String listMessagesEndpoint =
      '/api/method/aos.api.v1.chat.list_messages';
  static const String editMessageEndpoint =
      '/api/method/aos.api.v1.chat.edit_message';
  static const String deleteMessagesEndpoint =
      '/api/method/aos.api.v1.chat.delete_messages';
  static const String clearChatEndpoint =
      '/api/method/aos.api.v1.chat.clear_chat';
  static const String toggleMessageStarEndpoint =
      '/api/method/aos.api.v1.chat.toggle_message_star';
  static const String listStarredMessagesEndpoint =
      '/api/method/aos.api.v1.chat.list_starred_messages';
  static const String toggleMessageReactionEndpoint =
      '/api/method/aos.api.v1.chat.toggle_message_reaction';
  static const String forwardMessageEndpoint =
      '/api/method/aos.api.v1.chat.forward_message';
  static const String translateMessageEndpoint =
      '/api/method/aos.api.v1.chat.translate_message';
  static const String markDeliveredEndpoint =
      '/api/method/aos.api.v1.chat.mark_delivered';
  static const String markReadEndpoint =
      '/api/method/aos.api.v1.chat.mark_read';
  static const String typingEndpoint =
      '/api/method/aos.api.v1.chat.send_typing_event';

  // CALL Endpoints
  static const String initiateCallEndpoint =
      '/api/method/aos.api.v1.calls.initiate_call';
  static const String rejectCallEndpoint =
      '/api/method/aos.api.v1.calls.reject_call';
  static const String acceptCallEndpoint =
      '/api/method/aos.api.v1.calls.accept_call';
  static const String getCallTokenEndpoint =
      '/api/method/aos.api.v1.calls.get_call_token';
  static const String endCallEndpoint = '/api/method/aos.api.v1.calls.end_call';
  static const String listCallsEndpoint =
      '/api/method/aos.api.v1.calls.list_calls';
  static const String markCallRingingEndpoint =
      '/api/method/aos.api.v1.calls.mark_call_ringing';
  static const String cancelCallEndpoint =
      '/api/method/aos.api.v1.calls.cancel_call';
  static const String getCallStatusEndpoint =
      '/api/method/aos.api.v1.calls.get_call_status';
  static const String getCallGroupDetailsEndpoint =
      '/api/method/aos.api.v1.calls.get_call_group_details';
  static const String deleteCallLogsEndpoint =
      '/api/method/aos.api.v1.calls.delete_call_logs';
  static const String clearCallHistoryEndpoint =
      '/api/method/aos.api.v1.calls.clear_call_history';
  static const String requestVideoUpgradeEndpoint =
      '/api/method/aos.api.v1.calls.request_video_upgrade';
  static const String respondVideoUpgradeEndpoint =
      '/api/method/aos.api.v1.calls.respond_video_upgrade';

  // LIVE Endpoints
  static const String startLiveEndpoint =
      '/api/method/aos.api.v1.live.start_live';
  static const String joinLiveEndpoint =
      '/api/method/aos.api.v1.live.join_live';
  static const String endLiveEndpoint = '/api/method/aos.api.v1.live.end_live';
  static const String getLiveEndpoint = '/api/method/aos.api.v1.live.get_live';
  static const String trackLiveJoinEndpoint =
      '/api/method/aos.api.v1.live.track_join';
  static const String trackLiveLeaveEndpoint =
      '/api/method/aos.api.v1.live.track_leave';
  // Live extras
  static const String listLiveStreamsEndpoint =
      '/api/method/aos.api.v1.live.list_live_streams';
  static const String getLiveTokenEndpoint =
      '/api/method/aos.api.v1.live.get_live_token';

  static const addLiveComment = '/api/method/aos.api.v1.live.add_live_message';
  static const replyLiveComment =
      '/api/method/aos.api.v1.live.reply_live_message';
  static const listLiveComments =
      '/api/method/aos.api.v1.live.list_live_messages';
  static const listLiveReplies =
      '/api/method/aos.api.v1.live.list_live_replies';
  static const deleteLiveComment =
      '/api/method/aos.api.v1.live.delete_live_message';
  static const String sendLiveReaction =
      '/api/method/aos.api.v1.live.send_reaction';

  // ───────────── SHORTS ─────────────

  // FEED
  static const String shortsFeedForYou =
      '/api/method/aos.api.v1.shorts.feed_for_you';
  static const String shortsFeedFollowing =
      '/api/method/aos.api.v1.shorts.feed_following';
  static const String shortsFeedByAd =
      '/api/method/aos.api.v1.shorts.feed_by_ad';

  // MANAGEMENT
  static const String getShort = '/api/method/aos.api.v1.shorts.get_short';
  static const String myShorts = '/api/method/aos.api.v1.shorts.my_shorts';
  static const String userShorts = '/api/method/aos.api.v1.shorts.user_shorts';
  static const String savedShorts =
      '/api/method/aos.api.v1.shorts.saved_shorts';
  static const String likedShorts =
      '/api/method/aos.api.v1.shorts.liked_shorts';
  static const String repostedShorts =
      '/api/method/aos.api.v1.shorts.reposted_shorts';
  static const String deleteShort =
      '/api/method/aos.api.v1.shorts.delete_short';
  static const String retryProcessing =
      '/api/method/aos.api.v1.shorts.retry_processing';

  // UPLOAD
  static const String createShort =
      '/api/method/aos.api.v1.shorts.create_short';
  static const String updateShortMetadata =
      '/api/method/aos.api.v1.shorts.update_short_metadata';

  // ENGAGEMENT
  static const String toggleShortLike =
      '/api/method/aos.api.v1.shorts.toggle_like';
  static const String toggleShortSave =
      '/api/method/aos.api.v1.shorts.toggle_save_short';
  static const String toggleShortRepost =
      '/api/method/aos.api.v1.shorts.toggle_repost';

  // COMMENTS
  static const String addShortComment =
      '/api/method/aos.api.v1.shorts.add_comment';
  static const String replyShortComment =
      '/api/method/aos.api.v1.shorts.reply_comment';
  static const String listShortComments =
      '/api/method/aos.api.v1.shorts.list_comments';
  static const String listShortReplies =
      '/api/method/aos.api.v1.shorts.list_replies';
  static const String toggleShortCommentLike =
      '/api/method/aos.api.v1.shorts.toggle_comment_like';
  static const String deleteShortComment =
      '/api/method/aos.api.v1.shorts.delete_comment';

  // SHARING / DOWNLOAD
  static const String createShortShareLink =
      '/api/method/aos.api.v1.shorts.create_short_share_link';
  static const String shareShortToChat =
      '/api/method/aos.api.v1.shorts.share_short_to_chat';
  static const String downloadShort =
      '/api/method/aos.api.v1.shorts.download_short';

  // ANALYTICS
  static const String getShortAnalytics =
      '/api/method/aos.api.v1.shorts.get_short_analytics';
  static const String myShortsAnalytics =
      '/api/method/aos.api.v1.shorts.my_shorts_analytics';
  static const String userShortAnalytics =
      '/api/method/aos.api.v1.shorts.user_short_analytics';
  static const String generalShortAnalytics =
      '/api/method/aos.api.v1.shorts.general_short_analytics';
  static const String listActivity =
      '/api/method/aos.api.v1.activity.list_activity';

  // MUSIC / SOUNDS
  static const String createShortSound =
      '/api/method/aos.api.v1.shorts.create_sound';
  static const String listShortSounds =
      '/api/method/aos.api.v1.shorts.list_sounds';
  static const String searchShortSounds =
      '/api/method/aos.api.v1.shorts.search_sounds';
  static const String getShortSound = '/api/method/aos.api.v1.shorts.get_sound';
  static const String favoriteShortSound =
      '/api/method/aos.api.v1.shorts.favorite_sound';
  static const String myFavoriteShortSounds =
      '/api/method/aos.api.v1.shorts.my_favorite_sounds';
  static const String soundShorts =
      '/api/method/aos.api.v1.shorts.sound_shorts';
  static const String changeShortSound =
      '/api/method/aos.api.v1.shorts.change_short_sound';
  static const String removeShortSound =
      '/api/method/aos.api.v1.shorts.remove_short_sound';

  // TRACKING
  static const String trackShortImpression =
      '/api/method/aos.api.v1.shorts.track_impression';
  static const String trackShortView =
      '/api/method/aos.api.v1.shorts.track_view';

  // ───────────── NOTIFICATIONS ─────────────

  static const String markAllNotificationsRead =
      '/api/method/aos.api.v1.notifications.mark_all_notifications_read';
  static const String markNotificationRead =
      '/api/method/aos.api.v1.notifications.mark_notification_read';
  static const String listNotifications =
      '/api/method/aos.api.v1.notifications.list_notifications';
  static const String deleteNotification =
      '/api/method/aos.api.v1.notifications.delete_notification';
  static const String clearNotifications =
      '/api/method/aos.api.v1.notifications.clear_notifications';
  static const String deactivatePushToken =
      '/api/method/aos.api.v1.notifications.deactivate_push_token';
  static const String registerPushToken =
      '/api/method/aos.api.v1.notifications.register_push_token';

  // Live Co-host
  static const String inviteLiveCohost =
      '/api/method/aos.api.v1.live.invite_live_cohost';
  static const String requestLiveCohost =
      '/api/method/aos.api.v1.live.request_live_cohost';
  static const String respondLiveCohost =
      '/api/method/aos.api.v1.live.respond_live_cohost';
  static const String cancelLiveCohost =
      '/api/method/aos.api.v1.live.cancel_live_cohost';
  static const String activateLiveCohost =
      '/api/method/aos.api.v1.live.activate_live_cohost';
  static const String endLiveCohost =
      '/api/method/aos.api.v1.live.end_live_cohost';
  static const String getLiveCohost =
      '/api/method/aos.api.v1.live.get_live_cohost';
  static const String listLiveCohosts =
      '/api/method/aos.api.v1.live.list_live_cohosts';
  static const String getLiveCohostToken =
      '/api/method/aos.api.v1.live.get_live_cohost_token';

  // Maps
  static const String searchPlaces =
      '/api/method/aos.api.v1.maps.search_places';
  static const String autocompletePlaces =
      '/api/method/aos.api.v1.maps.autocomplete_places';
  static const String reverseGeocode =
      '/api/method/aos.api.v1.maps.reverse_geocode';
  static const String getRoute = '/api/method/aos.api.v1.maps.get_route';
  static const String refreshRoute =
      '/api/method/aos.api.v1.maps.refresh_route';

  // Seller Location
  static const String setMySellerLocation =
      '/api/method/aos.api.v1.sellers.set_my_seller_location';
  static const String getSellerLocation =
      '/api/method/aos.api.v1.sellers.get_seller_location';
  static const String removeMySellerLocation =
      '/api/method/aos.api.v1.sellers.remove_my_seller_location';
  static const String listSellerMapPoints =
      '/api/method/aos.api.v1.sellers.list_seller_map_points';

  // Activity Center
  static const String hideActivity =
      '/api/method/aos.api.v1.activity.hide_activity';
  static const String clearActivity =
      '/api/method/aos.api.v1.activity.clear_activity';

  // Social safety/discovery
  static const String searchUsers =
      '/api/method/aos.api.v1.social.search_users';
  static const String blockUser = '/api/method/aos.api.v1.social.block_user';
  static const String unblockUser =
      '/api/method/aos.api.v1.social.unblock_user';
  static const String getBlockStatus =
      '/api/method/aos.api.v1.social.get_block_status';
  static const String listBlockedUsers =
      '/api/method/aos.api.v1.social.list_blocked_users';
  static const String reportUser = '/api/method/aos.api.v1.reports.report_user';

  // Account deletion / restore
  static const String deleteAccount =
      '/api/method/aos.api.v1.auth.delete_account';
  static const String requestRestoreAccount =
      '/api/method/aos.api.v1.auth.request_restore_account';
  static const String restoreAccount =
      '/api/method/aos.api.v1.auth.restore_account';

  // Saved Searches
  static const String saveSearchEndpoint =
      '/api/method/aos.api.v1.saved_search.save_search';
  static const String listSavedSearchesEndpoint =
      '/api/method/aos.api.v1.saved_search.list_saved_searches';
  static const String deleteSavedSearchEndpoint =
      '/api/method/aos.api.v1.saved_search.delete_saved_search';
}
