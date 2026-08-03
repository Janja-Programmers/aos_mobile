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

  @override
  String get chat_connect_title => 'AOS Connect';

  @override
  String get chat_close_connect => 'Funga Connect';

  @override
  String get chat_close_search => 'Funga utafutaji';

  @override
  String get chat_search => 'Tafuta';

  @override
  String get chat_more_options => 'Chaguo zaidi';

  @override
  String get chat_search_chats_hint => 'Tafuta mazungumzo…';

  @override
  String get chat_search_calls_hint => 'Tafuta simu…';

  @override
  String get chat_all_marked_read =>
      'Mazungumzo yote yametiwa alama kuwa yamesomwa.';

  @override
  String get chat_some_mark_read_failed =>
      'Baadhi ya mazungumzo hayakuweza kutiwa alama kuwa yamesomwa.';

  @override
  String get chat_clear_call_log_title => 'Futa historia ya simu?';

  @override
  String get chat_clear_call_log_body =>
      'Hii huondoa historia ya simu unayoiona. Haifuti rekodi za watumiaji wengine.';

  @override
  String get chat_cancel => 'Ghairi';

  @override
  String get chat_clear => 'Futa';

  @override
  String get chat_call_log_cleared => 'Historia ya simu imefutwa.';

  @override
  String get chat_call_log_clear_failed =>
      'Imeshindikana kufuta historia ya simu.';

  @override
  String get chat_clear_call_log => 'Futa historia ya simu';

  @override
  String get chat_settings => 'Mipangilio';

  @override
  String get chat_mark_all_read => 'Tia zote alama kuwa zimesomwa';

  @override
  String get chat_starred_messages => 'Ujumbe wenye nyota';

  @override
  String get chat_chats => 'Mazungumzo';

  @override
  String get chat_new_conversation => 'Mazungumzo mapya';

  @override
  String get chat_new => 'Mpya';

  @override
  String get chat_calls => 'Simu';

  @override
  String get chat_back => 'Rudi';

  @override
  String get chat_call => 'Piga simu';

  @override
  String get chat_video_call => 'Simu ya video';

  @override
  String get chat_change_wallpaper => 'Badilisha mandhari';

  @override
  String get chat_user_might_be_offline => 'Huenda mtumiaji hayuko mtandaoni';

  @override
  String get chat_failed_to_start_call => 'Imeshindikana kuanzisha simu';

  @override
  String get chat_gallery => 'Matunzio';

  @override
  String get chat_camera => 'Kamera';

  @override
  String get chat_voice_call => 'Simu ya sauti';

  @override
  String get chat_location => 'Mahali';

  @override
  String get chat_document => 'Hati';

  @override
  String get chat_contact => 'Mwasiliani';

  @override
  String get chat_attachment_upload_failed =>
      'Upakiaji wa kiambatisho umeshindikana. Jaribu tena.';

  @override
  String get chat_message_hint => 'Ujumbe';

  @override
  String get chat_share_location_title => 'Shiriki mahali';

  @override
  String get chat_retry => 'Jaribu tena';

  @override
  String get chat_could_not_load_messages => 'Imeshindikana kupakia ujumbe';

  @override
  String get chat_check_connection_try_again =>
      'Angalia muunganisho wako kisha ujaribu tena.';

  @override
  String get chat_no_messages_yet => 'Bado hakuna ujumbe';

  @override
  String get chat_no_messages_hint => 'Tuma ujumbe ili kuanza mazungumzo haya.';

  @override
  String get chat_older_messages_load_failed =>
      'Ujumbe wa zamani haukuweza kupakiwa.';

  @override
  String get chat_reply => 'Jibu';

  @override
  String get chat_edit => 'Hariri';

  @override
  String get chat_copy => 'Nakili';

  @override
  String get chat_forward => 'Sambaza';

  @override
  String get chat_translate_again => 'Tafsiri tena';

  @override
  String get chat_translate => 'Tafsiri';

  @override
  String get chat_unstar => 'Ondoa nyota';

  @override
  String get chat_star => 'Weka nyota';

  @override
  String get chat_delete_for_me => 'Futa kwangu';

  @override
  String get chat_delete_for_everyone => 'Futa kwa kila mtu';

  @override
  String get chat_message_reactions => 'Miitikio ya ujumbe';

  @override
  String get chat_choose_another_reaction => 'Chagua mwitikio mwingine';

  @override
  String chat_react_with(Object emoji) {
    return 'Jibu kwa $emoji';
  }

  @override
  String chat_remove_reaction(Object emoji) {
    return 'Ondoa mwitikio wa $emoji';
  }

  @override
  String get chat_editing_message => 'Inahariri ujumbe';

  @override
  String get chat_cancel_editing => 'Ghairi kuhariri';

  @override
  String get chat_copied_to_clipboard => 'Imenakiliwa kwenye ubao wa kunakili';

  @override
  String get chat_message_still_failed =>
      'Ujumbe bado haujatumwa. Jaribu tena.';

  @override
  String get chat_send_ad_failed =>
      'Imeshindikana kutuma ujumbe wa tangazo. Jaribu tena.';

  @override
  String get chat_send_failed => 'Imeshindikana kutuma ujumbe. Jaribu tena.';

  @override
  String get chat_star_update_failed => 'Imeshindikana kusasisha nyota.';

  @override
  String get chat_reaction_update_failed => 'Imeshindikana kusasisha mwitikio.';

  @override
  String get chat_forward_failed => 'Imeshindikana kusambaza ujumbe.';

  @override
  String get chat_forwarded => 'Ujumbe umesambazwa.';

  @override
  String chat_forwarded_to_chats(Object count) {
    return 'Ujumbe umesambazwa kwenye mazungumzo $count.';
  }

  @override
  String get chat_translate_failed => 'Imeshindikana kutafsiri ujumbe.';

  @override
  String get chat_delete_failed => 'Imeshindikana kufuta ujumbe.';

  @override
  String get chat_deleted_for_everyone => 'Ujumbe umefutwa kwa kila mtu.';

  @override
  String get chat_deleted_for_you => 'Ujumbe umefutwa kwako.';

  @override
  String get chat_edit_failed => 'Imeshindikana kuhariri ujumbe.';

  @override
  String get chat_settings_title => 'Mipangilio ya Mazungumzo';

  @override
  String get chat_privacy => 'Faragha';

  @override
  String get chat_read_receipts => 'Uthibitisho wa kusoma';

  @override
  String get chat_read_receipts_managed =>
      'Inasimamiwa na AOS kwa uwasilishaji wa ujumbe';

  @override
  String get chat_last_seen_online => 'Mara ya mwisho kuonekana na mtandaoni';

  @override
  String get chat_no_backend_preference =>
      'Seva haitoi mpangilio huu wa akaunti';

  @override
  String get chat_blocked_contacts => 'Watu waliozuiwa';

  @override
  String get chat_chats_section => 'Mazungumzo';

  @override
  String get chat_wallpaper => 'Mandhari ya mazungumzo';

  @override
  String get chat_wallpaper_description =>
      'Weka mandhari chaguomsingi ya mazungumzo';

  @override
  String get chat_enter_is_send => 'Enter hutuma';

  @override
  String get chat_enter_is_send_description =>
      'Kitufe cha Enter hutuma ujumbe wako';

  @override
  String get chat_media_auto_download => 'Upakuaji otomatiki wa media';

  @override
  String get chat_unavailable_backend =>
      'Haipatikani katika mkataba wa sasa wa seva';

  @override
  String get chat_notifications => 'Arifa';

  @override
  String get chat_message_notifications => 'Arifa za ujumbe';

  @override
  String get chat_call_notifications => 'Arifa za simu';

  @override
  String get chat_system_notification_settings =>
      'Inadhibitiwa na mipangilio ya arifa ya mfumo';

  @override
  String get chat_on => 'Imewashwa';

  @override
  String get chat_off => 'Imezimwa';

  @override
  String get chat_starred_load_failed =>
      'Imeshindikana kupakia ujumbe wenye nyota';

  @override
  String get chat_no_starred_messages => 'Hakuna ujumbe wenye nyota';

  @override
  String get chat_no_starred_messages_hint =>
      'Ujumbe unaoweka nyota utaonekana hapa.';

  @override
  String get chat_unstar_message => 'Ondoa nyota kwenye ujumbe';

  @override
  String get chat_unstar_failed => 'Imeshindikana kuondoa nyota kwenye ujumbe.';

  @override
  String get chat_message_unstarred => 'Nyota ya ujumbe imeondolewa.';

  @override
  String get chat_attachment => 'Kiambatisho';

  @override
  String get chat_you => 'Wewe';

  @override
  String get chat_other_user => 'Mtumiaji mwingine';

  @override
  String get chat_aos_user => 'Mtumiaji wa AOS';

  @override
  String get chat_sending => 'Inatuma…';

  @override
  String get chat_edited => 'Imehaririwa';

  @override
  String get chat_starred => 'Ina nyota';

  @override
  String get chat_translated => 'Imetafsiriwa';

  @override
  String get chat_failed_to_send => 'Imeshindikana kutuma';

  @override
  String get chat_read => 'Imesomwa';

  @override
  String get chat_delivered => 'Imefikishwa';

  @override
  String get chat_sent => 'Imetumwa';

  @override
  String get chat_forwarded_label => 'Imesambazwa';

  @override
  String get chat_deleted_message => 'Ujumbe huu ulifutwa';

  @override
  String get chat_translating => 'Inatafsiri…';

  @override
  String get chat_tap_to_retry => 'Gusa ujaribu tena';

  @override
  String get chat_translate_to => 'Tafsiri kwa';

  @override
  String chat_translate_to_language(Object language) {
    return 'Tafsiri kwa $language';
  }

  @override
  String get chat_voice_release_cancel => 'Achilia ili kughairi';

  @override
  String get chat_voice_recording_locked => 'Kurekodi kumefungwa';

  @override
  String get chat_voice_slide_cancel => 'Telezesha kushoto ili kughairi';

  @override
  String chat_voice_recording_status(Object duration, Object instruction) {
    return 'Inarekodi sauti $duration. $instruction';
  }

  @override
  String chat_starred_message_from(Object sender) {
    return 'Ujumbe wenye nyota kutoka kwa $sender';
  }

  @override
  String get chat_verified_sellers => 'Wauzaji Waliothibitishwa';

  @override
  String get chat_friends => 'Marafiki';

  @override
  String get chat_search_sellers_hint => 'Tafuta wauzaji…';

  @override
  String get chat_search_friends_hint => 'Tafuta marafiki…';

  @override
  String get chat_loading_sellers => 'Inapakia wauzaji';

  @override
  String get chat_loading_sellers_hint =>
      'Tafadhali subiri tunapotafuta wauzaji waliothibitishwa.';

  @override
  String get chat_could_not_load_sellers => 'Imeshindwa kupakia wauzaji';

  @override
  String get chat_no_verified_sellers => 'Hakuna wauzaji waliothibitishwa';

  @override
  String get chat_no_sellers_found => 'Hakuna wauzaji waliopatikana';

  @override
  String get chat_no_verified_sellers_hint =>
      'Wauzaji waliothibitishwa wataonekana hapa wakipatikana.';

  @override
  String get chat_no_sellers_found_hint =>
      'Jaribu jina, aina au eneo jingine la muuzaji.';

  @override
  String get chat_refresh => 'Onyesha upya';

  @override
  String get chat_loading_friends => 'Inapakia marafiki';

  @override
  String get chat_loading_friends_hint =>
      'Tafadhali subiri tunapotafuta marafiki zako.';

  @override
  String get chat_could_not_load_friends => 'Imeshindwa kupakia marafiki';

  @override
  String get chat_try_again => 'Tafadhali jaribu tena.';

  @override
  String get chat_no_friends_yet => 'Bado hakuna marafiki';

  @override
  String get chat_no_friends_found => 'Hakuna marafiki waliopatikana';

  @override
  String get chat_no_friends_yet_hint =>
      'Marafiki wataonekana hapa mtakapofuatana.';

  @override
  String get chat_no_friends_found_hint =>
      'Jaribu kutafuta kwa jina au barua pepe nyingine.';

  @override
  String get chat_online => 'Mtandaoni';

  @override
  String get chat_last_seen_recently => 'Alionekana hivi karibuni';

  @override
  String get chat_friend => 'Rafiki';

  @override
  String get chat_message_contact => 'Tuma ujumbe';

  @override
  String get chat_call_contact => 'Piga simu';

  @override
  String get chat_all_chats => 'Gumzo Zote';

  @override
  String get chat_unread => 'Hazijasomwa';

  @override
  String get chat_loading_conversations => 'Inapakia mazungumzo';

  @override
  String get chat_loading_conversations_hint =>
      'Tafadhali subiri tunapopakia gumzo zako.';

  @override
  String get chat_could_not_load_chats => 'Imeshindwa kupakia gumzo';

  @override
  String get chat_no_chats_found => 'Hakuna gumzo zilizopatikana';

  @override
  String get chat_no_chats_search_hint => 'Jaribu jina au ujumbe mwingine.';

  @override
  String get chat_no_read_chats => 'Hakuna gumzo zilizosomwa';

  @override
  String get chat_no_unread_chats => 'Hakuna gumzo ambazo hazijasomwa';

  @override
  String get chat_no_conversations_yet => 'Bado hakuna mazungumzo';

  @override
  String get chat_no_read_chats_hint => 'Gumzo ulizosoma zitaonekana hapa.';

  @override
  String get chat_no_unread_chats_hint =>
      'Gumzo ambazo hazijasomwa zitaonekana hapa ujumbe mpya ukifika.';

  @override
  String get chat_no_conversations_hint =>
      'Mazungumzo yako yataonekana hapa ukianza kuzungumza.';

  @override
  String get chat_deleted_from_list => 'Gumzo imeondolewa kwenye orodha yako.';

  @override
  String get chat_delete_chat_failed => 'Imeshindwa kufuta gumzo. Jaribu tena.';

  @override
  String get chat_typing => 'Anaandika…';

  @override
  String chat_last_seen_time(Object time) {
    return 'Alionekana $time';
  }

  @override
  String get chat_forward_to_title => 'Sambaza kwa';

  @override
  String get chat_close => 'Funga';

  @override
  String get chat_search_conversations_hint => 'Tafuta mazungumzo';

  @override
  String get chat_clear_search => 'Futa utafutaji';

  @override
  String get chat_could_not_load_conversations =>
      'Imeshindikana kupakia mazungumzo';

  @override
  String get chat_no_other_conversations => 'Hakuna mazungumzo mengine';

  @override
  String get chat_no_other_conversations_hint =>
      'Anzisha gumzo jingine kwanza, kisha unaweza kusambaza ujumbe hapa.';

  @override
  String get chat_no_conversations_found => 'Hakuna mazungumzo yaliyopatikana';

  @override
  String get chat_search_conversations_empty_hint =>
      'Jaribu kutafuta kwa jina au ujumbe mwingine.';

  @override
  String get chat_forward_to_one_chat => 'Sambaza kwa gumzo 1';

  @override
  String chat_forward_to_chats_count(Object count) {
    return 'Sambaza kwa gumzo $count';
  }

  @override
  String get chat_default_wallpaper_applied =>
      'Mandhari chaguomsingi imetumika.';

  @override
  String get chat_wallpaper_updated => 'Mandhari imesasishwa.';

  @override
  String chat_named_wallpaper_applied(Object name) {
    return 'Mandhari ya $name imetumika.';
  }

  @override
  String get chat_choose_conversation_background =>
      'Chagua mandharinyuma ya mazungumzo haya';

  @override
  String get chat_default => 'Chaguomsingi';

  @override
  String get chat_choose_from_gallery => 'Chagua kutoka kwenye ghala';

  @override
  String get chat_solid_colors => 'Rangi moja';

  @override
  String get chat_emoji_recent => 'Za hivi karibuni';

  @override
  String get chat_emoji_smileys => 'Nyuso';

  @override
  String get chat_emoji_animals => 'Wanyama';

  @override
  String get chat_emoji_food => 'Chakula';

  @override
  String get chat_emoji_flags => 'Bendera';

  @override
  String get chat_search_emoji => 'Tafuta emoji';

  @override
  String get chat_no_emoji_found => 'Hakuna emoji iliyopatikana';

  @override
  String get chat_share_contact => 'Shiriki anwani';

  @override
  String get chat_search_aos_users => 'Tafuta watumiaji wa AOS';

  @override
  String get chat_could_not_load_contacts => 'Imeshindikana kupakia anwani';

  @override
  String get chat_search_people_on_aos => 'Tafuta watu kwenye AOS';

  @override
  String get chat_search_people_hint =>
      'Andika angalau herufi 2 ili kupata anwani ya kushiriki.';

  @override
  String get chat_no_contacts_found => 'Hakuna anwani zilizopatikana';

  @override
  String get chat_no_contacts_found_hint =>
      'Jaribu jina, jina la mtumiaji au barua pepe nyingine.';

  @override
  String get chat_unmute => 'Washa sauti';

  @override
  String get chat_mute => 'Nyamazisha';

  @override
  String get chat_end_call => 'Maliza simu';

  @override
  String get chat_calling => 'Inapiga simu';

  @override
  String get chat_ringing => 'Inaita';

  @override
  String get chat_incoming_call => 'Simu inayoingia';

  @override
  String get chat_connecting => 'Inaunganisha';

  @override
  String get chat_delete_chat_title => 'Futa gumzo?';

  @override
  String chat_delete_chat_description(Object name) {
    return 'Hii itaondoa gumzo lako na $name kwenye orodha yako. Haitalifuta kwa mtumiaji mwingine.';
  }

  @override
  String get chat_this_user => 'mtumiaji huyu';

  @override
  String get chat_delete => 'Futa';

  @override
  String get chat_view_profile => 'Tazama wasifu';

  @override
  String get chat_view_contact => 'Tazama anwani';

  @override
  String get chat_cannot_open_document =>
      'Haiwezekani kufungua aina hii ya hati';

  @override
  String get chat_failed_to_start_chat =>
      'Imeshindikana kuanzisha gumzo. Jaribu tena.';

  @override
  String get chat_invalid_conversation_response =>
      'Jibu la mazungumzo si sahihi';

  @override
  String get chat_voice_hold_to_record => 'Shikilia kurekodi ujumbe wa sauti';

  @override
  String get chat_voice_release_to_finish => 'Achilia kumaliza kurekodi sauti';

  @override
  String get chat_microphone_permission_denied =>
      'Ruhusa ya maikrofoni imekataliwa.';

  @override
  String get chat_voice_record_start_failed =>
      'Imeshindikana kuanza kurekodi sauti.';

  @override
  String get chat_voice_record_finish_failed =>
      'Imeshindikana kumaliza kurekodi sauti.';

  @override
  String get chat_language_english => 'Kiingereza';

  @override
  String get chat_language_swahili => 'Kiswahili';

  @override
  String get chat_language_french => 'Kifaransa';

  @override
  String get chat_language_spanish => 'Kihispania';

  @override
  String get chat_language_german => 'Kijerumani';

  @override
  String get chat_language_portuguese => 'Kireno';

  @override
  String get chat_language_arabic => 'Kiarabu';

  @override
  String get chat_language_hausa => 'Kihausa';

  @override
  String get chat_language_yoruba => 'Kiyoruba';

  @override
  String get chat_language_igbo => 'Kiigbo';

  @override
  String get chat_language_amharic => 'Kiamhari';

  @override
  String get chat_language_somali => 'Kisomali';

  @override
  String get chat_language_kinyarwanda => 'Kinyarwanda';

  @override
  String get chat_language_luganda => 'Kiluganda';

  @override
  String get chat_language_zulu => 'Kizulu';

  @override
  String get chat_language_xhosa => 'Kixhosa';

  @override
  String get chat_wallpaper_midnight => 'Usiku wa manane';

  @override
  String get chat_wallpaper_navy => 'Bluu bahari';

  @override
  String get chat_wallpaper_forest => 'Msitu';

  @override
  String get chat_wallpaper_plum => 'Rangi ya plamu';

  @override
  String get chat_wallpaper_charcoal => 'Mkaa';

  @override
  String get chat_wallpaper_maroon => 'Maruni';

  @override
  String get chat_wallpaper_teal => 'Kijani-bahari';

  @override
  String get chat_wallpaper_coffee => 'Kahawa';
}
