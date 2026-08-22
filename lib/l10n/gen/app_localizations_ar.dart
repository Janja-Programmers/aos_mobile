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
  String get settings_seller_country_locked_description =>
      'يتم قفل البلد لحسابات البائعين لحماية بيانات السوق.';

  @override
  String get settings_seller_country_locked =>
      'لا يمكن تغيير البلد لحساب بائع.';

  @override
  String get common_locked => 'مقفل';

  @override
  String get settings_preference_updated => 'تم تحديث التفضيل.';

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

  @override
  String get liveLikeAction => 'الإعجاب بالبث المباشر';

  @override
  String get liveShareAction => 'مشاركة البث المباشر';

  @override
  String get liveMuteAction => 'كتم الميكروفون';

  @override
  String get liveUnmuteAction => 'إلغاء كتم الميكروفون';

  @override
  String get liveFlipCameraAction => 'تبديل الكاميرا';

  @override
  String get liveGoLiveAction => 'بدء البث المباشر';

  @override
  String get liveStartingAction => 'جارٍ البدء...';

  @override
  String get liveDetailsTitle => 'تفاصيل البث المباشر';

  @override
  String get liveEditDetailsAction => 'تعديل تفاصيل البث المباشر';

  @override
  String get liveEditDetailsHint => 'اضغط لتعديل العنوان أو الغلاف';

  @override
  String get liveCoverLabel => 'صورة الغلاف';

  @override
  String get liveChangeCoverAction => 'تغيير الغلاف';

  @override
  String get liveChooseCoverFromGallery => 'الاختيار من المعرض';

  @override
  String get liveTakeCoverPhoto => 'التقاط صورة';

  @override
  String get liveTitleLabel => 'عنوان البث المباشر';

  @override
  String get liveTitleHint => 'أضف عنوانًا للبث المباشر';

  @override
  String get liveTitleRequired => 'أضف عنوانًا للبث المباشر للمتابعة.';

  @override
  String get liveCoverRequired => 'أضف صورة غلاف للمتابعة.';

  @override
  String get liveUploadingCover => 'جارٍ رفع الغلاف...';

  @override
  String get liveCameraStarting => 'جارٍ تشغيل الكاميرا...';

  @override
  String get liveCameraUnavailable => 'معاينة الكاميرا غير متاحة';

  @override
  String get liveCameraStartError => 'تعذر تشغيل معاينة الكاميرا.';

  @override
  String get liveNoAlternateCameraError => 'لا تتوفر كاميرا بديلة.';

  @override
  String get liveCameraFlipError => 'تعذر تبديل الكاميرا.';

  @override
  String get liveCoverUploadError => 'تعذر رفع غلاف البث المباشر.';

  @override
  String get liveCoverSelectionError => 'تعذر اختيار غلاف للبث المباشر.';

  @override
  String get watchThisLiveOnAos => 'شاهد هذا البث المباشر على AOS';

  @override
  String get unableToOpenShareOptions => 'تعذر فتح خيارات المشاركة.';

  @override
  String get chat_connect_title => 'AOS Connect';

  @override
  String get chat_close_connect => 'إغلاق Connect';

  @override
  String get chat_close_search => 'إغلاق البحث';

  @override
  String get chat_search => 'بحث';

  @override
  String get chat_more_options => 'خيارات إضافية';

  @override
  String get chat_search_chats_hint => 'البحث في الدردشات…';

  @override
  String get chat_search_calls_hint => 'البحث في المكالمات…';

  @override
  String get chat_all_marked_read => 'تم تعليم جميع الدردشات كمقروءة.';

  @override
  String get chat_some_mark_read_failed => 'تعذر تعليم بعض الدردشات كمقروءة.';

  @override
  String get chat_clear_call_log_title => 'مسح سجل المكالمات؟';

  @override
  String get chat_clear_call_log_body =>
      'سيؤدي ذلك إلى إزالة سجل المكالمات الظاهر لديك، ولن يحذف سجلات المستخدمين الآخرين.';

  @override
  String get chat_cancel => 'إلغاء';

  @override
  String get chat_clear => 'مسح';

  @override
  String get chat_call_log_cleared => 'تم مسح سجل المكالمات.';

  @override
  String get chat_call_log_clear_failed => 'تعذر مسح سجل المكالمات.';

  @override
  String get chat_clear_call_log => 'مسح سجل المكالمات';

  @override
  String get chat_settings => 'الإعدادات';

  @override
  String get chat_mark_all_read => 'تعليم الكل كمقروء';

  @override
  String get chat_starred_messages => 'الرسائل المميزة بنجمة';

  @override
  String get chat_chats => 'الدردشات';

  @override
  String get chat_new_conversation => 'محادثة جديدة';

  @override
  String get chat_new => 'جديد';

  @override
  String get chat_calls => 'المكالمات';

  @override
  String get chat_back => 'رجوع';

  @override
  String get chat_call => 'اتصال';

  @override
  String get chat_video_call => 'مكالمة فيديو';

  @override
  String get chat_change_wallpaper => 'تغيير الخلفية';

  @override
  String get chat_user_might_be_offline => 'قد يكون المستخدم غير متصل';

  @override
  String get chat_failed_to_start_call => 'تعذر بدء المكالمة';

  @override
  String get chat_gallery => 'المعرض';

  @override
  String get chat_camera => 'الكاميرا';

  @override
  String get chat_voice_call => 'مكالمة صوتية';

  @override
  String get chat_location => 'الموقع';

  @override
  String get chat_document => 'مستند';

  @override
  String get chat_contact => 'جهة اتصال';

  @override
  String get chat_attachment_upload_failed => 'فشل رفع المرفق. حاول مرة أخرى.';

  @override
  String get chat_message_hint => 'رسالة';

  @override
  String get chat_share_location_title => 'مشاركة الموقع';

  @override
  String get chat_retry => 'إعادة المحاولة';

  @override
  String get chat_could_not_load_messages => 'تعذر تحميل الرسائل';

  @override
  String get chat_check_connection_try_again =>
      'تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get chat_no_messages_yet => 'لا توجد رسائل بعد';

  @override
  String get chat_no_messages_hint => 'أرسل رسالة لبدء هذه المحادثة.';

  @override
  String get chat_older_messages_load_failed => 'تعذر تحميل الرسائل الأقدم.';

  @override
  String get chat_reply => 'رد';

  @override
  String get chat_edit => 'تعديل';

  @override
  String get chat_copy => 'نسخ';

  @override
  String get chat_forward => 'إعادة توجيه';

  @override
  String get chat_translate_again => 'ترجمة مرة أخرى';

  @override
  String get chat_translate => 'ترجمة';

  @override
  String get chat_unstar => 'إزالة النجمة';

  @override
  String get chat_star => 'تمييز بنجمة';

  @override
  String get chat_delete_for_me => 'حذف لدي';

  @override
  String get chat_delete_for_everyone => 'حذف لدى الجميع';

  @override
  String get chat_message_reactions => 'تفاعلات الرسالة';

  @override
  String get chat_choose_another_reaction => 'اختيار تفاعل آخر';

  @override
  String chat_react_with(Object emoji) {
    return 'تفاعل باستخدام $emoji';
  }

  @override
  String chat_remove_reaction(Object emoji) {
    return 'إزالة تفاعل $emoji';
  }

  @override
  String get chat_editing_message => 'تعديل الرسالة';

  @override
  String get chat_cancel_editing => 'إلغاء التعديل';

  @override
  String get chat_copied_to_clipboard => 'تم النسخ إلى الحافظة';

  @override
  String get chat_message_still_failed =>
      'ما زال إرسال الرسالة متعذرًا. حاول مرة أخرى.';

  @override
  String get chat_send_ad_failed => 'تعذر إرسال رسالة الإعلان. حاول مرة أخرى.';

  @override
  String get chat_send_failed => 'تعذر إرسال الرسالة. حاول مرة أخرى.';

  @override
  String get chat_star_update_failed => 'تعذر تحديث النجمة.';

  @override
  String get chat_reaction_update_failed => 'تعذر تحديث التفاعل.';

  @override
  String get chat_forward_failed => 'تعذر إعادة توجيه الرسالة.';

  @override
  String get chat_forwarded => 'تمت إعادة توجيه الرسالة.';

  @override
  String chat_forwarded_to_chats(Object count) {
    return 'تمت إعادة توجيه الرسالة إلى $count دردشات.';
  }

  @override
  String get chat_translate_failed => 'تعذرت ترجمة الرسالة.';

  @override
  String get chat_delete_failed => 'تعذر حذف الرسالة.';

  @override
  String get chat_deleted_for_everyone => 'تم حذف الرسالة لدى الجميع.';

  @override
  String get chat_deleted_for_you => 'تم حذف الرسالة لديك.';

  @override
  String get chat_edit_failed => 'تعذر تعديل الرسالة.';

  @override
  String get chat_settings_title => 'إعدادات الدردشة';

  @override
  String get chat_privacy => 'الخصوصية';

  @override
  String get chat_read_receipts => 'إيصالات القراءة';

  @override
  String get chat_read_receipts_managed => 'تديرها AOS لتسليم الرسائل';

  @override
  String get chat_last_seen_online => 'آخر ظهور وحالة الاتصال';

  @override
  String get chat_no_backend_preference =>
      'لا يوفر الخادم إعدادًا لهذا التفضيل';

  @override
  String get chat_blocked_contacts => 'جهات الاتصال المحظورة';

  @override
  String get chat_chats_section => 'الدردشات';

  @override
  String get chat_wallpaper => 'خلفية الدردشة';

  @override
  String get chat_wallpaper_description => 'تعيين خلفية افتراضية للدردشات';

  @override
  String get chat_enter_is_send => 'Enter للإرسال';

  @override
  String get chat_enter_is_send_description => 'يرسل مفتاح Enter رسالتك';

  @override
  String get chat_media_auto_download => 'التنزيل التلقائي للوسائط';

  @override
  String get chat_unavailable_backend => 'غير متاح في عقد الخادم الحالي';

  @override
  String get chat_notifications => 'الإشعارات';

  @override
  String get chat_message_notifications => 'إشعارات الرسائل';

  @override
  String get chat_call_notifications => 'إشعارات المكالمات';

  @override
  String get chat_system_notification_settings =>
      'تتحكم بها إعدادات إشعارات النظام';

  @override
  String get chat_on => 'مفعّل';

  @override
  String get chat_off => 'متوقف';

  @override
  String get chat_starred_load_failed => 'تعذر تحميل الرسائل المميزة بنجمة';

  @override
  String get chat_no_starred_messages => 'لا توجد رسائل مميزة بنجمة';

  @override
  String get chat_no_starred_messages_hint =>
      'ستظهر هنا الرسائل التي تميزها بنجمة.';

  @override
  String get chat_unstar_message => 'إزالة النجمة من الرسالة';

  @override
  String get chat_unstar_failed => 'تعذر إزالة النجمة من الرسالة.';

  @override
  String get chat_message_unstarred => 'تمت إزالة النجمة من الرسالة.';

  @override
  String get chat_attachment => 'مرفق';

  @override
  String get chat_you => 'أنت';

  @override
  String get chat_other_user => 'مستخدم آخر';

  @override
  String get chat_aos_user => 'مستخدم AOS';

  @override
  String get chat_sending => 'جارٍ الإرسال…';

  @override
  String get chat_edited => 'معدلة';

  @override
  String get chat_starred => 'مميزة بنجمة';

  @override
  String get chat_translated => 'مترجمة';

  @override
  String get chat_failed_to_send => 'فشل الإرسال';

  @override
  String get chat_read => 'مقروءة';

  @override
  String get chat_delivered => 'تم التسليم';

  @override
  String get chat_sent => 'تم الإرسال';

  @override
  String get chat_forwarded_label => 'معاد توجيهها';

  @override
  String get chat_deleted_message => 'تم حذف هذه الرسالة';

  @override
  String get chat_translating => 'جارٍ الترجمة…';

  @override
  String get chat_tap_to_retry => 'اضغط لإعادة المحاولة';

  @override
  String get chat_translate_to => 'الترجمة إلى';

  @override
  String chat_translate_to_language(Object language) {
    return 'الترجمة إلى $language';
  }

  @override
  String get chat_voice_release_cancel => 'حرر للإلغاء';

  @override
  String get chat_voice_recording_locked => 'تم تثبيت التسجيل';

  @override
  String get chat_voice_slide_cancel => 'اسحب لليسار للإلغاء';

  @override
  String chat_voice_recording_status(Object duration, Object instruction) {
    return 'تسجيل صوتي $duration. $instruction';
  }

  @override
  String chat_starred_message_from(Object sender) {
    return 'رسالة مميزة بنجمة من $sender';
  }

  @override
  String get chat_verified_sellers => 'البائعون الموثقون';

  @override
  String get chat_friends => 'الأصدقاء';

  @override
  String get chat_search_sellers_hint => 'البحث عن بائعين…';

  @override
  String get chat_search_friends_hint => 'البحث عن أصدقاء…';

  @override
  String get chat_loading_sellers => 'جارٍ تحميل البائعين';

  @override
  String get chat_loading_sellers_hint =>
      'يرجى الانتظار بينما نعثر على البائعين الموثقين.';

  @override
  String get chat_could_not_load_sellers => 'تعذر تحميل البائعين';

  @override
  String get chat_no_verified_sellers => 'لا يوجد بائعون موثقون';

  @override
  String get chat_no_sellers_found => 'لم يتم العثور على بائعين';

  @override
  String get chat_no_verified_sellers_hint =>
      'سيظهر البائعون الموثقون هنا عند توفرهم.';

  @override
  String get chat_no_sellers_found_hint =>
      'جرّب اسم بائع أو فئة أو موقعًا آخر.';

  @override
  String get chat_refresh => 'تحديث';

  @override
  String get chat_loading_friends => 'جارٍ تحميل الأصدقاء';

  @override
  String get chat_loading_friends_hint =>
      'يرجى الانتظار بينما نعثر على أصدقائك.';

  @override
  String get chat_could_not_load_friends => 'تعذر تحميل الأصدقاء';

  @override
  String get chat_try_again => 'يرجى المحاولة مرة أخرى.';

  @override
  String get chat_no_friends_yet => 'لا يوجد أصدقاء بعد';

  @override
  String get chat_no_friends_found => 'لم يتم العثور على أصدقاء';

  @override
  String get chat_no_friends_yet_hint =>
      'سيظهر الأصدقاء هنا عندما يتابع كل منكما الآخر.';

  @override
  String get chat_no_friends_found_hint =>
      'جرّب البحث باسم أو بريد إلكتروني آخر.';

  @override
  String get chat_online => 'متصل';

  @override
  String get chat_last_seen_recently => 'ظهر مؤخرًا';

  @override
  String get chat_friend => 'صديق';

  @override
  String get chat_message_contact => 'مراسلة';

  @override
  String get chat_call_contact => 'اتصال';

  @override
  String get chat_all_chats => 'كل الدردشات';

  @override
  String get chat_unread => 'غير مقروءة';

  @override
  String get chat_loading_conversations => 'جارٍ تحميل المحادثات';

  @override
  String get chat_loading_conversations_hint =>
      'يرجى الانتظار أثناء تحميل دردشاتك.';

  @override
  String get chat_could_not_load_chats => 'تعذر تحميل الدردشات';

  @override
  String get chat_no_chats_found => 'لم يتم العثور على دردشات';

  @override
  String get chat_no_chats_search_hint => 'جرّب اسمًا أو رسالة أخرى.';

  @override
  String get chat_no_read_chats => 'لا توجد دردشات مقروءة';

  @override
  String get chat_no_unread_chats => 'لا توجد دردشات غير مقروءة';

  @override
  String get chat_no_conversations_yet => 'لا توجد محادثات بعد';

  @override
  String get chat_no_read_chats_hint => 'ستظهر هنا الدردشات التي قرأتها.';

  @override
  String get chat_no_unread_chats_hint =>
      'ستظهر الدردشات غير المقروءة هنا عند وصول رسائل جديدة.';

  @override
  String get chat_no_conversations_hint =>
      'ستظهر محادثاتك هنا بعد بدء الدردشة.';

  @override
  String get chat_deleted_from_list => 'تم حذف الدردشة من قائمتك.';

  @override
  String get chat_delete_chat_failed => 'تعذر حذف الدردشة. حاول مرة أخرى.';

  @override
  String get chat_typing => 'يكتب…';

  @override
  String chat_last_seen_time(Object time) {
    return 'آخر ظهور $time';
  }

  @override
  String get chat_forward_to_title => 'إعادة توجيه إلى';

  @override
  String get chat_close => 'إغلاق';

  @override
  String get chat_search_conversations_hint => 'البحث في المحادثات';

  @override
  String get chat_clear_search => 'مسح البحث';

  @override
  String get chat_could_not_load_conversations => 'تعذر تحميل المحادثات';

  @override
  String get chat_no_other_conversations => 'لا توجد محادثات أخرى';

  @override
  String get chat_no_other_conversations_hint =>
      'ابدأ محادثة أخرى أولاً، ثم يمكنك إعادة توجيه الرسائل إليها.';

  @override
  String get chat_no_conversations_found => 'لم يتم العثور على محادثات';

  @override
  String get chat_search_conversations_empty_hint =>
      'جرّب البحث باسم أو رسالة أخرى.';

  @override
  String get chat_forward_to_one_chat => 'إعادة التوجيه إلى محادثة واحدة';

  @override
  String chat_forward_to_chats_count(Object count) {
    return 'إعادة التوجيه إلى $count محادثات';
  }

  @override
  String get chat_default_wallpaper_applied => 'تم تطبيق الخلفية الافتراضية.';

  @override
  String get chat_wallpaper_updated => 'تم تحديث الخلفية.';

  @override
  String chat_named_wallpaper_applied(Object name) {
    return 'تم تطبيق خلفية $name.';
  }

  @override
  String get chat_choose_conversation_background => 'اختر خلفية لهذه المحادثة';

  @override
  String get chat_default => 'افتراضي';

  @override
  String get chat_choose_from_gallery => 'اختيار من المعرض';

  @override
  String get chat_solid_colors => 'ألوان موحدة';

  @override
  String get chat_emoji_recent => 'الأخيرة';

  @override
  String get chat_emoji_smileys => 'وجوه';

  @override
  String get chat_emoji_animals => 'حيوانات';

  @override
  String get chat_emoji_food => 'طعام';

  @override
  String get chat_emoji_flags => 'أعلام';

  @override
  String get chat_search_emoji => 'البحث عن رمز تعبيري';

  @override
  String get chat_no_emoji_found => 'لم يتم العثور على رموز تعبيرية';

  @override
  String get chat_share_contact => 'مشاركة جهة اتصال';

  @override
  String get chat_search_aos_users => 'البحث عن مستخدمي AOS';

  @override
  String get chat_could_not_load_contacts => 'تعذر تحميل جهات الاتصال';

  @override
  String get chat_search_people_on_aos => 'البحث عن أشخاص على AOS';

  @override
  String get chat_search_people_hint =>
      'اكتب حرفين على الأقل للعثور على جهة اتصال لمشاركتها.';

  @override
  String get chat_no_contacts_found => 'لم يتم العثور على جهات اتصال';

  @override
  String get chat_no_contacts_found_hint =>
      'جرّب اسماً أو اسم مستخدم أو بريداً إلكترونياً آخر.';

  @override
  String get chat_unmute => 'إلغاء الكتم';

  @override
  String get chat_mute => 'كتم';

  @override
  String get chat_end_call => 'إنهاء المكالمة';

  @override
  String get chat_calling => 'جارٍ الاتصال';

  @override
  String get chat_ringing => 'يرن';

  @override
  String get chat_incoming_call => 'مكالمة واردة';

  @override
  String get chat_connecting => 'جارٍ الاتصال';

  @override
  String get chat_delete_chat_title => 'حذف المحادثة؟';

  @override
  String chat_delete_chat_description(Object name) {
    return 'سيؤدي هذا إلى إزالة محادثتك مع $name من قائمتك، ولن تُحذف لدى المستخدم الآخر.';
  }

  @override
  String get chat_this_user => 'هذا المستخدم';

  @override
  String get chat_delete => 'حذف';

  @override
  String get chat_view_profile => 'عرض الملف الشخصي';

  @override
  String get chat_view_contact => 'عرض جهة الاتصال';

  @override
  String get chat_cannot_open_document => 'لا يمكن فتح هذا النوع من المستندات';

  @override
  String get chat_failed_to_start_chat => 'تعذر بدء المحادثة. حاول مرة أخرى.';

  @override
  String get chat_invalid_conversation_response => 'استجابة محادثة غير صالحة';

  @override
  String get chat_voice_hold_to_record => 'اضغط مطولاً لتسجيل رسالة صوتية';

  @override
  String get chat_voice_tap_to_record => 'اضغط لتسجيل رسالة صوتية';

  @override
  String get chat_voice_pause => 'إيقاف التسجيل مؤقتًا';

  @override
  String get chat_voice_resume => 'استئناف التسجيل';

  @override
  String get chat_voice_delete_recording => 'حذف التسجيل';

  @override
  String get chat_voice_send_recording => 'إرسال الرسالة الصوتية';

  @override
  String get chat_voice_release_to_finish => 'اترك لإنهاء التسجيل الصوتي';

  @override
  String get chat_microphone_permission_denied => 'تم رفض إذن الميكروفون.';

  @override
  String get chat_voice_record_start_failed => 'تعذر بدء التسجيل الصوتي.';

  @override
  String get chat_voice_record_finish_failed => 'تعذر إنهاء التسجيل الصوتي.';

  @override
  String get chat_language_english => 'الإنجليزية';

  @override
  String get chat_language_swahili => 'السواحيلية';

  @override
  String get chat_language_french => 'الفرنسية';

  @override
  String get chat_language_spanish => 'الإسبانية';

  @override
  String get chat_language_german => 'الألمانية';

  @override
  String get chat_language_portuguese => 'البرتغالية';

  @override
  String get chat_language_arabic => 'العربية';

  @override
  String get chat_language_hausa => 'الهوسا';

  @override
  String get chat_language_yoruba => 'اليوروبا';

  @override
  String get chat_language_igbo => 'الإيغبو';

  @override
  String get chat_language_amharic => 'الأمهرية';

  @override
  String get chat_language_somali => 'الصومالية';

  @override
  String get chat_language_kinyarwanda => 'الكينيارواندا';

  @override
  String get chat_language_luganda => 'اللوغندية';

  @override
  String get chat_language_zulu => 'الزولو';

  @override
  String get chat_language_xhosa => 'الخوسا';

  @override
  String get chat_wallpaper_midnight => 'منتصف الليل';

  @override
  String get chat_wallpaper_navy => 'كحلي';

  @override
  String get chat_wallpaper_forest => 'غابة';

  @override
  String get chat_wallpaper_plum => 'برقوقي';

  @override
  String get chat_wallpaper_charcoal => 'فحمي';

  @override
  String get chat_wallpaper_maroon => 'خمري';

  @override
  String get chat_wallpaper_teal => 'أزرق مخضر';

  @override
  String get chat_wallpaper_coffee => 'قهوة';

  @override
  String get chat_audio_call => 'مكالمة صوتية';

  @override
  String get chat_clear_chat => 'مسح الدردشة';

  @override
  String get chat_audio => 'صوت';

  @override
  String get chat_view_replied_message => 'عرض الرسالة المُجاب عنها';

  @override
  String get chat_replied_message_unavailable =>
      'الرسالة المُجاب عنها لم تعد متاحة.';

  @override
  String get chat_clear_chat_title => 'مسح الدردشة؟';

  @override
  String get chat_clear_chats_title => 'مسح الدردشات؟';

  @override
  String get chat_clear_chat_description =>
      'يؤدي هذا إلى مسح جميع الرسائل الظاهرة في هذه الدردشة لديك فقط. سيحتفظ المشارك الآخر بنسخته.';

  @override
  String chat_clear_selected_chats_description(Object count) {
    return 'هل تريد مسح الرسائل الظاهرة في $count دردشات محددة لديك فقط؟ سيحتفظ المشاركون الآخرون بنسخهم.';
  }

  @override
  String get chat_chat_cleared => 'تم مسح الدردشة.';

  @override
  String get chat_clear_chat_failed => 'تعذر مسح الدردشة.';

  @override
  String get chat_select_conversations => 'تحديد الدردشات';

  @override
  String chat_selected_conversations(Object count) {
    return 'تم تحديد $count';
  }

  @override
  String get chat_cancel_selection => 'إلغاء التحديد';

  @override
  String get chat_mark_as_read => 'تحديد كمقروء';

  @override
  String get chat_clear_chats => 'مسح الدردشات';

  @override
  String get chat_delete_conversations => 'حذف الدردشة';

  @override
  String get chat_delete_conversations_title => 'حذف الدردشات؟';

  @override
  String chat_delete_selected_conversations_description(Object count) {
    return 'سيؤدي هذا إلى إزالة $count دردشات محددة من قائمتك. لن تُحذف لدى المشاركين الآخرين.';
  }

  @override
  String chat_selected_marked_read(Object count) {
    return 'تم تحديد $count دردشات كمقروءة.';
  }

  @override
  String chat_selected_chats_cleared(Object count) {
    return 'تم مسح $count دردشات محددة.';
  }

  @override
  String chat_selected_chats_deleted(Object count) {
    return 'تم حذف $count دردشات محددة.';
  }

  @override
  String get chat_selected_action_partial_failure =>
      'تعذر تحديث بعض الدردشات المحددة.';
}
