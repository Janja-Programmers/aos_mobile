// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get onboarding_language_title => 'Chagua Lugha Yako';

  @override
  String get onboarding_language_subtitle =>
      'Programu itaonekana katika lugha uliyochagua';

  @override
  String get onboarding_language_placeholder => 'Chagua lugha yako';

  @override
  String get onboarding_language_picker => 'Chagua Lugha';

  @override
  String get onboarding_use_current_location => 'Tumia eneo la sasa';

  @override
  String get onboarding_use_country_currency => 'Tumia sarafu ya nchi';

  @override
  String get onboarding_loading_title => 'Inapakia chaguo';

  @override
  String get onboarding_loading_message =>
      'Tunapakia chaguo zako za usanidi. Unaweza kujaribu tena au kuruka kwa sasa.';

  @override
  String get onboarding_offline_title => 'Hakuna muunganisho wa intaneti';

  @override
  String get onboarding_offline_message =>
      'Hatukuweza kupakia chaguo hizi. Jaribu tena ukiwa umeunganishwa, au ruka kwa sasa bila kuhifadhi chaguo zilizobuniwa.';

  @override
  String get common_try_again => 'Jaribu tena';

  @override
  String get common_no_languages => 'Hakuna lugha zinazopatikana';

  @override
  String get common_no_countries => 'Hakuna nchi zinazopatikana';

  @override
  String get common_search => 'Tafuta';

  @override
  String get common_no_results => 'Hakuna chaguo zinazolingana';

  @override
  String get common_save => 'Hifadhi';

  @override
  String get common_discard_changes_title => 'Tupilia mbali mabadiliko?';

  @override
  String get common_discard_changes_message =>
      'Una mabadiliko ambayo hayajahifadhiwa. Unataka kuyatupilia mbali?';

  @override
  String get common_keep_editing => 'Endelea kuhariri';

  @override
  String get common_discard => 'Tupilia mbali';

  @override
  String get common_selection_required => 'Chagua chaguo halali ili kuendelea.';

  @override
  String get onboarding_currency_title => 'Chagua Sarafu Yako';

  @override
  String get onboarding_currency_subtitle =>
      'Bei zitaonyeshwa kwa sarafu uliyochagua';

  @override
  String get onboarding_currency_placeholder => 'Chagua sarafu yako';

  @override
  String get onboarding_currency_picker => 'Chagua Sarafu';

  @override
  String get onboarding_country_title => 'Weka Nchi Yako';

  @override
  String get onboarding_country_subtitle =>
      'Tutakuonyesha bidhaa na wauzaji walio karibu nawe';

  @override
  String get onboarding_country_placeholder => 'Chagua nchi yako';

  @override
  String get onboarding_country_picker => 'Chagua Nchi';

  @override
  String get common_continue => 'Endelea';

  @override
  String get common_skip_for_now => 'Ruka kwa sasa';

  @override
  String get common_get_started => 'Anza';

  @override
  String get common_no_currencies => 'Hakuna sarafu zilizopatikana';

  @override
  String get auth_register_title => 'Jisajili';

  @override
  String get auth_register_subtitle =>
      'Ingiza maelezo yako hapa chini kuunda akaunti yako';

  @override
  String get auth_full_name => 'Jina Kamili';

  @override
  String get auth_email_address => 'Barua Pepe';

  @override
  String get auth_password => 'Nenosiri';

  @override
  String get auth_confirm_password => 'Thibitisha Nenosiri';

  @override
  String get auth_accept_terms_error =>
      'Tafadhali kubali Masharti na Sera ya Faragha';

  @override
  String get auth_terms_and_conditions => 'Masharti na Vigezo';

  @override
  String get auth_privacy_policy => 'Sera ya Faragha';

  @override
  String get auth_agree_prefix => 'Ninakubali ';

  @override
  String get auth_and => ' na ';

  @override
  String get auth_register_button => 'Jisajili';

  @override
  String auth_unexpected_error(Object error) {
    return 'Hitilafu isiyotarajiwa: $error';
  }

  @override
  String get auth_already_have_account => 'Tayari una akaunti?';

  @override
  String get auth_login => 'Ingia';

  @override
  String get auth_login_title => 'Habari, Karibu Tena';

  @override
  String get auth_login_subtitle => 'Ingia kwenye akaunti yako hapa chini';

  @override
  String get auth_remember_me => 'Nikumbuke';

  @override
  String get auth_forgot_password => 'Umesahau Nenosiri?';

  @override
  String get auth_login_button => 'Ingia';

  @override
  String get auth_no_account => 'Huna akaunti?';

  @override
  String get auth_register => 'Jisajili';

  @override
  String get auth_continue_google => 'Endelea na Google';

  @override
  String get auth_or => 'au';

  @override
  String get auth_send_otp => 'Tuma OTP';

  @override
  String get auth_mail_reset_password =>
      'Weka barua pepe yako kurejesha nenosiri';

  @override
  String get auth_password_updated_title =>
      'Nenosiri Limebadilishwa\nKwa Mafanikio';

  @override
  String get auth_password_updated_message =>
      'Nenosiri lako limebadilishwa kwa mafanikio';

  @override
  String get auth_password_updated_button => 'Endelea Kuingia';

  @override
  String get auth_email_verification_title => 'Uthibitishaji wa Barua Pepe';

  @override
  String get auth_enter_verification_code => 'Weka Msimbo wa Uthibitisho';

  @override
  String get auth_verification_code_sent_to =>
      'Tumetuma msimbo wa uthibitisho kwa';

  @override
  String get auth_email_verified_title =>
      'Barua Pepe Imethibitishwa\nKwa Mafanikio';

  @override
  String get auth_email_verified_message =>
      'Barua pepe yako imethibitishwa kwa mafanikio';

  @override
  String get auth_email_verified_button => 'Endelea Kuingia';

  @override
  String get auth_digit_code => 'Weka msimbo wa tarakimu 6';

  @override
  String get auth_resend_code => 'Hujapokea msimbo? ';

  @override
  String get auth_resend => 'Tuma tena';

  @override
  String get auth_resend_in => 'Tuma tena baada ya ';

  @override
  String get nav_home => 'Nyumbani';

  @override
  String get nav_categories => 'Makundi';

  @override
  String get nav_selling => 'Kuuza';

  @override
  String get nav_contact => 'Wasiliana';

  @override
  String get nav_account => 'Akaunti';

  @override
  String get common_see_all => 'Tazama zote';

  @override
  String get home_flash_sales => 'Mauzo ya Haraka AOS';

  @override
  String get home_services_near_you => 'Huduma Karibu Nawe';

  @override
  String get home_new_products => 'Bidhaa Mpya AOS';

  @override
  String get home_electronic_deals => 'Ofa za Elektroniki AOS';

  @override
  String get home_deals => 'Ofa AOS';

  @override
  String get home_furniture => 'Samani';

  @override
  String get home_electronics => 'Elektroniki';

  @override
  String get home_fashion => 'Mitindo';

  @override
  String get home_babies_kids => 'Watoto';

  @override
  String get home_beauty => 'Urembo';

  @override
  String get home_photography_tips => 'Vidokezo vya upigaji picha';

  @override
  String get home_boost_marketing_reach => 'Ongeza kufikia wateja';

  @override
  String get home_ranking_tips => 'Jaribu vidokezo bora vya upangaji';

  @override
  String get home_learn => 'Jifunze';

  @override
  String get home_top_deals => 'Ofa Bora';

  @override
  String get home_best_prices => 'Bei Bora';

  @override
  String get home_shop_now => 'Nunua Sasa';

  @override
  String get home_you_might_be_looking_for => 'Huenda unatafuta';

  @override
  String get ads_no_more_ads => 'Hakuna matangazo zaidi';

  @override
  String get location_all_locations => 'Maeneo yote';

  @override
  String get search_placeholder => 'Tafuta hapa...';

  @override
  String get search_button => 'Tafuta';

  @override
  String get ads_my_listings => 'Matangazo Yangu';

  @override
  String get ads_no_listings_yet => 'Hakuna Matangazo Bado';

  @override
  String get ads_no_listings_message => 'Bado hujaweka tangazo lolote.';

  @override
  String get ads_start_selling_message =>
      'Anza kuuza kwa kuweka tangazo lako la kwanza';

  @override
  String get ads_post_first_ad => 'Weka Tangazo Lako la Kwanza';

  @override
  String get ads_learn_sell_faster => 'Jifunze kuuza haraka';

  @override
  String get ads_create_ad => 'Unda Tangazo';

  @override
  String get ads_update_ad => 'Sasisha Tangazo';

  @override
  String get account_title => 'Akaunti';

  @override
  String get account_get_verified => 'Thibitisha Akaunti';

  @override
  String get account_boost_trust => 'Ongeza uaminifu na uhalali';

  @override
  String get account_settings => 'Mipangilio ya Akaunti';

  @override
  String get account_passwords_security => 'Nenosiri na Usalama';

  @override
  String get account_notifications_preferences => 'Mapendeleo ya Arifa';

  @override
  String get account_guest_title => 'Karibu AOS';

  @override
  String get account_guest_description =>
      'Ingia ili kufikia akaunti yako, kudhibiti matangazo, na zaidi';

  @override
  String get app_preferences => 'Mapendeleo ya Programu';

  @override
  String get settings_dark_mode => 'Mandhari ya Giza';

  @override
  String get common_other => 'Nyingine';

  @override
  String get common_discover_more => 'Gundua zaidi';

  @override
  String get settings_privacy_policy => 'Sera ya Faragha';

  @override
  String get settings_preferences => 'Mapendeleo';

  @override
  String get settings_manage_app =>
      'Dhibiti jinsi programu inavyokufanyia kazi';

  @override
  String get settings_language => 'Lugha';

  @override
  String get settings_language_description =>
      'Hudhibiti jinsi maandishi yanavyoonekana kwenye programu.';

  @override
  String get settings_country => 'Nchi';

  @override
  String get settings_country_description =>
      'Huamua matangazo yaliyo karibu na mahali matangazo yako yataonekana.';

  @override
  String get settings_currency => 'Sarafu';

  @override
  String get settings_currency_description =>
      'Hutumika kwa bei wakati wa kuangalia na kuchapisha matangazo.';

  @override
  String get settings_terms_conditions => 'Masharti na Vigezo';

  @override
  String get onboarding_preference_error =>
      'Hatukuweza kuhifadhi chaguo lako. Tafadhali jaribu tena.';

  @override
  String get session_restore_offline_title => 'Hujaunganishwa kwenye intaneti';

  @override
  String get session_restore_offline_message =>
      'AOS haikuweza kuthibitisha kipindi chako kilichopo. Unganisha intaneti kisha ujaribu tena. Kipindi chako kilichohifadhiwa hakijafutwa.';

  @override
  String get session_restore_unavailable_title =>
      'Hatukuweza kurejesha kipindi chako';

  @override
  String get session_restore_unavailable_message =>
      'AOS haiwezi kuthibitisha kipindi chako kilichopo kwa sasa. Jaribu tena. Kipindi chako kilichohifadhiwa hakijafutwa.';

  @override
  String get privacy_cover_accessibility_label =>
      'AOS inalinda taarifa za akaunti yako.';

  @override
  String get appLockScreenAccessibilityLabel => 'AOS imefungwa';

  @override
  String get appLockTitle => 'Fungua AOS';

  @override
  String get appLockPrompt => 'Weka kufuli ya programu kuendelea.';

  @override
  String get appLockUnlock => 'Fungua';

  @override
  String get appLockAuthenticating => 'Inathibitisha…';

  @override
  String get appLockLogout => 'Ondoka';

  @override
  String get appLockForgottenCredentialHelp =>
      'Weka upya kufuli ili utoke na kuondoa taarifa ya kufuli iliyosahaulika.';

  @override
  String get appLockUnlockReason => 'Thibitisha ili kufungua AOS.';

  @override
  String get appLockEnableReason => 'Thibitisha kuwasha kufuli ya biometriki.';

  @override
  String get appLockDisableReason => 'Thibitisha kuzima kufuli ya programu.';

  @override
  String get appLockCancelled =>
      'Uthibitishaji umeghairiwa. Akaunti yako bado imeingia.';

  @override
  String get appLockTemporaryLockout =>
      'Majaribio mengi sana. Jaribu tena baadaye au weka upya kufuli ya programu.';

  @override
  String get appLockPermanentLockout =>
      'Biometriki zimefungwa. Tumia urejeshaji wa kifaa au weka upya kufuli.';

  @override
  String get appLockNoDeviceCredential =>
      'Sanidi alama ya kidole, Face ID au biometriki nyingine kwenye mipangilio ya kifaa kwanza.';

  @override
  String get appLockUnsupported =>
      'Uthibitishaji wa kifaa haupatikani kwenye kifaa hiki.';

  @override
  String get appLockTryAgain => 'Jaribu tena';

  @override
  String get appLockFailed => 'Uthibitishaji umeshindwa. Jaribu tena.';

  @override
  String get appLockSettingTitle => 'Kufuli ya Programu';

  @override
  String get appLockSettingDescription =>
      'Linda sehemu binafsi kwa PIN ya tarakimu 4, mchoro au biometriki.';

  @override
  String get appLockTimingTitle => 'Muda wa kufunga';

  @override
  String get appLockTimingImmediately => 'Mara moja';

  @override
  String get appLockTimingThirtySeconds => 'Baada ya sekunde 30';

  @override
  String get appLockTimingOneMinute => 'Baada ya dakika 1';

  @override
  String get appLockTimingFiveMinutes => 'Baada ya dakika 5';

  @override
  String get wishlist_add => 'Ongeza kwenye vipendwa';

  @override
  String get wishlist_remove => 'Ondoa kwenye vipendwa';

  @override
  String get wishlist_update_error =>
      'Hatukuweza kusasisha vipendwa vyako. Tafadhali jaribu tena.';

  @override
  String get appLockBiometricPrompt =>
      'Tumia alama ya kidole, uso au biometriki nyingine iliyosajiliwa kuendelea.';

  @override
  String get appLockUseBiometrics => 'Tumia biometriki';

  @override
  String get appLockReset => 'Weka upya kufuli ya programu';

  @override
  String get appLockResetHelp =>
      'Umesahau PIN au mchoro? Kuweka upya kutakuondoa kwenye akaunti na kufuta kufuli ya ndani.';

  @override
  String get appLockResetTitle => 'Weka upya kufuli ya programu?';

  @override
  String get appLockResetMessage =>
      'Hii itakuondoa kwenye akaunti, kufuta kufuli iliyohifadhiwa na kurudisha kwenye sehemu ya umma. Ingia tena kuweka kufuli mpya.';

  @override
  String get appLockResetConfirm => 'Weka upya na utoke';

  @override
  String get appLockCancel => 'Ghairi';

  @override
  String get appLockClear => 'Futa';

  @override
  String get appLockEnterPin => 'Weka PIN yako ya tarakimu 4';

  @override
  String get appLockEnterPattern => 'Chora mchoro wako';

  @override
  String get appLockInvalidCredential => 'Kufuli hiyo si sahihi. Jaribu tena.';

  @override
  String get appLockPinHelp => 'Tumia tarakimu 4 kamili.';

  @override
  String get appLockPatternHelp => 'Unganisha angalau nukta 4.';

  @override
  String get appLockConfirmPin => 'Thibitisha PIN yako';

  @override
  String get appLockConfirmPattern => 'Thibitisha mchoro wako';

  @override
  String get appLockConfirmationMismatch =>
      'Uthibitisho haufanani. Jaribu tena.';

  @override
  String get appLockContinue => 'Endelea';

  @override
  String get appLockConfirm => 'Thibitisha';

  @override
  String get appLockStorageFailure =>
      'Mipangilio ya kufuli haikuweza kuhifadhiwa kwa usalama. Jaribu tena.';

  @override
  String get appLockConfigured => 'Kufuli ya programu imewashwa';

  @override
  String get appLockProcessRestartNote =>
      'AOS hufungwa kila programu inapofungwa kabisa au kuwashwa upya.';

  @override
  String get appLockChangeMethod => 'Badilisha njia ya kufuli';

  @override
  String get appLockDisable => 'Zima kufuli ya programu';

  @override
  String get appLockChooseMethod => 'Chagua njia ya kufuli';

  @override
  String get appLockMethodHelp =>
      'PIN na mchoro huhifadhiwa kama hash salama yenye chumvi. Data ya biometriki inasimamiwa na kifaa chako.';

  @override
  String get appLockMethodPin => 'PIN ya tarakimu 4';

  @override
  String get appLockMethodPattern => 'Mchoro';

  @override
  String get appLockMethodBiometric => 'Alama ya kidole au biometriki';

  @override
  String get appLockChangeReason =>
      'Thibitisha ili kubadilisha kufuli ya programu.';

  @override
  String get appLockTimingFiveSeconds => 'Baada ya sekunde 5';

  @override
  String get appLockTimingTenSeconds => 'Baada ya sekunde 10';

  @override
  String get appLockTimingFifteenSeconds => 'Baada ya sekunde 15';

  @override
  String get appLockPinInputAccessibility => 'Uingizaji wa PIN';

  @override
  String get appLockPatternInputAccessibility => 'Uingizaji wa mchoro';

  @override
  String get appLockPatternPointAccessibility => 'Nukta ya mchoro';

  @override
  String get ads_location_select_title => 'Chagua eneo';

  @override
  String ads_location_results_more(Object count) {
    return 'Zaidi ya maeneo $count yamepatikana';
  }

  @override
  String ads_location_results_exact(Object count) {
    return 'Maeneo $count yamepatikana';
  }

  @override
  String get ad_media_download_image => 'Pakua picha';

  @override
  String get ad_media_saved_to_gallery => 'Picha imehifadhiwa kwenye matunzio.';

  @override
  String get liveLikeAction => 'Penda mubashara';

  @override
  String get liveShareAction => 'Shiriki mubashara';

  @override
  String get liveMuteAction => 'Zima maikrofoni';

  @override
  String get liveUnmuteAction => 'Washa maikrofoni';

  @override
  String get liveFlipCameraAction => 'Geuza kamera';

  @override
  String get watchThisLiveOnAos => 'Tazama mubashara huu kwenye AOS';

  @override
  String get unableToOpenShareOptions =>
      'Imeshindikana kufungua chaguo za kushiriki.';
}
