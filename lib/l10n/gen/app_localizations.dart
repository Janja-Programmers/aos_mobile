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

  /// No description provided for @settings_seller_country_locked_description.
  ///
  /// In en, this message translates to:
  /// **'Country is locked for seller accounts to protect marketplace data.'**
  String get settings_seller_country_locked_description;

  /// No description provided for @settings_seller_country_locked.
  ///
  /// In en, this message translates to:
  /// **'Country cannot be changed for a seller account.'**
  String get settings_seller_country_locked;

  /// No description provided for @common_locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get common_locked;

  /// No description provided for @settings_preference_updated.
  ///
  /// In en, this message translates to:
  /// **'Preference updated.'**
  String get settings_preference_updated;

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

  /// No description provided for @ad_media_download_image.
  ///
  /// In en, this message translates to:
  /// **'Download image'**
  String get ad_media_download_image;

  /// No description provided for @ad_media_saved_to_gallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery.'**
  String get ad_media_saved_to_gallery;

  /// No description provided for @liveLikeAction.
  ///
  /// In en, this message translates to:
  /// **'Like live'**
  String get liveLikeAction;

  /// No description provided for @liveShareAction.
  ///
  /// In en, this message translates to:
  /// **'Share live'**
  String get liveShareAction;

  /// No description provided for @liveMuteAction.
  ///
  /// In en, this message translates to:
  /// **'Mute microphone'**
  String get liveMuteAction;

  /// No description provided for @liveUnmuteAction.
  ///
  /// In en, this message translates to:
  /// **'Unmute microphone'**
  String get liveUnmuteAction;

  /// No description provided for @liveFlipCameraAction.
  ///
  /// In en, this message translates to:
  /// **'Flip camera'**
  String get liveFlipCameraAction;

  /// No description provided for @liveGoLiveAction.
  ///
  /// In en, this message translates to:
  /// **'Go LIVE'**
  String get liveGoLiveAction;

  /// No description provided for @liveStartingAction.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get liveStartingAction;

  /// No description provided for @liveDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Live details'**
  String get liveDetailsTitle;

  /// No description provided for @liveEditDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Edit live details'**
  String get liveEditDetailsAction;

  /// No description provided for @liveEditDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit title or cover'**
  String get liveEditDetailsHint;

  /// No description provided for @liveCoverLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover photo'**
  String get liveCoverLabel;

  /// No description provided for @liveChangeCoverAction.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get liveChangeCoverAction;

  /// No description provided for @liveChooseCoverFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get liveChooseCoverFromGallery;

  /// No description provided for @liveTakeCoverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get liveTakeCoverPhoto;

  /// No description provided for @liveTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Live title'**
  String get liveTitleLabel;

  /// No description provided for @liveTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Add a live title'**
  String get liveTitleHint;

  /// No description provided for @liveTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a live title to continue.'**
  String get liveTitleRequired;

  /// No description provided for @liveCoverRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a cover photo to continue.'**
  String get liveCoverRequired;

  /// No description provided for @liveUploadingCover.
  ///
  /// In en, this message translates to:
  /// **'Uploading cover...'**
  String get liveUploadingCover;

  /// No description provided for @liveCameraStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting camera...'**
  String get liveCameraStarting;

  /// No description provided for @liveCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera preview unavailable'**
  String get liveCameraUnavailable;

  /// No description provided for @liveCameraStartError.
  ///
  /// In en, this message translates to:
  /// **'Could not start camera preview.'**
  String get liveCameraStartError;

  /// No description provided for @liveNoAlternateCameraError.
  ///
  /// In en, this message translates to:
  /// **'No alternate camera is available.'**
  String get liveNoAlternateCameraError;

  /// No description provided for @liveCameraFlipError.
  ///
  /// In en, this message translates to:
  /// **'Could not flip camera.'**
  String get liveCameraFlipError;

  /// No description provided for @liveCoverUploadError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the Live cover.'**
  String get liveCoverUploadError;

  /// No description provided for @liveCoverSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not select a Live cover.'**
  String get liveCoverSelectionError;

  /// No description provided for @watchThisLiveOnAos.
  ///
  /// In en, this message translates to:
  /// **'Watch this live on AOS'**
  String get watchThisLiveOnAos;

  /// No description provided for @unableToOpenShareOptions.
  ///
  /// In en, this message translates to:
  /// **'Unable to open share options.'**
  String get unableToOpenShareOptions;

  /// No description provided for @chat_connect_title.
  ///
  /// In en, this message translates to:
  /// **'AOS Connect'**
  String get chat_connect_title;

  /// No description provided for @chat_close_connect.
  ///
  /// In en, this message translates to:
  /// **'Close Connect'**
  String get chat_close_connect;

  /// No description provided for @chat_close_search.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get chat_close_search;

  /// No description provided for @chat_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get chat_search;

  /// No description provided for @chat_more_options.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get chat_more_options;

  /// No description provided for @chat_search_chats_hint.
  ///
  /// In en, this message translates to:
  /// **'Search chats...'**
  String get chat_search_chats_hint;

  /// No description provided for @chat_search_calls_hint.
  ///
  /// In en, this message translates to:
  /// **'Search calls...'**
  String get chat_search_calls_hint;

  /// No description provided for @chat_all_marked_read.
  ///
  /// In en, this message translates to:
  /// **'All chats marked as read.'**
  String get chat_all_marked_read;

  /// No description provided for @chat_some_mark_read_failed.
  ///
  /// In en, this message translates to:
  /// **'Some chats could not be marked as read.'**
  String get chat_some_mark_read_failed;

  /// No description provided for @chat_clear_call_log_title.
  ///
  /// In en, this message translates to:
  /// **'Clear call log?'**
  String get chat_clear_call_log_title;

  /// No description provided for @chat_clear_call_log_body.
  ///
  /// In en, this message translates to:
  /// **'This removes your visible call history. It does not delete other users’ records.'**
  String get chat_clear_call_log_body;

  /// No description provided for @chat_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chat_cancel;

  /// No description provided for @chat_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get chat_clear;

  /// No description provided for @chat_call_log_cleared.
  ///
  /// In en, this message translates to:
  /// **'Call log cleared.'**
  String get chat_call_log_cleared;

  /// No description provided for @chat_call_log_clear_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not clear call log.'**
  String get chat_call_log_clear_failed;

  /// No description provided for @chat_clear_call_log.
  ///
  /// In en, this message translates to:
  /// **'Clear call log'**
  String get chat_clear_call_log;

  /// No description provided for @chat_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get chat_settings;

  /// No description provided for @chat_mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get chat_mark_all_read;

  /// No description provided for @chat_starred_messages.
  ///
  /// In en, this message translates to:
  /// **'Starred messages'**
  String get chat_starred_messages;

  /// No description provided for @chat_chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chat_chats;

  /// No description provided for @chat_new_conversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get chat_new_conversation;

  /// No description provided for @chat_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get chat_new;

  /// No description provided for @chat_calls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get chat_calls;

  /// No description provided for @chat_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get chat_back;

  /// No description provided for @chat_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get chat_call;

  /// No description provided for @chat_video_call.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get chat_video_call;

  /// No description provided for @chat_change_wallpaper.
  ///
  /// In en, this message translates to:
  /// **'Change wallpaper'**
  String get chat_change_wallpaper;

  /// No description provided for @chat_user_might_be_offline.
  ///
  /// In en, this message translates to:
  /// **'User might be offline'**
  String get chat_user_might_be_offline;

  /// No description provided for @chat_failed_to_start_call.
  ///
  /// In en, this message translates to:
  /// **'Failed to start call'**
  String get chat_failed_to_start_call;

  /// No description provided for @chat_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chat_gallery;

  /// No description provided for @chat_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get chat_camera;

  /// No description provided for @chat_voice_call.
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get chat_voice_call;

  /// No description provided for @chat_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get chat_location;

  /// No description provided for @chat_document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get chat_document;

  /// No description provided for @chat_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get chat_contact;

  /// No description provided for @chat_attachment_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Attachment upload failed. Please try again.'**
  String get chat_attachment_upload_failed;

  /// No description provided for @chat_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chat_message_hint;

  /// No description provided for @chat_share_location_title.
  ///
  /// In en, this message translates to:
  /// **'Share location'**
  String get chat_share_location_title;

  /// No description provided for @chat_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chat_retry;

  /// No description provided for @chat_could_not_load_messages.
  ///
  /// In en, this message translates to:
  /// **'Could not load messages'**
  String get chat_could_not_load_messages;

  /// No description provided for @chat_check_connection_try_again.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get chat_check_connection_try_again;

  /// No description provided for @chat_no_messages_yet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chat_no_messages_yet;

  /// No description provided for @chat_no_messages_hint.
  ///
  /// In en, this message translates to:
  /// **'Send a message to start this conversation.'**
  String get chat_no_messages_hint;

  /// No description provided for @chat_older_messages_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Older messages could not be loaded.'**
  String get chat_older_messages_load_failed;

  /// No description provided for @chat_reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chat_reply;

  /// No description provided for @chat_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get chat_edit;

  /// No description provided for @chat_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get chat_copy;

  /// No description provided for @chat_forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get chat_forward;

  /// No description provided for @chat_translate_again.
  ///
  /// In en, this message translates to:
  /// **'Translate again'**
  String get chat_translate_again;

  /// No description provided for @chat_translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get chat_translate;

  /// No description provided for @chat_unstar.
  ///
  /// In en, this message translates to:
  /// **'Unstar'**
  String get chat_unstar;

  /// No description provided for @chat_star.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get chat_star;

  /// No description provided for @chat_delete_for_me.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get chat_delete_for_me;

  /// No description provided for @chat_delete_for_everyone.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get chat_delete_for_everyone;

  /// No description provided for @chat_message_reactions.
  ///
  /// In en, this message translates to:
  /// **'Message reactions'**
  String get chat_message_reactions;

  /// No description provided for @chat_choose_another_reaction.
  ///
  /// In en, this message translates to:
  /// **'Choose another reaction'**
  String get chat_choose_another_reaction;

  /// No description provided for @chat_react_with.
  ///
  /// In en, this message translates to:
  /// **'React with {emoji}'**
  String chat_react_with(Object emoji);

  /// No description provided for @chat_remove_reaction.
  ///
  /// In en, this message translates to:
  /// **'Remove {emoji} reaction'**
  String chat_remove_reaction(Object emoji);

  /// No description provided for @chat_editing_message.
  ///
  /// In en, this message translates to:
  /// **'Editing message'**
  String get chat_editing_message;

  /// No description provided for @chat_cancel_editing.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get chat_cancel_editing;

  /// No description provided for @chat_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get chat_copied_to_clipboard;

  /// No description provided for @chat_message_still_failed.
  ///
  /// In en, this message translates to:
  /// **'Message still failed. Try again.'**
  String get chat_message_still_failed;

  /// No description provided for @chat_send_ad_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send ad message. Please try again.'**
  String get chat_send_ad_failed;

  /// No description provided for @chat_send_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get chat_send_failed;

  /// No description provided for @chat_star_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update star.'**
  String get chat_star_update_failed;

  /// No description provided for @chat_reaction_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update reaction.'**
  String get chat_reaction_update_failed;

  /// No description provided for @chat_forward_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to forward message.'**
  String get chat_forward_failed;

  /// No description provided for @chat_forwarded.
  ///
  /// In en, this message translates to:
  /// **'Message forwarded.'**
  String get chat_forwarded;

  /// No description provided for @chat_forwarded_to_chats.
  ///
  /// In en, this message translates to:
  /// **'Message forwarded to {count} chats.'**
  String chat_forwarded_to_chats(Object count);

  /// No description provided for @chat_translate_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to translate message.'**
  String get chat_translate_failed;

  /// No description provided for @chat_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete message.'**
  String get chat_delete_failed;

  /// No description provided for @chat_deleted_for_everyone.
  ///
  /// In en, this message translates to:
  /// **'Message deleted for everyone.'**
  String get chat_deleted_for_everyone;

  /// No description provided for @chat_deleted_for_you.
  ///
  /// In en, this message translates to:
  /// **'Message deleted for you.'**
  String get chat_deleted_for_you;

  /// No description provided for @chat_edit_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to edit message.'**
  String get chat_edit_failed;

  /// No description provided for @chat_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Chat Settings'**
  String get chat_settings_title;

  /// No description provided for @chat_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get chat_privacy;

  /// No description provided for @chat_read_receipts.
  ///
  /// In en, this message translates to:
  /// **'Read receipts'**
  String get chat_read_receipts;

  /// No description provided for @chat_read_receipts_managed.
  ///
  /// In en, this message translates to:
  /// **'Managed by AOS for message delivery'**
  String get chat_read_receipts_managed;

  /// No description provided for @chat_last_seen_online.
  ///
  /// In en, this message translates to:
  /// **'Last seen & online'**
  String get chat_last_seen_online;

  /// No description provided for @chat_no_backend_preference.
  ///
  /// In en, this message translates to:
  /// **'No account preference is exposed by the backend'**
  String get chat_no_backend_preference;

  /// No description provided for @chat_blocked_contacts.
  ///
  /// In en, this message translates to:
  /// **'Blocked contacts'**
  String get chat_blocked_contacts;

  /// No description provided for @chat_chats_section.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chat_chats_section;

  /// No description provided for @chat_wallpaper.
  ///
  /// In en, this message translates to:
  /// **'Chat wallpaper'**
  String get chat_wallpaper;

  /// No description provided for @chat_wallpaper_description.
  ///
  /// In en, this message translates to:
  /// **'Set the default background for chats'**
  String get chat_wallpaper_description;

  /// No description provided for @chat_enter_is_send.
  ///
  /// In en, this message translates to:
  /// **'Enter is send'**
  String get chat_enter_is_send;

  /// No description provided for @chat_enter_is_send_description.
  ///
  /// In en, this message translates to:
  /// **'Enter key sends your message'**
  String get chat_enter_is_send_description;

  /// No description provided for @chat_media_auto_download.
  ///
  /// In en, this message translates to:
  /// **'Media auto-download'**
  String get chat_media_auto_download;

  /// No description provided for @chat_unavailable_backend.
  ///
  /// In en, this message translates to:
  /// **'Not available in the current backend contract'**
  String get chat_unavailable_backend;

  /// No description provided for @chat_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get chat_notifications;

  /// No description provided for @chat_message_notifications.
  ///
  /// In en, this message translates to:
  /// **'Message notifications'**
  String get chat_message_notifications;

  /// No description provided for @chat_call_notifications.
  ///
  /// In en, this message translates to:
  /// **'Call notifications'**
  String get chat_call_notifications;

  /// No description provided for @chat_system_notification_settings.
  ///
  /// In en, this message translates to:
  /// **'Controlled by system notification settings'**
  String get chat_system_notification_settings;

  /// No description provided for @chat_on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get chat_on;

  /// No description provided for @chat_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get chat_off;

  /// No description provided for @chat_starred_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load starred messages'**
  String get chat_starred_load_failed;

  /// No description provided for @chat_no_starred_messages.
  ///
  /// In en, this message translates to:
  /// **'No starred messages'**
  String get chat_no_starred_messages;

  /// No description provided for @chat_no_starred_messages_hint.
  ///
  /// In en, this message translates to:
  /// **'Messages you star will appear here.'**
  String get chat_no_starred_messages_hint;

  /// No description provided for @chat_unstar_message.
  ///
  /// In en, this message translates to:
  /// **'Unstar message'**
  String get chat_unstar_message;

  /// No description provided for @chat_unstar_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unstar message.'**
  String get chat_unstar_failed;

  /// No description provided for @chat_message_unstarred.
  ///
  /// In en, this message translates to:
  /// **'Message unstarred.'**
  String get chat_message_unstarred;

  /// No description provided for @chat_attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get chat_attachment;

  /// No description provided for @chat_you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chat_you;

  /// No description provided for @chat_other_user.
  ///
  /// In en, this message translates to:
  /// **'Other user'**
  String get chat_other_user;

  /// No description provided for @chat_aos_user.
  ///
  /// In en, this message translates to:
  /// **'AOS user'**
  String get chat_aos_user;

  /// No description provided for @chat_sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get chat_sending;

  /// No description provided for @chat_edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get chat_edited;

  /// No description provided for @chat_starred.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get chat_starred;

  /// No description provided for @chat_translated.
  ///
  /// In en, this message translates to:
  /// **'Translated'**
  String get chat_translated;

  /// No description provided for @chat_failed_to_send.
  ///
  /// In en, this message translates to:
  /// **'Failed to send'**
  String get chat_failed_to_send;

  /// No description provided for @chat_read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get chat_read;

  /// No description provided for @chat_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get chat_delivered;

  /// No description provided for @chat_sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get chat_sent;

  /// No description provided for @chat_forwarded_label.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get chat_forwarded_label;

  /// No description provided for @chat_deleted_message.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get chat_deleted_message;

  /// No description provided for @chat_translating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get chat_translating;

  /// No description provided for @chat_tap_to_retry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get chat_tap_to_retry;

  /// No description provided for @chat_translate_to.
  ///
  /// In en, this message translates to:
  /// **'Translate to'**
  String get chat_translate_to;

  /// No description provided for @chat_translate_to_language.
  ///
  /// In en, this message translates to:
  /// **'Translate to {language}'**
  String chat_translate_to_language(Object language);

  /// No description provided for @chat_voice_release_cancel.
  ///
  /// In en, this message translates to:
  /// **'Release to cancel'**
  String get chat_voice_release_cancel;

  /// No description provided for @chat_voice_recording_locked.
  ///
  /// In en, this message translates to:
  /// **'Recording locked'**
  String get chat_voice_recording_locked;

  /// No description provided for @chat_voice_slide_cancel.
  ///
  /// In en, this message translates to:
  /// **'Slide left to cancel'**
  String get chat_voice_slide_cancel;

  /// No description provided for @chat_voice_recording_status.
  ///
  /// In en, this message translates to:
  /// **'Voice recording {duration}. {instruction}'**
  String chat_voice_recording_status(Object duration, Object instruction);

  /// No description provided for @chat_starred_message_from.
  ///
  /// In en, this message translates to:
  /// **'Starred message from {sender}'**
  String chat_starred_message_from(Object sender);

  /// No description provided for @chat_verified_sellers.
  ///
  /// In en, this message translates to:
  /// **'Verified Sellers'**
  String get chat_verified_sellers;

  /// No description provided for @chat_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get chat_friends;

  /// No description provided for @chat_search_sellers_hint.
  ///
  /// In en, this message translates to:
  /// **'Search sellers...'**
  String get chat_search_sellers_hint;

  /// No description provided for @chat_search_friends_hint.
  ///
  /// In en, this message translates to:
  /// **'Search friends...'**
  String get chat_search_friends_hint;

  /// No description provided for @chat_loading_sellers.
  ///
  /// In en, this message translates to:
  /// **'Loading sellers'**
  String get chat_loading_sellers;

  /// No description provided for @chat_loading_sellers_hint.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we find verified sellers.'**
  String get chat_loading_sellers_hint;

  /// No description provided for @chat_could_not_load_sellers.
  ///
  /// In en, this message translates to:
  /// **'Could not load sellers'**
  String get chat_could_not_load_sellers;

  /// No description provided for @chat_no_verified_sellers.
  ///
  /// In en, this message translates to:
  /// **'No verified sellers'**
  String get chat_no_verified_sellers;

  /// No description provided for @chat_no_sellers_found.
  ///
  /// In en, this message translates to:
  /// **'No sellers found'**
  String get chat_no_sellers_found;

  /// No description provided for @chat_no_verified_sellers_hint.
  ///
  /// In en, this message translates to:
  /// **'Verified sellers will appear here when available.'**
  String get chat_no_verified_sellers_hint;

  /// No description provided for @chat_no_sellers_found_hint.
  ///
  /// In en, this message translates to:
  /// **'Try another seller name, category, or location.'**
  String get chat_no_sellers_found_hint;

  /// No description provided for @chat_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get chat_refresh;

  /// No description provided for @chat_loading_friends.
  ///
  /// In en, this message translates to:
  /// **'Loading friends'**
  String get chat_loading_friends;

  /// No description provided for @chat_loading_friends_hint.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we find your friends.'**
  String get chat_loading_friends_hint;

  /// No description provided for @chat_could_not_load_friends.
  ///
  /// In en, this message translates to:
  /// **'Could not load friends'**
  String get chat_could_not_load_friends;

  /// No description provided for @chat_try_again.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get chat_try_again;

  /// No description provided for @chat_no_friends_yet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get chat_no_friends_yet;

  /// No description provided for @chat_no_friends_found.
  ///
  /// In en, this message translates to:
  /// **'No friends found'**
  String get chat_no_friends_found;

  /// No description provided for @chat_no_friends_yet_hint.
  ///
  /// In en, this message translates to:
  /// **'Friends will appear here once you follow each other.'**
  String get chat_no_friends_yet_hint;

  /// No description provided for @chat_no_friends_found_hint.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another name or email.'**
  String get chat_no_friends_found_hint;

  /// No description provided for @chat_online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get chat_online;

  /// No description provided for @chat_last_seen_recently.
  ///
  /// In en, this message translates to:
  /// **'Last seen recently'**
  String get chat_last_seen_recently;

  /// No description provided for @chat_friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get chat_friend;

  /// No description provided for @chat_message_contact.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chat_message_contact;

  /// No description provided for @chat_call_contact.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get chat_call_contact;

  /// No description provided for @chat_all_chats.
  ///
  /// In en, this message translates to:
  /// **'All Chats'**
  String get chat_all_chats;

  /// No description provided for @chat_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get chat_unread;

  /// No description provided for @chat_loading_conversations.
  ///
  /// In en, this message translates to:
  /// **'Loading conversations'**
  String get chat_loading_conversations;

  /// No description provided for @chat_loading_conversations_hint.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we fetch your chats.'**
  String get chat_loading_conversations_hint;

  /// No description provided for @chat_could_not_load_chats.
  ///
  /// In en, this message translates to:
  /// **'Could not load chats'**
  String get chat_could_not_load_chats;

  /// No description provided for @chat_no_chats_found.
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get chat_no_chats_found;

  /// No description provided for @chat_no_chats_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another name or message.'**
  String get chat_no_chats_search_hint;

  /// No description provided for @chat_no_read_chats.
  ///
  /// In en, this message translates to:
  /// **'No read chats'**
  String get chat_no_read_chats;

  /// No description provided for @chat_no_unread_chats.
  ///
  /// In en, this message translates to:
  /// **'No unread chats'**
  String get chat_no_unread_chats;

  /// No description provided for @chat_no_conversations_yet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chat_no_conversations_yet;

  /// No description provided for @chat_no_read_chats_hint.
  ///
  /// In en, this message translates to:
  /// **'Chats you have already read will appear here.'**
  String get chat_no_read_chats_hint;

  /// No description provided for @chat_no_unread_chats_hint.
  ///
  /// In en, this message translates to:
  /// **'Unread chats will appear here as new messages arrive.'**
  String get chat_no_unread_chats_hint;

  /// No description provided for @chat_no_conversations_hint.
  ///
  /// In en, this message translates to:
  /// **'Your conversations will appear here once you start chatting.'**
  String get chat_no_conversations_hint;

  /// No description provided for @chat_deleted_from_list.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted from your conversation list.'**
  String get chat_deleted_from_list;

  /// No description provided for @chat_delete_chat_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete chat. Please try again.'**
  String get chat_delete_chat_failed;

  /// No description provided for @chat_typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get chat_typing;

  /// No description provided for @chat_last_seen_time.
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String chat_last_seen_time(Object time);

  /// No description provided for @chat_forward_to_title.
  ///
  /// In en, this message translates to:
  /// **'Forward to'**
  String get chat_forward_to_title;

  /// No description provided for @chat_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get chat_close;

  /// No description provided for @chat_search_conversations_hint.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get chat_search_conversations_hint;

  /// No description provided for @chat_clear_search.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get chat_clear_search;

  /// No description provided for @chat_could_not_load_conversations.
  ///
  /// In en, this message translates to:
  /// **'Could not load conversations'**
  String get chat_could_not_load_conversations;

  /// No description provided for @chat_no_other_conversations.
  ///
  /// In en, this message translates to:
  /// **'No other conversations'**
  String get chat_no_other_conversations;

  /// No description provided for @chat_no_other_conversations_hint.
  ///
  /// In en, this message translates to:
  /// **'Start another chat first, then you can forward messages here.'**
  String get chat_no_other_conversations_hint;

  /// No description provided for @chat_no_conversations_found.
  ///
  /// In en, this message translates to:
  /// **'No conversations found'**
  String get chat_no_conversations_found;

  /// No description provided for @chat_search_conversations_empty_hint.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another name or message.'**
  String get chat_search_conversations_empty_hint;

  /// No description provided for @chat_forward_to_one_chat.
  ///
  /// In en, this message translates to:
  /// **'Forward to 1 chat'**
  String get chat_forward_to_one_chat;

  /// No description provided for @chat_forward_to_chats_count.
  ///
  /// In en, this message translates to:
  /// **'Forward to {count} chats'**
  String chat_forward_to_chats_count(Object count);

  /// No description provided for @chat_default_wallpaper_applied.
  ///
  /// In en, this message translates to:
  /// **'Default wallpaper applied.'**
  String get chat_default_wallpaper_applied;

  /// No description provided for @chat_wallpaper_updated.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper updated.'**
  String get chat_wallpaper_updated;

  /// No description provided for @chat_named_wallpaper_applied.
  ///
  /// In en, this message translates to:
  /// **'{name} wallpaper applied.'**
  String chat_named_wallpaper_applied(Object name);

  /// No description provided for @chat_choose_conversation_background.
  ///
  /// In en, this message translates to:
  /// **'Choose a background for this conversation'**
  String get chat_choose_conversation_background;

  /// No description provided for @chat_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get chat_default;

  /// No description provided for @chat_choose_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chat_choose_from_gallery;

  /// No description provided for @chat_solid_colors.
  ///
  /// In en, this message translates to:
  /// **'Solid colors'**
  String get chat_solid_colors;

  /// No description provided for @chat_emoji_recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get chat_emoji_recent;

  /// No description provided for @chat_emoji_smileys.
  ///
  /// In en, this message translates to:
  /// **'Smileys'**
  String get chat_emoji_smileys;

  /// No description provided for @chat_emoji_animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get chat_emoji_animals;

  /// No description provided for @chat_emoji_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get chat_emoji_food;

  /// No description provided for @chat_emoji_flags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get chat_emoji_flags;

  /// No description provided for @chat_search_emoji.
  ///
  /// In en, this message translates to:
  /// **'Search emoji'**
  String get chat_search_emoji;

  /// No description provided for @chat_no_emoji_found.
  ///
  /// In en, this message translates to:
  /// **'No emoji found'**
  String get chat_no_emoji_found;

  /// No description provided for @chat_share_contact.
  ///
  /// In en, this message translates to:
  /// **'Share a contact'**
  String get chat_share_contact;

  /// No description provided for @chat_search_aos_users.
  ///
  /// In en, this message translates to:
  /// **'Search AOS users'**
  String get chat_search_aos_users;

  /// No description provided for @chat_could_not_load_contacts.
  ///
  /// In en, this message translates to:
  /// **'Could not load contacts'**
  String get chat_could_not_load_contacts;

  /// No description provided for @chat_search_people_on_aos.
  ///
  /// In en, this message translates to:
  /// **'Search people on AOS'**
  String get chat_search_people_on_aos;

  /// No description provided for @chat_search_people_hint.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to find a contact to share.'**
  String get chat_search_people_hint;

  /// No description provided for @chat_no_contacts_found.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get chat_no_contacts_found;

  /// No description provided for @chat_no_contacts_found_hint.
  ///
  /// In en, this message translates to:
  /// **'Try another name, username, or email.'**
  String get chat_no_contacts_found_hint;

  /// No description provided for @chat_unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get chat_unmute;

  /// No description provided for @chat_mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get chat_mute;

  /// No description provided for @chat_end_call.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get chat_end_call;

  /// No description provided for @chat_calling.
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get chat_calling;

  /// No description provided for @chat_ringing.
  ///
  /// In en, this message translates to:
  /// **'Ringing'**
  String get chat_ringing;

  /// No description provided for @chat_incoming_call.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get chat_incoming_call;

  /// No description provided for @chat_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get chat_connecting;

  /// No description provided for @chat_delete_chat_title.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get chat_delete_chat_title;

  /// No description provided for @chat_delete_chat_description.
  ///
  /// In en, this message translates to:
  /// **'This will remove your chat with {name} from your conversation list. It will not delete it for the other user.'**
  String chat_delete_chat_description(Object name);

  /// No description provided for @chat_this_user.
  ///
  /// In en, this message translates to:
  /// **'this user'**
  String get chat_this_user;

  /// No description provided for @chat_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chat_delete;

  /// No description provided for @chat_view_profile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get chat_view_profile;

  /// No description provided for @chat_view_contact.
  ///
  /// In en, this message translates to:
  /// **'View contact'**
  String get chat_view_contact;

  /// No description provided for @chat_cannot_open_document.
  ///
  /// In en, this message translates to:
  /// **'Cannot open this type of document'**
  String get chat_cannot_open_document;

  /// No description provided for @chat_failed_to_start_chat.
  ///
  /// In en, this message translates to:
  /// **'Failed to start chat. Please try again.'**
  String get chat_failed_to_start_chat;

  /// No description provided for @chat_invalid_conversation_response.
  ///
  /// In en, this message translates to:
  /// **'Invalid conversation response'**
  String get chat_invalid_conversation_response;

  /// No description provided for @chat_voice_hold_to_record.
  ///
  /// In en, this message translates to:
  /// **'Hold to record a voice message'**
  String get chat_voice_hold_to_record;

  /// No description provided for @chat_voice_tap_to_record.
  ///
  /// In en, this message translates to:
  /// **'Tap to record a voice message'**
  String get chat_voice_tap_to_record;

  /// No description provided for @chat_voice_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause recording'**
  String get chat_voice_pause;

  /// No description provided for @chat_voice_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume recording'**
  String get chat_voice_resume;

  /// No description provided for @chat_voice_delete_recording.
  ///
  /// In en, this message translates to:
  /// **'Delete recording'**
  String get chat_voice_delete_recording;

  /// No description provided for @chat_voice_send_recording.
  ///
  /// In en, this message translates to:
  /// **'Send voice message'**
  String get chat_voice_send_recording;

  /// No description provided for @chat_voice_release_to_finish.
  ///
  /// In en, this message translates to:
  /// **'Release to finish voice recording'**
  String get chat_voice_release_to_finish;

  /// No description provided for @chat_microphone_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied.'**
  String get chat_microphone_permission_denied;

  /// No description provided for @chat_voice_record_start_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not start voice recording.'**
  String get chat_voice_record_start_failed;

  /// No description provided for @chat_voice_record_finish_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not finish voice recording.'**
  String get chat_voice_record_finish_failed;

  /// No description provided for @chat_language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get chat_language_english;

  /// No description provided for @chat_language_swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get chat_language_swahili;

  /// No description provided for @chat_language_french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get chat_language_french;

  /// No description provided for @chat_language_spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get chat_language_spanish;

  /// No description provided for @chat_language_german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get chat_language_german;

  /// No description provided for @chat_language_portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get chat_language_portuguese;

  /// No description provided for @chat_language_arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get chat_language_arabic;

  /// No description provided for @chat_language_hausa.
  ///
  /// In en, this message translates to:
  /// **'Hausa'**
  String get chat_language_hausa;

  /// No description provided for @chat_language_yoruba.
  ///
  /// In en, this message translates to:
  /// **'Yoruba'**
  String get chat_language_yoruba;

  /// No description provided for @chat_language_igbo.
  ///
  /// In en, this message translates to:
  /// **'Igbo'**
  String get chat_language_igbo;

  /// No description provided for @chat_language_amharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get chat_language_amharic;

  /// No description provided for @chat_language_somali.
  ///
  /// In en, this message translates to:
  /// **'Somali'**
  String get chat_language_somali;

  /// No description provided for @chat_language_kinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Kinyarwanda'**
  String get chat_language_kinyarwanda;

  /// No description provided for @chat_language_luganda.
  ///
  /// In en, this message translates to:
  /// **'Luganda'**
  String get chat_language_luganda;

  /// No description provided for @chat_language_zulu.
  ///
  /// In en, this message translates to:
  /// **'Zulu'**
  String get chat_language_zulu;

  /// No description provided for @chat_language_xhosa.
  ///
  /// In en, this message translates to:
  /// **'Xhosa'**
  String get chat_language_xhosa;

  /// No description provided for @chat_wallpaper_midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get chat_wallpaper_midnight;

  /// No description provided for @chat_wallpaper_navy.
  ///
  /// In en, this message translates to:
  /// **'Navy'**
  String get chat_wallpaper_navy;

  /// No description provided for @chat_wallpaper_forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get chat_wallpaper_forest;

  /// No description provided for @chat_wallpaper_plum.
  ///
  /// In en, this message translates to:
  /// **'Plum'**
  String get chat_wallpaper_plum;

  /// No description provided for @chat_wallpaper_charcoal.
  ///
  /// In en, this message translates to:
  /// **'Charcoal'**
  String get chat_wallpaper_charcoal;

  /// No description provided for @chat_wallpaper_maroon.
  ///
  /// In en, this message translates to:
  /// **'Maroon'**
  String get chat_wallpaper_maroon;

  /// No description provided for @chat_wallpaper_teal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get chat_wallpaper_teal;

  /// No description provided for @chat_wallpaper_coffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get chat_wallpaper_coffee;

  /// No description provided for @chat_audio_call.
  ///
  /// In en, this message translates to:
  /// **'Audio call'**
  String get chat_audio_call;

  /// No description provided for @chat_clear_chat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get chat_clear_chat;

  /// No description provided for @chat_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get chat_audio;

  /// No description provided for @chat_view_replied_message.
  ///
  /// In en, this message translates to:
  /// **'View replied message'**
  String get chat_view_replied_message;

  /// No description provided for @chat_replied_message_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The replied message is no longer available.'**
  String get chat_replied_message_unavailable;

  /// No description provided for @chat_clear_chat_title.
  ///
  /// In en, this message translates to:
  /// **'Clear chat?'**
  String get chat_clear_chat_title;

  /// No description provided for @chat_clear_chats_title.
  ///
  /// In en, this message translates to:
  /// **'Clear chats?'**
  String get chat_clear_chats_title;

  /// No description provided for @chat_clear_chat_description.
  ///
  /// In en, this message translates to:
  /// **'This clears all visible messages in this chat for you only. The other participant will keep their copy.'**
  String get chat_clear_chat_description;

  /// No description provided for @chat_clear_selected_chats_description.
  ///
  /// In en, this message translates to:
  /// **'Clear the visible messages in {count} selected chats for you only? Other participants will keep their copies.'**
  String chat_clear_selected_chats_description(Object count);

  /// No description provided for @chat_chat_cleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared.'**
  String get chat_chat_cleared;

  /// No description provided for @chat_clear_chat_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not clear the chat.'**
  String get chat_clear_chat_failed;

  /// No description provided for @chat_select_conversations.
  ///
  /// In en, this message translates to:
  /// **'Select conversations'**
  String get chat_select_conversations;

  /// No description provided for @chat_selected_conversations.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String chat_selected_conversations(Object count);

  /// No description provided for @chat_cancel_selection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get chat_cancel_selection;

  /// No description provided for @chat_mark_as_read.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get chat_mark_as_read;

  /// No description provided for @chat_clear_chats.
  ///
  /// In en, this message translates to:
  /// **'Clear chats'**
  String get chat_clear_chats;

  /// No description provided for @chat_delete_conversations.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get chat_delete_conversations;

  /// No description provided for @chat_delete_conversations_title.
  ///
  /// In en, this message translates to:
  /// **'Delete conversations?'**
  String get chat_delete_conversations_title;

  /// No description provided for @chat_delete_selected_conversations_description.
  ///
  /// In en, this message translates to:
  /// **'This will remove {count} selected conversations from your conversation list. It will not delete them for the other participants.'**
  String chat_delete_selected_conversations_description(Object count);

  /// No description provided for @chat_selected_marked_read.
  ///
  /// In en, this message translates to:
  /// **'{count} selected chats marked as read.'**
  String chat_selected_marked_read(Object count);

  /// No description provided for @chat_selected_chats_cleared.
  ///
  /// In en, this message translates to:
  /// **'{count} selected chats cleared.'**
  String chat_selected_chats_cleared(Object count);

  /// No description provided for @chat_selected_chats_deleted.
  ///
  /// In en, this message translates to:
  /// **'{count} selected conversations deleted.'**
  String chat_selected_chats_deleted(Object count);

  /// No description provided for @chat_selected_action_partial_failure.
  ///
  /// In en, this message translates to:
  /// **'Some selected conversations could not be updated.'**
  String get chat_selected_action_partial_failure;

  /// No description provided for @profilePhotoRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profilePhotoRemoveAction;

  /// No description provided for @profilePhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed.'**
  String get profilePhotoRemoved;

  /// No description provided for @sellerBannerChangeAction.
  ///
  /// In en, this message translates to:
  /// **'Change banner'**
  String get sellerBannerChangeAction;

  /// No description provided for @sellerBannerRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove banner'**
  String get sellerBannerRemoveAction;

  /// No description provided for @sellerBannerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Store banner updated.'**
  String get sellerBannerUpdated;

  /// No description provided for @sellerBannerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Store banner removed.'**
  String get sellerBannerRemoved;
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
