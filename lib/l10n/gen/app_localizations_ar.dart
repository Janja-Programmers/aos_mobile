// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get onboarding_language_title => 'اختر لغتك';

  @override
  String get onboarding_language_subtitle =>
      'سيظهر التطبيق باللغة التي اخترتها';

  @override
  String get onboarding_language_placeholder => 'اختر لغتك';

  @override
  String get onboarding_language_picker => 'اختر اللغة';

  @override
  String get onboarding_use_current_location => 'استخدم الموقع الحالي';

  @override
  String get onboarding_use_country_currency => 'استخدم عملة البلد';

  @override
  String get onboarding_loading_title => 'جارٍ تحميل الخيارات';

  @override
  String get onboarding_loading_message =>
      'نحمّل خيارات الإعداد. يمكنك إعادة المحاولة أو التخطي الآن.';

  @override
  String get onboarding_offline_title => 'لا يوجد اتصال بالإنترنت';

  @override
  String get onboarding_offline_message =>
      'تعذر تحميل هذه الخيارات. أعد المحاولة عند الاتصال، أو تخطَّ الآن دون حفظ قيم مصطنعة.';

  @override
  String get common_try_again => 'حاول مرة أخرى';

  @override
  String get common_no_languages => 'لا توجد لغات متاحة';

  @override
  String get common_no_countries => 'لا توجد بلدان متاحة';

  @override
  String get common_search => 'بحث';

  @override
  String get common_no_results => 'لا توجد خيارات مطابقة';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_discard_changes_title => 'تجاهل التغييرات؟';

  @override
  String get common_discard_changes_message =>
      'لديك تغييرات غير محفوظة. هل تريد تجاهلها؟';

  @override
  String get common_keep_editing => 'متابعة التعديل';

  @override
  String get common_discard => 'تجاهل';

  @override
  String get common_selection_required => 'اختر خيارًا صالحًا للمتابعة.';

  @override
  String get onboarding_currency_title => 'اختر عملتك';

  @override
  String get onboarding_currency_subtitle =>
      'سيتم عرض الأسعار بالعملة التي اخترتها';

  @override
  String get onboarding_currency_placeholder => 'اختر عملتك';

  @override
  String get onboarding_currency_picker => 'اختر العملة';

  @override
  String get onboarding_country_title => 'حدد بلدك';

  @override
  String get onboarding_country_subtitle =>
      'سنُظهر لك المنتجات والبائعين القريبين منك';

  @override
  String get onboarding_country_placeholder => 'اختر بلدك';

  @override
  String get onboarding_country_picker => 'اختر الدولة';

  @override
  String get common_continue => 'متابعة';

  @override
  String get common_skip_for_now => 'تخطي الآن';

  @override
  String get common_get_started => 'ابدأ';

  @override
  String get common_no_currencies => 'لا توجد عملات متاحة';

  @override
  String get auth_register_title => 'إنشاء حساب';

  @override
  String get auth_register_subtitle => 'أدخل بياناتك لإنشاء حسابك';

  @override
  String get auth_full_name => 'الاسم الكامل';

  @override
  String get auth_email_address => 'البريد الإلكتروني';

  @override
  String get auth_password => 'كلمة المرور';

  @override
  String get auth_confirm_password => 'تأكيد كلمة المرور';

  @override
  String get auth_accept_terms_error =>
      'يرجى قبول الشروط والأحكام وسياسة الخصوصية';

  @override
  String get auth_terms_and_conditions => 'الشروط والأحكام';

  @override
  String get auth_privacy_policy => 'سياسة الخصوصية';

  @override
  String get auth_agree_prefix => 'أوافق على ';

  @override
  String get auth_and => ' و ';

  @override
  String get auth_register_button => 'تسجيل';

  @override
  String auth_unexpected_error(Object error) {
    return 'خطأ غير متوقع: $error';
  }

  @override
  String get auth_already_have_account => 'هل لديك حساب بالفعل؟ ';

  @override
  String get auth_login => 'تسجيل الدخول';

  @override
  String get auth_login_title => 'مرحباً بعودتك';

  @override
  String get auth_login_subtitle => 'سجل الدخول إلى حسابك';

  @override
  String get auth_remember_me => 'تذكرني';

  @override
  String get auth_forgot_password => 'هل نسيت كلمة المرور؟';

  @override
  String get auth_login_button => 'تسجيل الدخول';

  @override
  String get auth_no_account => 'ليس لديك حساب؟';

  @override
  String get auth_register => 'إنشاء حساب';

  @override
  String get auth_continue_google => 'المتابعة باستخدام Google';

  @override
  String get auth_or => 'أو';

  @override
  String get auth_send_otp => 'إرسال رمز التحقق';

  @override
  String get auth_mail_reset_password =>
      'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور';

  @override
  String get auth_password_updated_title => 'تم تحديث كلمة المرور\nبنجاح';

  @override
  String get auth_password_updated_message => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get auth_password_updated_button => 'المتابعة إلى تسجيل الدخول';

  @override
  String get auth_email_verification_title => 'تأكيد البريد الإلكتروني';

  @override
  String get auth_enter_verification_code => 'أدخل رمز التحقق';

  @override
  String get auth_verification_code_sent_to => 'لقد أرسلنا رمز التحقق إلى';

  @override
  String get auth_email_verified_title =>
      'تم التحقق من البريد الإلكتروني\nبنجاح';

  @override
  String get auth_email_verified_message =>
      'تم التحقق من بريدك الإلكتروني بنجاح';

  @override
  String get auth_email_verified_button => 'المتابعة إلى تسجيل الدخول';

  @override
  String get auth_digit_code => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get auth_resend_code => 'لم تستلم الرمز؟ ';

  @override
  String get auth_resend => 'إعادة الإرسال';

  @override
  String get auth_resend_in => 'إعادة الإرسال خلال ';

  @override
  String get nav_home => 'الرئيسية';

  @override
  String get nav_categories => 'الفئات';

  @override
  String get nav_selling => 'بيع';

  @override
  String get nav_contact => 'اتصل بنا';

  @override
  String get nav_account => 'الحساب';

  @override
  String get common_see_all => 'عرض الكل';

  @override
  String get home_flash_sales => 'عروض AOS السريعة';

  @override
  String get home_services_near_you => 'خدمات قريبة منك';

  @override
  String get home_new_products => 'منتجات جديدة في AOS';

  @override
  String get home_electronic_deals => 'عروض الإلكترونيات AOS';

  @override
  String get home_deals => 'عروض AOS';

  @override
  String get home_furniture => 'أثاث';

  @override
  String get home_electronics => 'إلكترونيات';

  @override
  String get home_fashion => 'موضة';

  @override
  String get home_babies_kids => 'الأطفال والرضع';

  @override
  String get home_beauty => 'جمال';

  @override
  String get home_photography_tips => 'نصائح التصوير';

  @override
  String get home_boost_marketing_reach => 'عزز وصولك التسويقي';

  @override
  String get home_ranking_tips => 'جرب أفضل نصائح الترتيب';

  @override
  String get home_learn => 'تعلم';

  @override
  String get home_top_deals => 'أفضل العروض';

  @override
  String get home_best_prices => 'أفضل الأسعار';

  @override
  String get home_shop_now => 'تسوق الآن';

  @override
  String get home_you_might_be_looking_for => 'قد تكون تبحث عن';

  @override
  String get ads_no_more_ads => 'لا توجد إعلانات أخرى';

  @override
  String get location_all_locations => 'كل المواقع';

  @override
  String get search_placeholder => 'ابحث هنا...';

  @override
  String get search_button => 'بحث';

  @override
  String get ads_my_listings => 'إعلاناتي';

  @override
  String get ads_no_listings_yet => 'لا توجد إعلانات بعد';

  @override
  String get ads_no_listings_message => 'لم تقم بنشر أي إعلان بعد';

  @override
  String get ads_start_selling_message => 'ابدأ البيع بإنشاء إعلانك الأول';

  @override
  String get ads_post_first_ad => 'أنشئ إعلانك الأول';

  @override
  String get ads_learn_sell_faster => 'تعلم كيف تبيع بشكل أسرع';

  @override
  String get ads_create_ad => 'إنشاء إعلان';

  @override
  String get ads_update_ad => 'تحديث الإعلان';

  @override
  String get account_title => 'الحساب';

  @override
  String get account_get_verified => 'توثيق الحساب';

  @override
  String get account_boost_trust => 'عزز الثقة والمصداقية';

  @override
  String get account_settings => 'إعدادات الحساب';

  @override
  String get account_passwords_security => 'كلمات المرور والأمان';

  @override
  String get account_notifications_preferences => 'تفضيلات التطبيق';

  @override
  String get account_guest_title => 'مرحبًا بك في AOS';

  @override
  String get account_guest_description =>
      'قم بتسجيل الدخول للوصول إلى حسابك وإدارة الإعلانات والمزيد';

  @override
  String get app_preferences => 'تفضيلات التطبيق';

  @override
  String get settings_dark_mode => 'الوضع الداكن';

  @override
  String get common_other => 'أخرى';

  @override
  String get common_discover_more => 'اكتشف المزيد';

  @override
  String get settings_privacy_policy => 'سياسة الخصوصية';

  @override
  String get settings_preferences => 'التفضيلات';

  @override
  String get settings_manage_app => 'إدارة كيفية عمل التطبيق لك';

  @override
  String get settings_language => 'اللغة';

  @override
  String get settings_language_description =>
      'يتحكم في كيفية ظهور النص في التطبيق.';

  @override
  String get settings_country => 'الدولة';

  @override
  String get settings_country_description =>
      'يحدد الإعلانات القريبة وأين تظهر إعلاناتك.';

  @override
  String get settings_currency => 'العملة';

  @override
  String get settings_currency_description =>
      'يستخدم لعرض الأسعار عند تصفح ونشر الإعلانات.';

  @override
  String get settings_terms_conditions => 'الشروط والأحكام';

  @override
  String get onboarding_preference_error =>
      'تعذر حفظ تفضيلك. يُرجى المحاولة مرة أخرى.';

  @override
  String get session_restore_offline_title => 'أنت غير متصل بالإنترنت';

  @override
  String get session_restore_offline_message =>
      'تعذر على AOS التحقق من جلستك الحالية. اتصل بالإنترنت ثم حاول مرة أخرى. لم يتم حذف جلستك المحفوظة.';

  @override
  String get session_restore_unavailable_title => 'تعذر استعادة جلستك';

  @override
  String get session_restore_unavailable_message =>
      'يتعذر على AOS التحقق من جلستك الحالية الآن. حاول مرة أخرى. لم يتم حذف جلستك المحفوظة.';

  @override
  String get privacy_cover_accessibility_label => 'يحمي AOS معلومات حسابك.';

  @override
  String get appLockScreenAccessibilityLabel => 'تطبيق AOS مقفل';

  @override
  String get appLockTitle => 'فتح AOS';

  @override
  String get appLockPrompt => 'أدخل قفل التطبيق للمتابعة.';

  @override
  String get appLockUnlock => 'فتح';

  @override
  String get appLockAuthenticating => 'جارٍ التحقق…';

  @override
  String get appLockLogout => 'تسجيل الخروج';

  @override
  String get appLockForgottenCredentialHelp =>
      'أعد تعيين القفل لتسجيل الخروج وحذف بيانات القفل المحلية المنسية.';

  @override
  String get appLockUnlockReason => 'تحقق لفتح AOS.';

  @override
  String get appLockEnableReason => 'تحقق لتفعيل قفل التطبيق البيومتري.';

  @override
  String get appLockDisableReason => 'تحقق لتعطيل قفل التطبيق.';

  @override
  String get appLockCancelled => 'تم إلغاء التحقق. ما زالت جلستك مسجلة الدخول.';

  @override
  String get appLockTemporaryLockout =>
      'محاولات كثيرة جدًا. حاول لاحقًا أو أعد تعيين قفل التطبيق.';

  @override
  String get appLockPermanentLockout =>
      'القياسات الحيوية مقفلة. استخدم استرداد الجهاز أو أعد تعيين قفل التطبيق.';

  @override
  String get appLockNoDeviceCredential =>
      'قم أولًا بإعداد بصمة أو Face ID أو قياسات حيوية مدعومة في إعدادات الجهاز.';

  @override
  String get appLockUnsupported => 'مصادقة الجهاز غير متاحة على هذا الجهاز.';

  @override
  String get appLockTryAgain => 'حاول مرة أخرى';

  @override
  String get appLockFailed => 'فشلت المصادقة. حاول مرة أخرى.';

  @override
  String get appLockSettingTitle => 'قفل التطبيق';

  @override
  String get appLockSettingDescription =>
      'احمِ الأقسام الخاصة برمز من 4 أرقام أو نمط أو قياسات حيوية.';

  @override
  String get appLockTimingTitle => 'توقيت القفل';

  @override
  String get appLockTimingImmediately => 'فورًا';

  @override
  String get appLockTimingThirtySeconds => 'بعد 30 ثانية';

  @override
  String get appLockTimingOneMinute => 'بعد دقيقة واحدة';

  @override
  String get appLockTimingFiveMinutes => 'بعد 5 دقائق';

  @override
  String get wishlist_add => 'إضافة إلى قائمة الرغبات';

  @override
  String get wishlist_remove => 'إزالة من قائمة الرغبات';

  @override
  String get wishlist_update_error => 'تعذر تحديث قائمة رغباتك. حاول مرة أخرى.';

  @override
  String get appLockBiometricPrompt =>
      'استخدم بصمة الإصبع أو الوجه أو وسيلة بيومترية مسجلة للمتابعة.';

  @override
  String get appLockUseBiometrics => 'استخدام القياسات الحيوية';

  @override
  String get appLockReset => 'إعادة تعيين قفل التطبيق';

  @override
  String get appLockResetHelp =>
      'هل نسيت الرمز أو النمط؟ ستؤدي إعادة التعيين إلى تسجيل خروجك وحذف القفل المحلي.';

  @override
  String get appLockResetTitle => 'إعادة تعيين قفل التطبيق؟';

  @override
  String get appLockResetMessage =>
      'سيتم تسجيل خروجك وحذف قفل التطبيق المحفوظ والعودة إلى الجزء العام. سجّل الدخول مجددًا لإعداد قفل جديد.';

  @override
  String get appLockResetConfirm => 'إعادة التعيين وتسجيل الخروج';

  @override
  String get appLockCancel => 'إلغاء';

  @override
  String get appLockClear => 'مسح';

  @override
  String get appLockEnterPin => 'أدخل رمز PIN المكوّن من 4 أرقام';

  @override
  String get appLockEnterPattern => 'ارسم النمط';

  @override
  String get appLockInvalidCredential =>
      'بيانات قفل التطبيق غير صحيحة. حاول مرة أخرى.';

  @override
  String get appLockPinHelp => 'استخدم 4 أرقام بالضبط.';

  @override
  String get appLockPatternHelp => 'صِل 4 نقاط على الأقل.';

  @override
  String get appLockConfirmPin => 'أكد رمز PIN';

  @override
  String get appLockConfirmPattern => 'أكد النمط';

  @override
  String get appLockConfirmationMismatch => 'التأكيد غير مطابق. حاول مرة أخرى.';

  @override
  String get appLockContinue => 'متابعة';

  @override
  String get appLockConfirm => 'تأكيد';

  @override
  String get appLockStorageFailure =>
      'تعذر حفظ إعدادات القفل بأمان. حاول مرة أخرى.';

  @override
  String get appLockConfigured => 'قفل التطبيق مفعّل';

  @override
  String get appLockProcessRestartNote =>
      'يُقفل AOS دائمًا بعد إنهاء التطبيق أو إعادة تشغيله.';

  @override
  String get appLockChangeMethod => 'تغيير طريقة القفل';

  @override
  String get appLockDisable => 'تعطيل قفل التطبيق';

  @override
  String get appLockChooseMethod => 'اختر طريقة القفل';

  @override
  String get appLockMethodHelp =>
      'يُحفظ الرمز والنمط فقط كقيم تجزئة آمنة ومملحة. تبقى البيانات البيومترية تحت إدارة الجهاز.';

  @override
  String get appLockMethodPin => 'رمز PIN من 4 أرقام';

  @override
  String get appLockMethodPattern => 'نمط';

  @override
  String get appLockMethodBiometric => 'بصمة أو قياسات حيوية';

  @override
  String get appLockChangeReason => 'تحقق لتغيير قفل التطبيق.';

  @override
  String get appLockTimingFiveSeconds => 'بعد 5 ثوانٍ';

  @override
  String get appLockTimingTenSeconds => 'بعد 10 ثوانٍ';

  @override
  String get appLockTimingFifteenSeconds => 'بعد 15 ثانية';

  @override
  String get appLockPinInputAccessibility => 'إدخال رمز PIN';

  @override
  String get appLockPatternInputAccessibility => 'إدخال النمط';

  @override
  String get appLockPatternPointAccessibility => 'نقطة النمط';

  @override
  String get ads_location_select_title => 'اختر الموقع';

  @override
  String ads_location_results_more(Object count) {
    return 'تم العثور على أكثر من $count موقعًا';
  }

  @override
  String ads_location_results_exact(Object count) {
    return 'تم العثور على $count موقعًا';
  }

  @override
  String get ad_media_download_image => 'تنزيل الصورة';

  @override
  String get ad_media_saved_to_gallery => 'تم حفظ الصورة في المعرض.';
}
