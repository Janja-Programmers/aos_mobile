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
}
