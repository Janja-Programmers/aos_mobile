// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboarding_language_title => 'Choose Your Language';

  @override
  String get onboarding_language_subtitle =>
      'The app will display in your selected language';

  @override
  String get onboarding_language_placeholder => 'Select your language';

  @override
  String get onboarding_language_picker => 'Select Language';

  @override
  String get onboarding_use_current_location => 'Use current location';

  @override
  String get onboarding_use_country_currency => 'Use country currency';

  @override
  String get onboarding_loading_title => 'Loading options';

  @override
  String get onboarding_loading_message =>
      'We’re loading your setup options. You can retry or skip for now.';

  @override
  String get onboarding_offline_title => 'No internet connection';

  @override
  String get onboarding_offline_message =>
      'We couldn’t load these options. Retry when you are connected, or skip for now without saving made-up defaults.';

  @override
  String get common_try_again => 'Try again';

  @override
  String get common_no_languages => 'No languages available';

  @override
  String get common_no_countries => 'No countries available';

  @override
  String get common_search => 'Search';

  @override
  String get common_no_results => 'No matching options';

  @override
  String get common_save => 'Save';

  @override
  String get common_discard_changes_title => 'Discard changes?';

  @override
  String get common_discard_changes_message =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get common_keep_editing => 'Keep editing';

  @override
  String get common_discard => 'Discard';

  @override
  String get common_selection_required => 'Select a valid option to continue.';

  @override
  String get onboarding_currency_title => 'Choose Your Currency';

  @override
  String get onboarding_currency_subtitle =>
      'Prices will be shown in your selected currency';

  @override
  String get onboarding_currency_placeholder => 'Select your currency';

  @override
  String get onboarding_currency_picker => 'Select Currency';

  @override
  String get onboarding_country_title => 'Set Your Country';

  @override
  String get onboarding_country_subtitle =>
      'We\'ll show you products and sellers near you';

  @override
  String get onboarding_country_placeholder => 'Select your country';

  @override
  String get onboarding_country_picker => 'Select Country';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_skip_for_now => 'Skip for now';

  @override
  String get common_get_started => 'Get Started';

  @override
  String get common_no_currencies => 'No currencies available';

  @override
  String get auth_register_title => 'Register';

  @override
  String get auth_register_subtitle =>
      'Enter your details below to create your account';

  @override
  String get auth_full_name => 'Full Name';

  @override
  String get auth_email_address => 'Email Address';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_confirm_password => 'Confirm Password';

  @override
  String get auth_accept_terms_error =>
      'Please accept Terms & Conditions and Privacy Policy';

  @override
  String get auth_terms_and_conditions => 'Terms & Conditions';

  @override
  String get auth_privacy_policy => 'Privacy Policy';

  @override
  String get auth_agree_prefix => 'I agree to the ';

  @override
  String get auth_and => ' and ';

  @override
  String get auth_register_button => 'Register';

  @override
  String auth_unexpected_error(Object error) {
    return 'Unexpected error: $error';
  }

  @override
  String get auth_already_have_account => 'Already have an account? ';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_login_title => 'Hello, Welcome Back';

  @override
  String get auth_login_subtitle => 'Login to your account below';

  @override
  String get auth_remember_me => 'Remember Me';

  @override
  String get auth_forgot_password => 'Forgot Password?';

  @override
  String get auth_login_button => 'Login';

  @override
  String get auth_no_account => 'Don\'t have an account?';

  @override
  String get auth_register => 'Register';

  @override
  String get auth_continue_google => 'Continue with Google';

  @override
  String get auth_or => 'or';

  @override
  String get auth_send_otp => 'Send OTP';

  @override
  String get auth_mail_reset_password =>
      'Enter your email address to reset your password';

  @override
  String get auth_password_updated_title => 'Password Updated\nSuccessfully';

  @override
  String get auth_password_updated_message =>
      'Your password has been updated successfully';

  @override
  String get auth_password_updated_button => 'Proceed To Login';

  @override
  String get auth_email_verification_title => 'Email Verification';

  @override
  String get auth_enter_verification_code => 'Enter Verification Code';

  @override
  String get auth_verification_code_sent_to =>
      'We have sent the verification code to';

  @override
  String get auth_email_verified_title => 'Email Verified\nSuccessfully';

  @override
  String get auth_email_verified_message =>
      'Your email has been verified successfully';

  @override
  String get auth_email_verified_button => 'Proceed To Login';

  @override
  String get auth_digit_code => 'Enter the 6-digit code';

  @override
  String get auth_resend_code => 'Didn\'t receive the code? ';

  @override
  String get auth_resend => 'Resend';

  @override
  String get auth_resend_in => 'Resend in ';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_categories => 'Categories';

  @override
  String get nav_selling => 'Selling';

  @override
  String get nav_contact => 'Contact';

  @override
  String get nav_account => 'Account';

  @override
  String get common_see_all => 'See all';

  @override
  String get home_flash_sales => 'AOS Flash Sales';

  @override
  String get home_services_near_you => 'Services Near You';

  @override
  String get home_new_products => 'New Products in AOS';

  @override
  String get home_electronic_deals => 'AOS Electronic Deals';

  @override
  String get home_deals => 'AOS Deals';

  @override
  String get home_furniture => 'Furniture';

  @override
  String get home_electronics => 'Electronics';

  @override
  String get home_fashion => 'Women\'s Fashion';

  @override
  String get home_babies_kids => 'Babies & Kids';

  @override
  String get home_beauty => 'Beauty';

  @override
  String get home_photography_tips => 'Photography tips that sell';

  @override
  String get home_boost_marketing_reach => 'Boost your marketing reach';

  @override
  String get home_ranking_tips => 'Try all the best ranking tips';

  @override
  String get home_learn => 'Learn';

  @override
  String get home_top_deals => 'Top Deals';

  @override
  String get home_best_prices => 'Best prices';

  @override
  String get home_shop_now => 'Shop Now';

  @override
  String get home_you_might_be_looking_for => 'You might be looking for';

  @override
  String get ads_no_more_ads => 'No more ads';

  @override
  String get location_all_locations => 'All locations';

  @override
  String get search_placeholder => 'Search here...';

  @override
  String get search_button => 'Search';

  @override
  String get ads_my_listings => 'My Listings';

  @override
  String get ads_no_listings_yet => 'No Listings Yet';

  @override
  String get ads_no_listings_message => 'You haven\'t posted any ads yet.';

  @override
  String get ads_start_selling_message =>
      'Start selling by creating your first listing';

  @override
  String get ads_post_first_ad => 'Post Your First Ad';

  @override
  String get ads_learn_sell_faster => 'Learn how to sell faster';

  @override
  String get ads_create_ad => 'Create Ad';

  @override
  String get ads_update_ad => 'Update Ad';

  @override
  String get account_title => 'Account';

  @override
  String get account_get_verified => 'Verify Your Business';

  @override
  String get account_boost_trust => 'Get verified as a registered business';

  @override
  String get account_settings => 'Account Settings';

  @override
  String get account_passwords_security => 'Passwords & Security';

  @override
  String get account_notifications_preferences => 'Notifications Preferences';

  @override
  String get account_guest_title => 'Welcome to AOS';

  @override
  String get account_guest_description =>
      'Sign in to access your account, manage ads, and more';

  @override
  String get app_preferences => 'Application Prefences';

  @override
  String get settings_dark_mode => 'Dark Mode';

  @override
  String get common_other => 'Other';

  @override
  String get common_discover_more => 'Discover More';

  @override
  String get settings_privacy_policy => 'Privacy Policy';

  @override
  String get settings_preferences => 'Preferences';

  @override
  String get settings_manage_app => 'Manage how the app works for you';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_description =>
      'Controls how text appears in the app.';

  @override
  String get settings_country => 'Country';

  @override
  String get settings_country_description =>
      'Determines nearby listings and where your ads appear.';

  @override
  String get settings_currency => 'Currency';

  @override
  String get settings_currency_description =>
      'Used for prices when viewing and posting listings.';

  @override
  String get settings_terms_conditions => 'Terms & Conditions';

  @override
  String get onboarding_preference_error =>
      'We couldn\'t save your preference. Please try again.';

  @override
  String get session_restore_offline_title => 'You\'re offline';

  @override
  String get session_restore_offline_message =>
      'AOS couldn\'t verify your existing session. Reconnect and try again. Your stored session has not been cleared.';

  @override
  String get session_restore_unavailable_title =>
      'We couldn\'t restore your session';

  @override
  String get session_restore_unavailable_message =>
      'AOS couldn\'t verify your existing session right now. Try again. Your stored session has not been cleared.';

  @override
  String get privacy_cover_accessibility_label =>
      'AOS is protecting your account information.';

  @override
  String get appLockScreenAccessibilityLabel => 'AOS is locked';

  @override
  String get appLockTitle => 'Unlock AOS';

  @override
  String get appLockPrompt => 'Enter your app lock to continue.';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockAuthenticating => 'Authenticating…';

  @override
  String get appLockLogout => 'Log out';

  @override
  String get appLockForgottenCredentialHelp =>
      'Reset app lock to sign out and remove a forgotten local credential.';

  @override
  String get appLockUnlockReason => 'Authenticate to unlock AOS.';

  @override
  String get appLockEnableReason =>
      'Authenticate to enable biometric app lock.';

  @override
  String get appLockDisableReason => 'Authenticate to disable app lock.';

  @override
  String get appLockCancelled =>
      'Authentication was cancelled. Your session is still signed in.';

  @override
  String get appLockTemporaryLockout =>
      'Too many attempts. Try again later or reset app lock.';

  @override
  String get appLockPermanentLockout =>
      'Biometrics are locked. Use your device recovery options or reset app lock.';

  @override
  String get appLockNoDeviceCredential =>
      'Set up fingerprint, Face ID, or another supported biometric in device settings first.';

  @override
  String get appLockUnsupported =>
      'Native device authentication is unavailable on this device.';

  @override
  String get appLockTryAgain => 'Try again';

  @override
  String get appLockFailed => 'Authentication failed. Try again.';

  @override
  String get appLockSettingTitle => 'App Lock';

  @override
  String get appLockSettingDescription =>
      'Protect private areas with a 4-digit PIN, pattern, or biometrics.';

  @override
  String get appLockTimingTitle => 'Lock timing';

  @override
  String get appLockTimingImmediately => 'Immediately';

  @override
  String get appLockTimingThirtySeconds => 'After 30 seconds';

  @override
  String get appLockTimingOneMinute => 'After 1 minute';

  @override
  String get appLockTimingFiveMinutes => 'After 5 minutes';

  @override
  String get wishlist_add => 'Add to wishlist';

  @override
  String get wishlist_remove => 'Remove from wishlist';

  @override
  String get wishlist_update_error =>
      'We couldn\'t update your wishlist. Please try again.';

  @override
  String get appLockBiometricPrompt =>
      'Use your fingerprint, face, or other enrolled biometric to continue.';

  @override
  String get appLockUseBiometrics => 'Use biometrics';

  @override
  String get appLockReset => 'Reset app lock';

  @override
  String get appLockResetHelp =>
      'Forgot your PIN or pattern? Resetting app lock signs you out and removes the local lock.';

  @override
  String get appLockResetTitle => 'Reset app lock?';

  @override
  String get appLockResetMessage =>
      'This will sign you out, clear the saved app lock, and return you to the public app. Sign in again to set a new lock.';

  @override
  String get appLockResetConfirm => 'Reset and log out';

  @override
  String get appLockCancel => 'Cancel';

  @override
  String get appLockClear => 'Clear';

  @override
  String get appLockEnterPin => 'Enter your 4-digit PIN';

  @override
  String get appLockEnterPattern => 'Draw your pattern';

  @override
  String get appLockInvalidCredential =>
      'That app-lock credential is incorrect. Try again.';

  @override
  String get appLockPinHelp => 'Use exactly 4 digits.';

  @override
  String get appLockPatternHelp => 'Connect at least 4 points.';

  @override
  String get appLockConfirmPin => 'Confirm your PIN';

  @override
  String get appLockConfirmPattern => 'Confirm your pattern';

  @override
  String get appLockConfirmationMismatch =>
      'The confirmation does not match. Try again.';

  @override
  String get appLockContinue => 'Continue';

  @override
  String get appLockConfirm => 'Confirm';

  @override
  String get appLockStorageFailure =>
      'App-lock settings could not be saved securely. Try again.';

  @override
  String get appLockConfigured => 'App lock is enabled';

  @override
  String get appLockProcessRestartNote =>
      'AOS always locks after the app is terminated or restarted.';

  @override
  String get appLockChangeMethod => 'Change lock method';

  @override
  String get appLockDisable => 'Disable app lock';

  @override
  String get appLockChooseMethod => 'Choose a lock method';

  @override
  String get appLockMethodHelp =>
      'PIN and pattern are stored only as secure salted hashes. Biometric data remains managed by your device.';

  @override
  String get appLockMethodPin => '4-digit PIN';

  @override
  String get appLockMethodPattern => 'Pattern';

  @override
  String get appLockMethodBiometric => 'Fingerprint or biometrics';

  @override
  String get appLockChangeReason => 'Authenticate to change your app lock.';

  @override
  String get appLockTimingFiveSeconds => 'After 5 seconds';

  @override
  String get appLockTimingTenSeconds => 'After 10 seconds';

  @override
  String get appLockTimingFifteenSeconds => 'After 15 seconds';

  @override
  String get appLockPinInputAccessibility => 'PIN entry';

  @override
  String get appLockPatternInputAccessibility => 'Pattern entry';

  @override
  String get appLockPatternPointAccessibility => 'Pattern point';

  @override
  String get ads_location_select_title => 'Select location';

  @override
  String ads_location_results_more(Object count) {
    return 'More than $count locations found';
  }

  @override
  String ads_location_results_exact(Object count) {
    return '$count locations found';
  }

  @override
  String get ad_media_download_image => 'Download image';

  @override
  String get ad_media_saved_to_gallery => 'Image saved to gallery.';

  @override
  String get liveLikeAction => 'Like live';

  @override
  String get liveShareAction => 'Share live';

  @override
  String get liveMuteAction => 'Mute microphone';

  @override
  String get liveUnmuteAction => 'Unmute microphone';

  @override
  String get liveFlipCameraAction => 'Flip camera';

  @override
  String get watchThisLiveOnAos => 'Watch this live on AOS';

  @override
  String get unableToOpenShareOptions => 'Unable to open share options.';

  @override
  String get chat_connect_title => 'AOS Connect';

  @override
  String get chat_close_connect => 'Close Connect';

  @override
  String get chat_close_search => 'Close search';

  @override
  String get chat_search => 'Search';

  @override
  String get chat_more_options => 'More options';

  @override
  String get chat_search_chats_hint => 'Search chats...';

  @override
  String get chat_search_calls_hint => 'Search calls...';

  @override
  String get chat_all_marked_read => 'All chats marked as read.';

  @override
  String get chat_some_mark_read_failed =>
      'Some chats could not be marked as read.';

  @override
  String get chat_clear_call_log_title => 'Clear call log?';

  @override
  String get chat_clear_call_log_body =>
      'This removes your visible call history. It does not delete other users’ records.';

  @override
  String get chat_cancel => 'Cancel';

  @override
  String get chat_clear => 'Clear';

  @override
  String get chat_call_log_cleared => 'Call log cleared.';

  @override
  String get chat_call_log_clear_failed => 'Could not clear call log.';

  @override
  String get chat_clear_call_log => 'Clear call log';

  @override
  String get chat_settings => 'Settings';

  @override
  String get chat_mark_all_read => 'Mark all read';

  @override
  String get chat_starred_messages => 'Starred messages';

  @override
  String get chat_chats => 'Chats';

  @override
  String get chat_new_conversation => 'New conversation';

  @override
  String get chat_new => 'New';

  @override
  String get chat_calls => 'Calls';

  @override
  String get chat_back => 'Back';

  @override
  String get chat_call => 'Call';

  @override
  String get chat_video_call => 'Video call';

  @override
  String get chat_change_wallpaper => 'Change wallpaper';

  @override
  String get chat_user_might_be_offline => 'User might be offline';

  @override
  String get chat_failed_to_start_call => 'Failed to start call';

  @override
  String get chat_gallery => 'Gallery';

  @override
  String get chat_camera => 'Camera';

  @override
  String get chat_voice_call => 'Voice call';

  @override
  String get chat_location => 'Location';

  @override
  String get chat_document => 'Document';

  @override
  String get chat_contact => 'Contact';

  @override
  String get chat_attachment_upload_failed =>
      'Attachment upload failed. Please try again.';

  @override
  String get chat_message_hint => 'Message';

  @override
  String get chat_share_location_title => 'Share location';

  @override
  String get chat_retry => 'Retry';

  @override
  String get chat_could_not_load_messages => 'Could not load messages';

  @override
  String get chat_check_connection_try_again =>
      'Check your connection and try again.';

  @override
  String get chat_no_messages_yet => 'No messages yet';

  @override
  String get chat_no_messages_hint =>
      'Send a message to start this conversation.';

  @override
  String get chat_older_messages_load_failed =>
      'Older messages could not be loaded.';

  @override
  String get chat_reply => 'Reply';

  @override
  String get chat_edit => 'Edit';

  @override
  String get chat_copy => 'Copy';

  @override
  String get chat_forward => 'Forward';

  @override
  String get chat_translate_again => 'Translate again';

  @override
  String get chat_translate => 'Translate';

  @override
  String get chat_unstar => 'Unstar';

  @override
  String get chat_star => 'Star';

  @override
  String get chat_delete_for_me => 'Delete for me';

  @override
  String get chat_delete_for_everyone => 'Delete for everyone';

  @override
  String get chat_message_reactions => 'Message reactions';

  @override
  String get chat_choose_another_reaction => 'Choose another reaction';

  @override
  String chat_react_with(Object emoji) {
    return 'React with $emoji';
  }

  @override
  String chat_remove_reaction(Object emoji) {
    return 'Remove $emoji reaction';
  }

  @override
  String get chat_editing_message => 'Editing message';

  @override
  String get chat_cancel_editing => 'Cancel editing';

  @override
  String get chat_copied_to_clipboard => 'Copied to clipboard';

  @override
  String get chat_message_still_failed => 'Message still failed. Try again.';

  @override
  String get chat_send_ad_failed =>
      'Failed to send ad message. Please try again.';

  @override
  String get chat_send_failed => 'Failed to send message. Please try again.';

  @override
  String get chat_star_update_failed => 'Failed to update star.';

  @override
  String get chat_reaction_update_failed => 'Failed to update reaction.';

  @override
  String get chat_forward_failed => 'Failed to forward message.';

  @override
  String get chat_forwarded => 'Message forwarded.';

  @override
  String chat_forwarded_to_chats(Object count) {
    return 'Message forwarded to $count chats.';
  }

  @override
  String get chat_translate_failed => 'Failed to translate message.';

  @override
  String get chat_delete_failed => 'Failed to delete message.';

  @override
  String get chat_deleted_for_everyone => 'Message deleted for everyone.';

  @override
  String get chat_deleted_for_you => 'Message deleted for you.';

  @override
  String get chat_edit_failed => 'Failed to edit message.';

  @override
  String get chat_settings_title => 'Chat Settings';

  @override
  String get chat_privacy => 'Privacy';

  @override
  String get chat_read_receipts => 'Read receipts';

  @override
  String get chat_read_receipts_managed =>
      'Managed by AOS for message delivery';

  @override
  String get chat_last_seen_online => 'Last seen & online';

  @override
  String get chat_no_backend_preference =>
      'No account preference is exposed by the backend';

  @override
  String get chat_blocked_contacts => 'Blocked contacts';

  @override
  String get chat_chats_section => 'Chats';

  @override
  String get chat_wallpaper => 'Chat wallpaper';

  @override
  String get chat_wallpaper_description =>
      'Set the default background for chats';

  @override
  String get chat_enter_is_send => 'Enter is send';

  @override
  String get chat_enter_is_send_description => 'Enter key sends your message';

  @override
  String get chat_media_auto_download => 'Media auto-download';

  @override
  String get chat_unavailable_backend =>
      'Not available in the current backend contract';

  @override
  String get chat_notifications => 'Notifications';

  @override
  String get chat_message_notifications => 'Message notifications';

  @override
  String get chat_call_notifications => 'Call notifications';

  @override
  String get chat_system_notification_settings =>
      'Controlled by system notification settings';

  @override
  String get chat_on => 'On';

  @override
  String get chat_off => 'Off';

  @override
  String get chat_starred_load_failed => 'Could not load starred messages';

  @override
  String get chat_no_starred_messages => 'No starred messages';

  @override
  String get chat_no_starred_messages_hint =>
      'Messages you star will appear here.';

  @override
  String get chat_unstar_message => 'Unstar message';

  @override
  String get chat_unstar_failed => 'Failed to unstar message.';

  @override
  String get chat_message_unstarred => 'Message unstarred.';

  @override
  String get chat_attachment => 'Attachment';

  @override
  String get chat_you => 'You';

  @override
  String get chat_other_user => 'Other user';

  @override
  String get chat_aos_user => 'AOS user';

  @override
  String get chat_sending => 'Sending...';

  @override
  String get chat_edited => 'Edited';

  @override
  String get chat_starred => 'Starred';

  @override
  String get chat_translated => 'Translated';

  @override
  String get chat_failed_to_send => 'Failed to send';

  @override
  String get chat_read => 'Read';

  @override
  String get chat_delivered => 'Delivered';

  @override
  String get chat_sent => 'Sent';

  @override
  String get chat_forwarded_label => 'Forwarded';

  @override
  String get chat_deleted_message => 'This message was deleted';

  @override
  String get chat_translating => 'Translating...';

  @override
  String get chat_tap_to_retry => 'Tap to retry';

  @override
  String get chat_translate_to => 'Translate to';

  @override
  String chat_translate_to_language(Object language) {
    return 'Translate to $language';
  }

  @override
  String get chat_voice_release_cancel => 'Release to cancel';

  @override
  String get chat_voice_recording_locked => 'Recording locked';

  @override
  String get chat_voice_slide_cancel => 'Slide left to cancel';

  @override
  String chat_voice_recording_status(Object duration, Object instruction) {
    return 'Voice recording $duration. $instruction';
  }

  @override
  String chat_starred_message_from(Object sender) {
    return 'Starred message from $sender';
  }

  @override
  String get chat_verified_sellers => 'Verified Sellers';

  @override
  String get chat_friends => 'Friends';

  @override
  String get chat_search_sellers_hint => 'Search sellers...';

  @override
  String get chat_search_friends_hint => 'Search friends...';

  @override
  String get chat_loading_sellers => 'Loading sellers';

  @override
  String get chat_loading_sellers_hint =>
      'Please wait while we find verified sellers.';

  @override
  String get chat_could_not_load_sellers => 'Could not load sellers';

  @override
  String get chat_no_verified_sellers => 'No verified sellers';

  @override
  String get chat_no_sellers_found => 'No sellers found';

  @override
  String get chat_no_verified_sellers_hint =>
      'Verified sellers will appear here when available.';

  @override
  String get chat_no_sellers_found_hint =>
      'Try another seller name, category, or location.';

  @override
  String get chat_refresh => 'Refresh';

  @override
  String get chat_loading_friends => 'Loading friends';

  @override
  String get chat_loading_friends_hint =>
      'Please wait while we find your friends.';

  @override
  String get chat_could_not_load_friends => 'Could not load friends';

  @override
  String get chat_try_again => 'Please try again.';

  @override
  String get chat_no_friends_yet => 'No friends yet';

  @override
  String get chat_no_friends_found => 'No friends found';

  @override
  String get chat_no_friends_yet_hint =>
      'Friends will appear here once you follow each other.';

  @override
  String get chat_no_friends_found_hint =>
      'Try searching with another name or email.';

  @override
  String get chat_online => 'Online';

  @override
  String get chat_last_seen_recently => 'Last seen recently';

  @override
  String get chat_friend => 'Friend';

  @override
  String get chat_message_contact => 'Message';

  @override
  String get chat_call_contact => 'Call';

  @override
  String get chat_all_chats => 'All Chats';

  @override
  String get chat_unread => 'Unread';

  @override
  String get chat_loading_conversations => 'Loading conversations';

  @override
  String get chat_loading_conversations_hint =>
      'Please wait while we fetch your chats.';

  @override
  String get chat_could_not_load_chats => 'Could not load chats';

  @override
  String get chat_no_chats_found => 'No chats found';

  @override
  String get chat_no_chats_search_hint =>
      'Try searching with another name or message.';

  @override
  String get chat_no_read_chats => 'No read chats';

  @override
  String get chat_no_unread_chats => 'No unread chats';

  @override
  String get chat_no_conversations_yet => 'No conversations yet';

  @override
  String get chat_no_read_chats_hint =>
      'Chats you have already read will appear here.';

  @override
  String get chat_no_unread_chats_hint =>
      'Unread chats will appear here as new messages arrive.';

  @override
  String get chat_no_conversations_hint =>
      'Your conversations will appear here once you start chatting.';

  @override
  String get chat_deleted_from_list =>
      'Chat deleted from your conversation list.';

  @override
  String get chat_delete_chat_failed =>
      'Failed to delete chat. Please try again.';

  @override
  String get chat_typing => 'Typing...';

  @override
  String chat_last_seen_time(Object time) {
    return 'Last seen $time';
  }

  @override
  String get chat_forward_to_title => 'Forward to';

  @override
  String get chat_close => 'Close';

  @override
  String get chat_search_conversations_hint => 'Search conversations';

  @override
  String get chat_clear_search => 'Clear search';

  @override
  String get chat_could_not_load_conversations =>
      'Could not load conversations';

  @override
  String get chat_no_other_conversations => 'No other conversations';

  @override
  String get chat_no_other_conversations_hint =>
      'Start another chat first, then you can forward messages here.';

  @override
  String get chat_no_conversations_found => 'No conversations found';

  @override
  String get chat_search_conversations_empty_hint =>
      'Try searching with another name or message.';

  @override
  String get chat_forward_to_one_chat => 'Forward to 1 chat';

  @override
  String chat_forward_to_chats_count(Object count) {
    return 'Forward to $count chats';
  }

  @override
  String get chat_default_wallpaper_applied => 'Default wallpaper applied.';

  @override
  String get chat_wallpaper_updated => 'Wallpaper updated.';

  @override
  String chat_named_wallpaper_applied(Object name) {
    return '$name wallpaper applied.';
  }

  @override
  String get chat_choose_conversation_background =>
      'Choose a background for this conversation';

  @override
  String get chat_default => 'Default';

  @override
  String get chat_choose_from_gallery => 'Choose from gallery';

  @override
  String get chat_solid_colors => 'Solid colors';

  @override
  String get chat_emoji_recent => 'Recent';

  @override
  String get chat_emoji_smileys => 'Smileys';

  @override
  String get chat_emoji_animals => 'Animals';

  @override
  String get chat_emoji_food => 'Food';

  @override
  String get chat_emoji_flags => 'Flags';

  @override
  String get chat_search_emoji => 'Search emoji';

  @override
  String get chat_no_emoji_found => 'No emoji found';

  @override
  String get chat_share_contact => 'Share a contact';

  @override
  String get chat_search_aos_users => 'Search AOS users';

  @override
  String get chat_could_not_load_contacts => 'Could not load contacts';

  @override
  String get chat_search_people_on_aos => 'Search people on AOS';

  @override
  String get chat_search_people_hint =>
      'Type at least 2 characters to find a contact to share.';

  @override
  String get chat_no_contacts_found => 'No contacts found';

  @override
  String get chat_no_contacts_found_hint =>
      'Try another name, username, or email.';

  @override
  String get chat_unmute => 'Unmute';

  @override
  String get chat_mute => 'Mute';

  @override
  String get chat_end_call => 'End call';

  @override
  String get chat_calling => 'Calling';

  @override
  String get chat_ringing => 'Ringing';

  @override
  String get chat_incoming_call => 'Incoming call';

  @override
  String get chat_connecting => 'Connecting';

  @override
  String get chat_delete_chat_title => 'Delete chat?';

  @override
  String chat_delete_chat_description(Object name) {
    return 'This will remove your chat with $name from your conversation list. It will not delete it for the other user.';
  }

  @override
  String get chat_this_user => 'this user';

  @override
  String get chat_delete => 'Delete';

  @override
  String get chat_view_profile => 'View profile';

  @override
  String get chat_view_contact => 'View contact';

  @override
  String get chat_cannot_open_document => 'Cannot open this type of document';

  @override
  String get chat_failed_to_start_chat =>
      'Failed to start chat. Please try again.';

  @override
  String get chat_invalid_conversation_response =>
      'Invalid conversation response';

  @override
  String get chat_voice_hold_to_record => 'Hold to record a voice message';

  @override
  String get chat_voice_tap_to_record => 'Tap to record a voice message';

  @override
  String get chat_voice_pause => 'Pause recording';

  @override
  String get chat_voice_resume => 'Resume recording';

  @override
  String get chat_voice_delete_recording => 'Delete recording';

  @override
  String get chat_voice_send_recording => 'Send voice message';

  @override
  String get chat_voice_release_to_finish =>
      'Release to finish voice recording';

  @override
  String get chat_microphone_permission_denied =>
      'Microphone permission denied.';

  @override
  String get chat_voice_record_start_failed =>
      'Could not start voice recording.';

  @override
  String get chat_voice_record_finish_failed =>
      'Could not finish voice recording.';

  @override
  String get chat_language_english => 'English';

  @override
  String get chat_language_swahili => 'Swahili';

  @override
  String get chat_language_french => 'French';

  @override
  String get chat_language_spanish => 'Spanish';

  @override
  String get chat_language_german => 'German';

  @override
  String get chat_language_portuguese => 'Portuguese';

  @override
  String get chat_language_arabic => 'Arabic';

  @override
  String get chat_language_hausa => 'Hausa';

  @override
  String get chat_language_yoruba => 'Yoruba';

  @override
  String get chat_language_igbo => 'Igbo';

  @override
  String get chat_language_amharic => 'Amharic';

  @override
  String get chat_language_somali => 'Somali';

  @override
  String get chat_language_kinyarwanda => 'Kinyarwanda';

  @override
  String get chat_language_luganda => 'Luganda';

  @override
  String get chat_language_zulu => 'Zulu';

  @override
  String get chat_language_xhosa => 'Xhosa';

  @override
  String get chat_wallpaper_midnight => 'Midnight';

  @override
  String get chat_wallpaper_navy => 'Navy';

  @override
  String get chat_wallpaper_forest => 'Forest';

  @override
  String get chat_wallpaper_plum => 'Plum';

  @override
  String get chat_wallpaper_charcoal => 'Charcoal';

  @override
  String get chat_wallpaper_maroon => 'Maroon';

  @override
  String get chat_wallpaper_teal => 'Teal';

  @override
  String get chat_wallpaper_coffee => 'Coffee';
}
