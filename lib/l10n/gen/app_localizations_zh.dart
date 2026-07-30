// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get onboarding_language_title => '选择您的语言';

  @override
  String get onboarding_language_subtitle => '应用将使用您选择的语言显示';

  @override
  String get onboarding_language_placeholder => '选择您的语言';

  @override
  String get onboarding_language_picker => '选择语言';

  @override
  String get onboarding_use_current_location => '使用当前位置';

  @override
  String get onboarding_use_country_currency => '使用国家货币';

  @override
  String get onboarding_loading_title => '正在加载选项';

  @override
  String get onboarding_loading_message => '正在加载设置选项。您可以重试或暂时跳过。';

  @override
  String get onboarding_offline_title => '无互联网连接';

  @override
  String get onboarding_offline_message => '无法加载这些选项。连接网络后重试，或暂时跳过且不保存虚构默认值。';

  @override
  String get common_try_again => '重试';

  @override
  String get common_no_languages => '没有可用语言';

  @override
  String get common_no_countries => '没有可用国家';

  @override
  String get common_search => '搜索';

  @override
  String get common_no_results => '没有匹配的选项';

  @override
  String get common_save => '保存';

  @override
  String get common_discard_changes_title => '放弃更改？';

  @override
  String get common_discard_changes_message => '您有未保存的更改。要放弃吗？';

  @override
  String get common_keep_editing => '继续编辑';

  @override
  String get common_discard => '放弃';

  @override
  String get common_selection_required => '请选择有效选项后继续。';

  @override
  String get onboarding_currency_title => '选择您的货币';

  @override
  String get onboarding_currency_subtitle => '价格将以您选择的货币显示';

  @override
  String get onboarding_currency_placeholder => '选择您的货币';

  @override
  String get onboarding_currency_picker => '选择货币';

  @override
  String get onboarding_country_title => '设置您的国家';

  @override
  String get onboarding_country_subtitle => '我们将向您展示附近的商品和卖家';

  @override
  String get onboarding_country_placeholder => '选择您的国家';

  @override
  String get onboarding_country_picker => '选择国家';

  @override
  String get common_continue => '继续';

  @override
  String get common_skip_for_now => '暂时跳过';

  @override
  String get common_get_started => '开始';

  @override
  String get common_no_currencies => '没有可用货币';

  @override
  String get auth_register_title => '注册';

  @override
  String get auth_register_subtitle => '输入您的信息以创建账户';

  @override
  String get auth_full_name => '姓名';

  @override
  String get auth_email_address => '电子邮件';

  @override
  String get auth_password => '密码';

  @override
  String get auth_confirm_password => '确认密码';

  @override
  String get auth_accept_terms_error => '请接受条款和隐私政策';

  @override
  String get auth_terms_and_conditions => '条款和条件';

  @override
  String get auth_privacy_policy => '隐私政策';

  @override
  String get auth_agree_prefix => '我同意 ';

  @override
  String get auth_and => ' 和 ';

  @override
  String get auth_register_button => '注册';

  @override
  String auth_unexpected_error(Object error) {
    return '发生未知错误：$error';
  }

  @override
  String get auth_already_have_account => '已经有账户？ ';

  @override
  String get auth_login => '登录';

  @override
  String get auth_login_title => '欢迎回来';

  @override
  String get auth_login_subtitle => '登录您的账户';

  @override
  String get auth_remember_me => '记住我';

  @override
  String get auth_forgot_password => '忘记密码？';

  @override
  String get auth_login_button => '登录';

  @override
  String get auth_no_account => '没有账户？';

  @override
  String get auth_register => '注册';

  @override
  String get auth_continue_google => '使用 Google 登录';

  @override
  String get auth_or => '或';

  @override
  String get auth_send_otp => '发送 OTP';

  @override
  String get auth_mail_reset_password => '输入您的电子邮件以重置密码';

  @override
  String get auth_password_updated_title => '密码更新\n成功';

  @override
  String get auth_password_updated_message => '您的密码已成功更新';

  @override
  String get auth_password_updated_button => '前往登录';

  @override
  String get auth_email_verification_title => '邮箱验证';

  @override
  String get auth_enter_verification_code => '输入验证码';

  @override
  String get auth_verification_code_sent_to => '我们已将验证码发送至';

  @override
  String get auth_email_verified_title => '邮箱验证\n成功';

  @override
  String get auth_email_verified_message => '您的邮箱已成功验证';

  @override
  String get auth_email_verified_button => '前往登录';

  @override
  String get auth_digit_code => '输入6位验证码';

  @override
  String get auth_resend_code => '没有收到验证码？ ';

  @override
  String get auth_resend => '重新发送';

  @override
  String get auth_resend_in => '重新发送于 ';

  @override
  String get nav_home => '首页';

  @override
  String get nav_categories => '分类';

  @override
  String get nav_selling => '出售';

  @override
  String get nav_contact => '联系';

  @override
  String get nav_account => '账户';

  @override
  String get common_see_all => '查看全部';

  @override
  String get home_flash_sales => 'AOS 闪购';

  @override
  String get home_services_near_you => '附近服务';

  @override
  String get home_new_products => 'AOS 新商品';

  @override
  String get home_electronic_deals => 'AOS 电子优惠';

  @override
  String get home_deals => 'AOS 优惠';

  @override
  String get home_furniture => '家具';

  @override
  String get home_electronics => '电子产品';

  @override
  String get home_fashion => '时尚';

  @override
  String get home_babies_kids => '婴儿与儿童';

  @override
  String get home_beauty => '美容';

  @override
  String get home_photography_tips => '摄影技巧';

  @override
  String get home_boost_marketing_reach => '提升您的营销覆盖范围';

  @override
  String get home_ranking_tips => '尝试最佳排名技巧';

  @override
  String get home_learn => '学习';

  @override
  String get home_top_deals => '热门优惠';

  @override
  String get home_best_prices => '最佳价格';

  @override
  String get home_shop_now => '立即购买';

  @override
  String get home_you_might_be_looking_for => '您可能正在寻找';

  @override
  String get ads_no_more_ads => '没有更多广告';

  @override
  String get location_all_locations => '所有地区';

  @override
  String get search_placeholder => '在此搜索...';

  @override
  String get search_button => '搜索';

  @override
  String get ads_my_listings => '我的列表';

  @override
  String get ads_no_listings_yet => '暂无列表';

  @override
  String get ads_no_listings_message => '您还没有发布任何广告';

  @override
  String get ads_start_selling_message => '通过创建您的第一条广告开始销售';

  @override
  String get ads_post_first_ad => '发布您的第一条广告';

  @override
  String get ads_learn_sell_faster => '学习如何更快销售';

  @override
  String get ads_create_ad => '创建广告';

  @override
  String get ads_update_ad => '更新广告';

  @override
  String get account_title => '账户';

  @override
  String get account_get_verified => '获取认证';

  @override
  String get account_boost_trust => '提升信任和可信度';

  @override
  String get account_settings => '账户设置';

  @override
  String get account_passwords_security => '密码与安全';

  @override
  String get account_notifications_preferences => '通知偏好';

  @override
  String get account_guest_title => '欢迎来到 AOS';

  @override
  String get account_guest_description => '登录以访问您的账户、管理广告等';

  @override
  String get app_preferences => '应用偏好';

  @override
  String get settings_dark_mode => '深色模式';

  @override
  String get common_other => '其他';

  @override
  String get common_discover_more => '发现更多';

  @override
  String get settings_privacy_policy => '隐私政策';

  @override
  String get settings_preferences => '偏好设置';

  @override
  String get settings_manage_app => '管理应用的运行方式';

  @override
  String get settings_language => '语言';

  @override
  String get settings_language_description => '控制应用中显示文本的方式。';

  @override
  String get settings_country => '国家';

  @override
  String get settings_country_description => '决定附近的列表以及您的广告显示的位置。';

  @override
  String get settings_currency => '货币';

  @override
  String get settings_currency_description => '用于查看和发布列表时的价格显示。';

  @override
  String get settings_terms_conditions => '条款和条件';

  @override
  String get onboarding_preference_error => '无法保存您的偏好设置。请重试。';

  @override
  String get wishlist_add => '添加到愿望清单';

  @override
  String get wishlist_remove => '从愿望清单中移除';

  @override
  String get wishlist_update_error => '无法更新您的愿望清单。请重试。';
}
