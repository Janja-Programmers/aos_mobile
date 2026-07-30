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
  String get wishlist_add => 'إضافة إلى قائمة الرغبات';

  @override
  String get wishlist_remove => 'إزالة من قائمة الرغبات';

  @override
  String get wishlist_update_error =>
      'تعذر تحديث قائمة رغباتك. يُرجى المحاولة مرة أخرى.';
}
