import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
    Locale('sw'),
    Locale('zh'),
  ];

  /// No description provided for @onboarding_language_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get onboarding_language_title;

  /// No description provided for @onboarding_language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The app will display in your selected language'**
  String get onboarding_language_subtitle;

  /// No description provided for @onboarding_language_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get onboarding_language_placeholder;

  /// No description provided for @onboarding_language_picker.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get onboarding_language_picker;

  /// No description provided for @onboarding_use_current_location.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get onboarding_use_current_location;

  /// No description provided for @onboarding_use_country_currency.
  ///
  /// In en, this message translates to:
  /// **'Use country currency'**
  String get onboarding_use_country_currency;

  /// No description provided for @onboarding_loading_title.
  ///
  /// In en, this message translates to:
  /// **'Loading options'**
  String get onboarding_loading_title;

  /// No description provided for @onboarding_loading_message.
  ///
  /// In en, this message translates to:
  /// **'We’re loading your setup options. You can retry or skip for now.'**
  String get onboarding_loading_message;

  /// No description provided for @onboarding_offline_title.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get onboarding_offline_title;

  /// No description provided for @onboarding_offline_message.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load these options. Retry when you are connected, or skip for now without saving made-up defaults.'**
  String get onboarding_offline_message;

  /// No description provided for @common_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_try_again;

  /// No description provided for @common_no_languages.
  ///
  /// In en, this message translates to:
  /// **'No languages available'**
  String get common_no_languages;

  /// No description provided for @common_no_countries.
  ///
  /// In en, this message translates to:
  /// **'No countries available'**
  String get common_no_countries;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_no_results.
  ///
  /// In en, this message translates to:
  /// **'No matching options'**
  String get common_no_results;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_discard_changes_title.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get common_discard_changes_title;

  /// No description provided for @common_discard_changes_message.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get common_discard_changes_message;

  /// No description provided for @common_keep_editing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get common_keep_editing;

  /// No description provided for @common_discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get common_discard;

  /// No description provided for @common_selection_required.
  ///
  /// In en, this message translates to:
  /// **'Select a valid option to continue.'**
  String get common_selection_required;

  /// No description provided for @onboarding_currency_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Currency'**
  String get onboarding_currency_title;

  /// No description provided for @onboarding_currency_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Prices will be shown in your selected currency'**
  String get onboarding_currency_subtitle;

  /// No description provided for @onboarding_currency_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select your currency'**
  String get onboarding_currency_placeholder;

  /// No description provided for @onboarding_currency_picker.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get onboarding_currency_picker;

  /// No description provided for @onboarding_country_title.
  ///
  /// In en, this message translates to:
  /// **'Set Your Country'**
  String get onboarding_country_title;

  /// No description provided for @onboarding_country_subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll show you products and sellers near you'**
  String get onboarding_country_subtitle;

  /// No description provided for @onboarding_country_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get onboarding_country_placeholder;

  /// No description provided for @onboarding_country_picker.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get onboarding_country_picker;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_skip_for_now.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get common_skip_for_now;

  /// No description provided for @common_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get common_get_started;

  /// No description provided for @common_no_currencies.
  ///
  /// In en, this message translates to:
  /// **'No currencies available'**
  String get common_no_currencies;

  /// No description provided for @auth_register_title.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register_title;

  /// No description provided for @auth_register_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details below to create your account'**
  String get auth_register_subtitle;

  /// No description provided for @auth_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_full_name;

  /// No description provided for @auth_email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get auth_email_address;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirm_password;

  /// No description provided for @auth_accept_terms_error.
  ///
  /// In en, this message translates to:
  /// **'Please accept Terms & Conditions and Privacy Policy'**
  String get auth_accept_terms_error;

  /// No description provided for @auth_terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get auth_terms_and_conditions;

  /// No description provided for @auth_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get auth_privacy_policy;

  /// No description provided for @auth_agree_prefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get auth_agree_prefix;

  /// No description provided for @auth_and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get auth_and;

  /// No description provided for @auth_register_button.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register_button;

  /// No description provided for @auth_unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String auth_unexpected_error(Object error);

  /// No description provided for @auth_already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get auth_already_have_account;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_login_title.
  ///
  /// In en, this message translates to:
  /// **'Hello, Welcome Back'**
  String get auth_login_title;

  /// No description provided for @auth_login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to your account below'**
  String get auth_login_subtitle;

  /// No description provided for @auth_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get auth_remember_me;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login_button;

  /// No description provided for @auth_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_no_account;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_continue_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_continue_google;

  /// No description provided for @auth_or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get auth_or;

  /// No description provided for @auth_send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get auth_send_otp;

  /// No description provided for @auth_mail_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to reset your password'**
  String get auth_mail_reset_password;

  /// No description provided for @auth_password_updated_title.
  ///
  /// In en, this message translates to:
  /// **'Password Updated\nSuccessfully'**
  String get auth_password_updated_title;

  /// No description provided for @auth_password_updated_message.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully'**
  String get auth_password_updated_message;

  /// No description provided for @auth_password_updated_button.
  ///
  /// In en, this message translates to:
  /// **'Proceed To Login'**
  String get auth_password_updated_button;

  /// No description provided for @auth_email_verification_title.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get auth_email_verification_title;

  /// No description provided for @auth_enter_verification_code.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get auth_enter_verification_code;

  /// No description provided for @auth_verification_code_sent_to.
  ///
  /// In en, this message translates to:
  /// **'We have sent the verification code to'**
  String get auth_verification_code_sent_to;

  /// No description provided for @auth_email_verified_title.
  ///
  /// In en, this message translates to:
  /// **'Email Verified\nSuccessfully'**
  String get auth_email_verified_title;

  /// No description provided for @auth_email_verified_message.
  ///
  /// In en, this message translates to:
  /// **'Your email has been verified successfully'**
  String get auth_email_verified_message;

  /// No description provided for @auth_email_verified_button.
  ///
  /// In en, this message translates to:
  /// **'Proceed To Login'**
  String get auth_email_verified_button;

  /// No description provided for @auth_digit_code.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get auth_digit_code;

  /// No description provided for @auth_resend_code.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get auth_resend_code;

  /// No description provided for @auth_resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get auth_resend;

  /// No description provided for @auth_resend_in.
  ///
  /// In en, this message translates to:
  /// **'Resend in '**
  String get auth_resend_in;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get nav_categories;

  /// No description provided for @nav_selling.
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get nav_selling;

  /// No description provided for @nav_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get nav_contact;

  /// No description provided for @nav_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get nav_account;

  /// No description provided for @common_see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get common_see_all;

  /// No description provided for @home_flash_sales.
  ///
  /// In en, this message translates to:
  /// **'AOS Flash Sales'**
  String get home_flash_sales;

  /// No description provided for @home_services_near_you.
  ///
  /// In en, this message translates to:
  /// **'Services Near You'**
  String get home_services_near_you;

  /// No description provided for @home_new_products.
  ///
  /// In en, this message translates to:
  /// **'New Products in AOS'**
  String get home_new_products;

  /// No description provided for @home_electronic_deals.
  ///
  /// In en, this message translates to:
  /// **'AOS Electronic Deals'**
  String get home_electronic_deals;

  /// No description provided for @home_deals.
  ///
  /// In en, this message translates to:
  /// **'AOS Deals'**
  String get home_deals;

  /// No description provided for @home_furniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get home_furniture;

  /// No description provided for @home_electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get home_electronics;

  /// No description provided for @home_fashion.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Fashion'**
  String get home_fashion;

  /// No description provided for @home_babies_kids.
  ///
  /// In en, this message translates to:
  /// **'Babies & Kids'**
  String get home_babies_kids;

  /// No description provided for @home_beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get home_beauty;

  /// No description provided for @home_photography_tips.
  ///
  /// In en, this message translates to:
  /// **'Photography tips that sell'**
  String get home_photography_tips;

  /// No description provided for @home_boost_marketing_reach.
  ///
  /// In en, this message translates to:
  /// **'Boost your marketing reach'**
  String get home_boost_marketing_reach;

  /// No description provided for @home_ranking_tips.
  ///
  /// In en, this message translates to:
  /// **'Try all the best ranking tips'**
  String get home_ranking_tips;

  /// No description provided for @home_learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get home_learn;

  /// No description provided for @home_top_deals.
  ///
  /// In en, this message translates to:
  /// **'Top Deals'**
  String get home_top_deals;

  /// No description provided for @home_best_prices.
  ///
  /// In en, this message translates to:
  /// **'Best prices'**
  String get home_best_prices;

  /// No description provided for @home_shop_now.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get home_shop_now;

  /// No description provided for @home_you_might_be_looking_for.
  ///
  /// In en, this message translates to:
  /// **'You might be looking for'**
  String get home_you_might_be_looking_for;

  /// No description provided for @ads_no_more_ads.
  ///
  /// In en, this message translates to:
  /// **'No more ads'**
  String get ads_no_more_ads;

  /// No description provided for @location_all_locations.
  ///
  /// In en, this message translates to:
  /// **'All locations'**
  String get location_all_locations;

  /// No description provided for @search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search here...'**
  String get search_placeholder;

  /// No description provided for @search_button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_button;

  /// No description provided for @ads_my_listings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get ads_my_listings;

  /// No description provided for @ads_no_listings_yet.
  ///
  /// In en, this message translates to:
  /// **'No Listings Yet'**
  String get ads_no_listings_yet;

  /// No description provided for @ads_no_listings_message.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any ads yet.'**
  String get ads_no_listings_message;

  /// No description provided for @ads_start_selling_message.
  ///
  /// In en, this message translates to:
  /// **'Start selling by creating your first listing'**
  String get ads_start_selling_message;

  /// No description provided for @ads_post_first_ad.
  ///
  /// In en, this message translates to:
  /// **'Post Your First Ad'**
  String get ads_post_first_ad;

  /// No description provided for @ads_learn_sell_faster.
  ///
  /// In en, this message translates to:
  /// **'Learn how to sell faster'**
  String get ads_learn_sell_faster;

  /// No description provided for @ads_create_ad.
  ///
  /// In en, this message translates to:
  /// **'Create Ad'**
  String get ads_create_ad;

  /// No description provided for @ads_update_ad.
  ///
  /// In en, this message translates to:
  /// **'Update Ad'**
  String get ads_update_ad;

  /// No description provided for @account_title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account_title;

  /// No description provided for @account_get_verified.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Business'**
  String get account_get_verified;

  /// No description provided for @account_boost_trust.
  ///
  /// In en, this message translates to:
  /// **'Get verified as a registered business'**
  String get account_boost_trust;

  /// No description provided for @account_settings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get account_settings;

  /// No description provided for @account_passwords_security.
  ///
  /// In en, this message translates to:
  /// **'Passwords & Security'**
  String get account_passwords_security;

  /// No description provided for @account_notifications_preferences.
  ///
  /// In en, this message translates to:
  /// **'Notifications Preferences'**
  String get account_notifications_preferences;

  /// No description provided for @account_guest_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AOS'**
  String get account_guest_title;

  /// No description provided for @account_guest_description.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account, manage ads, and more'**
  String get account_guest_description;

  /// No description provided for @app_preferences.
  ///
  /// In en, this message translates to:
  /// **'Application Prefences'**
  String get app_preferences;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_dark_mode;

  /// No description provided for @common_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get common_other;

  /// No description provided for @common_discover_more.
  ///
  /// In en, this message translates to:
  /// **'Discover More'**
  String get common_discover_more;

  /// No description provided for @settings_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy_policy;

  /// No description provided for @settings_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settings_preferences;

  /// No description provided for @settings_manage_app.
  ///
  /// In en, this message translates to:
  /// **'Manage how the app works for you'**
  String get settings_manage_app;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_description.
  ///
  /// In en, this message translates to:
  /// **'Controls how text appears in the app.'**
  String get settings_language_description;

  /// No description provided for @settings_country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get settings_country;

  /// No description provided for @settings_country_description.
  ///
  /// In en, this message translates to:
  /// **'Determines nearby listings and where your ads appear.'**
  String get settings_country_description;

  /// No description provided for @settings_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settings_currency;

  /// No description provided for @settings_currency_description.
  ///
  /// In en, this message translates to:
  /// **'Used for prices when viewing and posting listings.'**
  String get settings_currency_description;

  /// No description provided for @settings_terms_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settings_terms_conditions;

  /// No description provided for @onboarding_preference_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your preference. Please try again.'**
  String get onboarding_preference_error;

  /// No description provided for @session_restore_offline_title.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get session_restore_offline_title;

  /// No description provided for @session_restore_offline_message.
  ///
  /// In en, this message translates to:
  /// **'AOS couldn\'t verify your existing session. Reconnect and try again. Your stored session has not been cleared.'**
  String get session_restore_offline_message;

  /// No description provided for @session_restore_unavailable_title.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t restore your session'**
  String get session_restore_unavailable_title;

  /// No description provided for @session_restore_unavailable_message.
  ///
  /// In en, this message translates to:
  /// **'AOS couldn\'t verify your existing session right now. Try again. Your stored session has not been cleared.'**
  String get session_restore_unavailable_message;

  /// No description provided for @privacy_cover_accessibility_label.
  ///
  /// In en, this message translates to:
  /// **'AOS is protecting your account information.'**
  String get privacy_cover_accessibility_label;

  /// No description provided for @appLockScreenAccessibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'AOS is locked'**
  String get appLockScreenAccessibilityLabel;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock AOS'**
  String get appLockTitle;

  /// No description provided for @appLockPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your app lock to continue.'**
  String get appLockPrompt;

  /// No description provided for @appLockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlock;

  /// No description provided for @appLockAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating…'**
  String get appLockAuthenticating;

  /// No description provided for @appLockLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get appLockLogout;

  /// No description provided for @appLockForgottenCredentialHelp.
  ///
  /// In en, this message translates to:
  /// **'Reset app lock to sign out and remove a forgotten local credential.'**
  String get appLockForgottenCredentialHelp;

  /// No description provided for @appLockUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock AOS.'**
  String get appLockUnlockReason;

  /// No description provided for @appLockEnableReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to enable biometric app lock.'**
  String get appLockEnableReason;

  /// No description provided for @appLockDisableReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to disable app lock.'**
  String get appLockDisableReason;

  /// No description provided for @appLockCancelled.
  ///
  /// In en, this message translates to:
  /// **'Authentication was cancelled. Your session is still signed in.'**
  String get appLockCancelled;

  /// No description provided for @appLockTemporaryLockout.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later or reset app lock.'**
  String get appLockTemporaryLockout;

  /// No description provided for @appLockPermanentLockout.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are locked. Use your device recovery options or reset app lock.'**
  String get appLockPermanentLockout;

  /// No description provided for @appLockNoDeviceCredential.
  ///
  /// In en, this message translates to:
  /// **'Set up fingerprint, Face ID, or another supported biometric in device settings first.'**
  String get appLockNoDeviceCredential;

  /// No description provided for @appLockUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Native device authentication is unavailable on this device.'**
  String get appLockUnsupported;

  /// No description provided for @appLockTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get appLockTryAgain;

  /// No description provided for @appLockFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Try again.'**
  String get appLockFailed;

  /// No description provided for @appLockSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLockSettingTitle;

  /// No description provided for @appLockSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'Protect private areas with a 4-digit PIN, pattern, or biometrics.'**
  String get appLockSettingDescription;

  /// No description provided for @appLockTimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock timing'**
  String get appLockTimingTitle;

  /// No description provided for @appLockTimingImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get appLockTimingImmediately;

  /// No description provided for @appLockTimingThirtySeconds.
  ///
  /// In en, this message translates to:
  /// **'After 30 seconds'**
  String get appLockTimingThirtySeconds;

  /// No description provided for @appLockTimingOneMinute.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get appLockTimingOneMinute;

  /// No description provided for @appLockTimingFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get appLockTimingFiveMinutes;

  /// No description provided for @wishlist_add.
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get wishlist_add;

  /// No description provided for @wishlist_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove from wishlist'**
  String get wishlist_remove;

  /// No description provided for @wishlist_update_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update your wishlist. Please try again.'**
  String get wishlist_update_error;

  /// No description provided for @appLockBiometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint, face, or other enrolled biometric to continue.'**
  String get appLockBiometricPrompt;

  /// No description provided for @appLockUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get appLockUseBiometrics;

  /// No description provided for @appLockReset.
  ///
  /// In en, this message translates to:
  /// **'Reset app lock'**
  String get appLockReset;

  /// No description provided for @appLockResetHelp.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN or pattern? Resetting app lock signs you out and removes the local lock.'**
  String get appLockResetHelp;

  /// No description provided for @appLockResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset app lock?'**
  String get appLockResetTitle;

  /// No description provided for @appLockResetMessage.
  ///
  /// In en, this message translates to:
  /// **'This will sign you out, clear the saved app lock, and return you to the public app. Sign in again to set a new lock.'**
  String get appLockResetMessage;

  /// No description provided for @appLockResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset and log out'**
  String get appLockResetConfirm;

  /// No description provided for @appLockCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get appLockCancel;

  /// No description provided for @appLockClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get appLockClear;

  /// No description provided for @appLockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your 4-digit PIN'**
  String get appLockEnterPin;

  /// No description provided for @appLockEnterPattern.
  ///
  /// In en, this message translates to:
  /// **'Draw your pattern'**
  String get appLockEnterPattern;

  /// No description provided for @appLockInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'That app-lock credential is incorrect. Try again.'**
  String get appLockInvalidCredential;

  /// No description provided for @appLockPinHelp.
  ///
  /// In en, this message translates to:
  /// **'Use exactly 4 digits.'**
  String get appLockPinHelp;

  /// No description provided for @appLockPatternHelp.
  ///
  /// In en, this message translates to:
  /// **'Connect at least 4 points.'**
  String get appLockPatternHelp;

  /// No description provided for @appLockConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get appLockConfirmPin;

  /// No description provided for @appLockConfirmPattern.
  ///
  /// In en, this message translates to:
  /// **'Confirm your pattern'**
  String get appLockConfirmPattern;

  /// No description provided for @appLockConfirmationMismatch.
  ///
  /// In en, this message translates to:
  /// **'The confirmation does not match. Try again.'**
  String get appLockConfirmationMismatch;

  /// No description provided for @appLockContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get appLockContinue;

  /// No description provided for @appLockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get appLockConfirm;

  /// No description provided for @appLockStorageFailure.
  ///
  /// In en, this message translates to:
  /// **'App-lock settings could not be saved securely. Try again.'**
  String get appLockStorageFailure;

  /// No description provided for @appLockConfigured.
  ///
  /// In en, this message translates to:
  /// **'App lock is enabled'**
  String get appLockConfigured;

  /// No description provided for @appLockProcessRestartNote.
  ///
  /// In en, this message translates to:
  /// **'AOS always locks after the app is terminated or restarted.'**
  String get appLockProcessRestartNote;

  /// No description provided for @appLockChangeMethod.
  ///
  /// In en, this message translates to:
  /// **'Change lock method'**
  String get appLockChangeMethod;

  /// No description provided for @appLockDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable app lock'**
  String get appLockDisable;

  /// No description provided for @appLockChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose a lock method'**
  String get appLockChooseMethod;

  /// No description provided for @appLockMethodHelp.
  ///
  /// In en, this message translates to:
  /// **'PIN and pattern are stored only as secure salted hashes. Biometric data remains managed by your device.'**
  String get appLockMethodHelp;

  /// No description provided for @appLockMethodPin.
  ///
  /// In en, this message translates to:
  /// **'4-digit PIN'**
  String get appLockMethodPin;

  /// No description provided for @appLockMethodPattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get appLockMethodPattern;

  /// No description provided for @appLockMethodBiometric.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or biometrics'**
  String get appLockMethodBiometric;

  /// No description provided for @appLockChangeReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to change your app lock.'**
  String get appLockChangeReason;

  /// No description provided for @appLockTimingFiveSeconds.
  ///
  /// In en, this message translates to:
  /// **'After 5 seconds'**
  String get appLockTimingFiveSeconds;

  /// No description provided for @appLockTimingTenSeconds.
  ///
  /// In en, this message translates to:
  /// **'After 10 seconds'**
  String get appLockTimingTenSeconds;

  /// No description provided for @appLockTimingFifteenSeconds.
  ///
  /// In en, this message translates to:
  /// **'After 15 seconds'**
  String get appLockTimingFifteenSeconds;

  /// No description provided for @appLockPinInputAccessibility.
  ///
  /// In en, this message translates to:
  /// **'PIN entry'**
  String get appLockPinInputAccessibility;

  /// No description provided for @appLockPatternInputAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Pattern entry'**
  String get appLockPatternInputAccessibility;

  /// No description provided for @appLockPatternPointAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Pattern point'**
  String get appLockPatternPointAccessibility;

  /// No description provided for @ads_location_select_title.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get ads_location_select_title;

  /// No description provided for @ads_location_results_more.
  ///
  /// In en, this message translates to:
  /// **'More than {count} locations found'**
  String ads_location_results_more(Object count);

  /// No description provided for @ads_location_results_exact.
  ///
  /// In en, this message translates to:
  /// **'{count} locations found'**
  String ads_location_results_exact(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr', 'sw', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'sw':
      return AppLocalizationsSw();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
