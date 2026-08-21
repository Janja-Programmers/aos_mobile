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
  String get settings_seller_country_locked_description =>
      '卖家账户的国家/地区已锁定，以保护市场数据。';

  @override
  String get settings_seller_country_locked => '卖家账户无法更改国家/地区。';

  @override
  String get common_locked => '已锁定';

  @override
  String get settings_preference_updated => '偏好设置已更新。';

  @override
  String get settings_currency => '货币';

  @override
  String get settings_currency_description => '用于查看和发布列表时的价格显示。';

  @override
  String get settings_terms_conditions => '条款和条件';

  @override
  String get onboarding_preference_error => '无法保存您的偏好设置。请重试。';

  @override
  String get session_restore_offline_title => '你当前处于离线状态';

  @override
  String get session_restore_offline_message =>
      'AOS 无法验证你现有的会话。请重新连接网络后重试。已保存的会话尚未清除。';

  @override
  String get session_restore_unavailable_title => '无法恢复你的会话';

  @override
  String get session_restore_unavailable_message =>
      'AOS 目前无法验证你现有的会话。请重试。已保存的会话尚未清除。';

  @override
  String get privacy_cover_accessibility_label => 'AOS 正在保护你的账户信息。';

  @override
  String get appLockScreenAccessibilityLabel => 'AOS 已锁定';

  @override
  String get appLockTitle => '解锁 AOS';

  @override
  String get appLockPrompt => '输入应用锁以继续。';

  @override
  String get appLockUnlock => '解锁';

  @override
  String get appLockAuthenticating => '正在验证…';

  @override
  String get appLockLogout => '退出登录';

  @override
  String get appLockForgottenCredentialHelp => '重置应用锁可退出登录并删除忘记的本地凭据。';

  @override
  String get appLockUnlockReason => '验证身份以解锁 AOS。';

  @override
  String get appLockEnableReason => '验证身份以启用生物识别应用锁。';

  @override
  String get appLockDisableReason => '验证身份以停用应用锁。';

  @override
  String get appLockCancelled => '验证已取消。您的会话仍保持登录。';

  @override
  String get appLockTemporaryLockout => '尝试次数过多。请稍后重试或重置应用锁。';

  @override
  String get appLockPermanentLockout => '生物识别已锁定。请使用设备恢复方式或重置应用锁。';

  @override
  String get appLockNoDeviceCredential => '请先在设备设置中登记指纹、Face ID 或其他受支持的生物识别。';

  @override
  String get appLockUnsupported => '此设备不支持本机设备验证。';

  @override
  String get appLockTryAgain => '重试';

  @override
  String get appLockFailed => '验证失败。请重试。';

  @override
  String get appLockSettingTitle => '应用锁';

  @override
  String get appLockSettingDescription => '使用 4 位 PIN、图案或生物识别保护私密区域。';

  @override
  String get appLockTimingTitle => '锁定时间';

  @override
  String get appLockTimingImmediately => '立即';

  @override
  String get appLockTimingThirtySeconds => '30 秒后';

  @override
  String get appLockTimingOneMinute => '1 分钟后';

  @override
  String get appLockTimingFiveMinutes => '5 分钟后';

  @override
  String get wishlist_add => '添加到愿望清单';

  @override
  String get wishlist_remove => '从愿望清单中移除';

  @override
  String get wishlist_update_error => '无法更新愿望清单。请重试。';

  @override
  String get appLockBiometricPrompt => '使用已登记的指纹、面容或其他生物识别方式继续。';

  @override
  String get appLockUseBiometrics => '使用生物识别';

  @override
  String get appLockReset => '重置应用锁';

  @override
  String get appLockResetHelp => '忘记 PIN 或图案？重置会退出登录并删除本地应用锁。';

  @override
  String get appLockResetTitle => '重置应用锁？';

  @override
  String get appLockResetMessage => '这会退出登录、删除已保存的应用锁并返回公开区域。重新登录后可设置新锁。';

  @override
  String get appLockResetConfirm => '重置并退出登录';

  @override
  String get appLockCancel => '取消';

  @override
  String get appLockClear => '清除';

  @override
  String get appLockEnterPin => '输入 4 位 PIN';

  @override
  String get appLockEnterPattern => '绘制图案';

  @override
  String get appLockInvalidCredential => '应用锁凭据不正确，请重试。';

  @override
  String get appLockPinHelp => '必须正好使用 4 位数字。';

  @override
  String get appLockPatternHelp => '至少连接 4 个点。';

  @override
  String get appLockConfirmPin => '确认 PIN';

  @override
  String get appLockConfirmPattern => '确认图案';

  @override
  String get appLockConfirmationMismatch => '两次输入不一致，请重试。';

  @override
  String get appLockContinue => '继续';

  @override
  String get appLockConfirm => '确认';

  @override
  String get appLockStorageFailure => '无法安全保存应用锁设置，请重试。';

  @override
  String get appLockConfigured => '应用锁已启用';

  @override
  String get appLockProcessRestartNote => '应用被终止或重新启动后，AOS 始终会锁定。';

  @override
  String get appLockChangeMethod => '更改锁定方式';

  @override
  String get appLockDisable => '停用应用锁';

  @override
  String get appLockChooseMethod => '选择锁定方式';

  @override
  String get appLockMethodHelp => 'PIN 和图案只以安全加盐哈希保存。生物识别数据始终由设备管理。';

  @override
  String get appLockMethodPin => '4 位 PIN';

  @override
  String get appLockMethodPattern => '图案';

  @override
  String get appLockMethodBiometric => '指纹或生物识别';

  @override
  String get appLockChangeReason => '验证身份以更改应用锁。';

  @override
  String get appLockTimingFiveSeconds => '5 秒后';

  @override
  String get appLockTimingTenSeconds => '10 秒后';

  @override
  String get appLockTimingFifteenSeconds => '15 秒后';

  @override
  String get appLockPinInputAccessibility => 'PIN 输入';

  @override
  String get appLockPatternInputAccessibility => '图案输入';

  @override
  String get appLockPatternPointAccessibility => '图案点';

  @override
  String get ads_location_select_title => '选择地点';

  @override
  String ads_location_results_more(Object count) {
    return '找到超过 $count 个地点';
  }

  @override
  String ads_location_results_exact(Object count) {
    return '找到 $count 个地点';
  }

  @override
  String get ad_media_download_image => '下载图片';

  @override
  String get ad_media_saved_to_gallery => '图片已保存到图库。';

  @override
  String get liveLikeAction => '点赞直播';

  @override
  String get liveShareAction => '分享直播';

  @override
  String get liveMuteAction => '关闭麦克风';

  @override
  String get liveUnmuteAction => '打开麦克风';

  @override
  String get liveFlipCameraAction => '切换摄像头';

  @override
  String get liveGoLiveAction => '开始直播';

  @override
  String get liveStartingAction => '正在开始...';

  @override
  String get liveDetailsTitle => '直播详情';

  @override
  String get liveEditDetailsAction => '编辑直播详情';

  @override
  String get liveEditDetailsHint => '点按以编辑标题或封面';

  @override
  String get liveCoverLabel => '封面照片';

  @override
  String get liveChangeCoverAction => '更换封面';

  @override
  String get liveChooseCoverFromGallery => '从图库选择';

  @override
  String get liveTakeCoverPhoto => '拍摄照片';

  @override
  String get liveTitleLabel => '直播标题';

  @override
  String get liveTitleHint => '添加直播标题';

  @override
  String get liveTitleRequired => '请添加直播标题以继续。';

  @override
  String get liveCoverRequired => '请添加封面照片以继续。';

  @override
  String get liveUploadingCover => '正在上传封面...';

  @override
  String get liveCameraStarting => '正在启动摄像头...';

  @override
  String get liveCameraUnavailable => '摄像头预览不可用';

  @override
  String get liveCameraStartError => '无法启动摄像头预览。';

  @override
  String get liveNoAlternateCameraError => '没有可用的其他摄像头。';

  @override
  String get liveCameraFlipError => '无法切换摄像头。';

  @override
  String get liveCoverUploadError => '无法上传直播封面。';

  @override
  String get liveCoverSelectionError => '无法选择直播封面。';

  @override
  String get watchThisLiveOnAos => '在 AOS 上观看此直播';

  @override
  String get unableToOpenShareOptions => '无法打开分享选项。';

  @override
  String get chat_connect_title => 'AOS Connect';

  @override
  String get chat_close_connect => '关闭 Connect';

  @override
  String get chat_close_search => '关闭搜索';

  @override
  String get chat_search => '搜索';

  @override
  String get chat_more_options => '更多选项';

  @override
  String get chat_search_chats_hint => '搜索聊天…';

  @override
  String get chat_search_calls_hint => '搜索通话…';

  @override
  String get chat_all_marked_read => '所有聊天均已标记为已读。';

  @override
  String get chat_some_mark_read_failed => '部分聊天无法标记为已读。';

  @override
  String get chat_clear_call_log_title => '清除通话记录？';

  @override
  String get chat_clear_call_log_body => '这会删除您可见的通话历史，不会删除其他用户的记录。';

  @override
  String get chat_cancel => '取消';

  @override
  String get chat_clear => '清除';

  @override
  String get chat_call_log_cleared => '通话记录已清除。';

  @override
  String get chat_call_log_clear_failed => '无法清除通话记录。';

  @override
  String get chat_clear_call_log => '清除通话记录';

  @override
  String get chat_settings => '设置';

  @override
  String get chat_mark_all_read => '全部标为已读';

  @override
  String get chat_starred_messages => '已加星标的消息';

  @override
  String get chat_chats => '聊天';

  @override
  String get chat_new_conversation => '新建对话';

  @override
  String get chat_new => '新建';

  @override
  String get chat_calls => '通话';

  @override
  String get chat_back => '返回';

  @override
  String get chat_call => '通话';

  @override
  String get chat_video_call => '视频通话';

  @override
  String get chat_change_wallpaper => '更换壁纸';

  @override
  String get chat_user_might_be_offline => '用户可能不在线';

  @override
  String get chat_failed_to_start_call => '无法发起通话';

  @override
  String get chat_gallery => '图库';

  @override
  String get chat_camera => '相机';

  @override
  String get chat_voice_call => '语音通话';

  @override
  String get chat_location => '位置';

  @override
  String get chat_document => '文档';

  @override
  String get chat_contact => '联系人';

  @override
  String get chat_attachment_upload_failed => '附件上传失败，请重试。';

  @override
  String get chat_message_hint => '消息';

  @override
  String get chat_share_location_title => '共享位置';

  @override
  String get chat_retry => '重试';

  @override
  String get chat_could_not_load_messages => '无法加载消息';

  @override
  String get chat_check_connection_try_again => '请检查网络连接后重试。';

  @override
  String get chat_no_messages_yet => '暂无消息';

  @override
  String get chat_no_messages_hint => '发送消息以开始此对话。';

  @override
  String get chat_older_messages_load_failed => '无法加载更早的消息。';

  @override
  String get chat_reply => '回复';

  @override
  String get chat_edit => '编辑';

  @override
  String get chat_copy => '复制';

  @override
  String get chat_forward => '转发';

  @override
  String get chat_translate_again => '重新翻译';

  @override
  String get chat_translate => '翻译';

  @override
  String get chat_unstar => '取消星标';

  @override
  String get chat_star => '加星标';

  @override
  String get chat_delete_for_me => '为我删除';

  @override
  String get chat_delete_for_everyone => '为所有人删除';

  @override
  String get chat_message_reactions => '消息回应';

  @override
  String get chat_choose_another_reaction => '选择其他回应';

  @override
  String chat_react_with(Object emoji) {
    return '使用 $emoji 回应';
  }

  @override
  String chat_remove_reaction(Object emoji) {
    return '移除 $emoji 回应';
  }

  @override
  String get chat_editing_message => '正在编辑消息';

  @override
  String get chat_cancel_editing => '取消编辑';

  @override
  String get chat_copied_to_clipboard => '已复制到剪贴板';

  @override
  String get chat_message_still_failed => '消息仍未发送，请重试。';

  @override
  String get chat_send_ad_failed => '广告消息发送失败，请重试。';

  @override
  String get chat_send_failed => '消息发送失败，请重试。';

  @override
  String get chat_star_update_failed => '无法更新星标。';

  @override
  String get chat_reaction_update_failed => '无法更新回应。';

  @override
  String get chat_forward_failed => '无法转发消息。';

  @override
  String get chat_forwarded => '消息已转发。';

  @override
  String chat_forwarded_to_chats(Object count) {
    return '消息已转发到 $count 个聊天。';
  }

  @override
  String get chat_translate_failed => '无法翻译消息。';

  @override
  String get chat_delete_failed => '无法删除消息。';

  @override
  String get chat_deleted_for_everyone => '消息已为所有人删除。';

  @override
  String get chat_deleted_for_you => '消息已为您删除。';

  @override
  String get chat_edit_failed => '无法编辑消息。';

  @override
  String get chat_settings_title => '聊天设置';

  @override
  String get chat_privacy => '隐私';

  @override
  String get chat_read_receipts => '已读回执';

  @override
  String get chat_read_receipts_managed => '由 AOS 管理消息送达状态';

  @override
  String get chat_last_seen_online => '最后上线与在线状态';

  @override
  String get chat_no_backend_preference => '服务器未提供此账户偏好设置';

  @override
  String get chat_blocked_contacts => '已屏蔽的联系人';

  @override
  String get chat_chats_section => '聊天';

  @override
  String get chat_wallpaper => '聊天壁纸';

  @override
  String get chat_wallpaper_description => '设置默认聊天背景';

  @override
  String get chat_enter_is_send => '按 Enter 发送';

  @override
  String get chat_enter_is_send_description => '按 Enter 键发送消息';

  @override
  String get chat_media_auto_download => '媒体自动下载';

  @override
  String get chat_unavailable_backend => '当前服务器协议不支持';

  @override
  String get chat_notifications => '通知';

  @override
  String get chat_message_notifications => '消息通知';

  @override
  String get chat_call_notifications => '通话通知';

  @override
  String get chat_system_notification_settings => '由系统通知设置控制';

  @override
  String get chat_on => '开启';

  @override
  String get chat_off => '关闭';

  @override
  String get chat_starred_load_failed => '无法加载已加星标的消息';

  @override
  String get chat_no_starred_messages => '没有已加星标的消息';

  @override
  String get chat_no_starred_messages_hint => '您加星标的消息会显示在这里。';

  @override
  String get chat_unstar_message => '取消消息星标';

  @override
  String get chat_unstar_failed => '无法取消消息星标。';

  @override
  String get chat_message_unstarred => '已取消消息星标。';

  @override
  String get chat_attachment => '附件';

  @override
  String get chat_you => '您';

  @override
  String get chat_other_user => '其他用户';

  @override
  String get chat_aos_user => 'AOS 用户';

  @override
  String get chat_sending => '正在发送…';

  @override
  String get chat_edited => '已编辑';

  @override
  String get chat_starred => '已加星标';

  @override
  String get chat_translated => '已翻译';

  @override
  String get chat_failed_to_send => '发送失败';

  @override
  String get chat_read => '已读';

  @override
  String get chat_delivered => '已送达';

  @override
  String get chat_sent => '已发送';

  @override
  String get chat_forwarded_label => '已转发';

  @override
  String get chat_deleted_message => '此消息已删除';

  @override
  String get chat_translating => '正在翻译…';

  @override
  String get chat_tap_to_retry => '点按重试';

  @override
  String get chat_translate_to => '翻译为';

  @override
  String chat_translate_to_language(Object language) {
    return '翻译为$language';
  }

  @override
  String get chat_voice_release_cancel => '松开以取消';

  @override
  String get chat_voice_recording_locked => '录音已锁定';

  @override
  String get chat_voice_slide_cancel => '向左滑动以取消';

  @override
  String chat_voice_recording_status(Object duration, Object instruction) {
    return '语音录制 $duration。$instruction';
  }

  @override
  String chat_starred_message_from(Object sender) {
    return '来自 $sender 的星标消息';
  }

  @override
  String get chat_verified_sellers => '认证卖家';

  @override
  String get chat_friends => '好友';

  @override
  String get chat_search_sellers_hint => '搜索卖家…';

  @override
  String get chat_search_friends_hint => '搜索好友…';

  @override
  String get chat_loading_sellers => '正在加载卖家';

  @override
  String get chat_loading_sellers_hint => '正在查找认证卖家，请稍候。';

  @override
  String get chat_could_not_load_sellers => '无法加载卖家';

  @override
  String get chat_no_verified_sellers => '暂无认证卖家';

  @override
  String get chat_no_sellers_found => '未找到卖家';

  @override
  String get chat_no_verified_sellers_hint => '认证卖家可用时会显示在这里。';

  @override
  String get chat_no_sellers_found_hint => '请尝试其他卖家名称、类别或位置。';

  @override
  String get chat_refresh => '刷新';

  @override
  String get chat_loading_friends => '正在加载好友';

  @override
  String get chat_loading_friends_hint => '正在查找您的好友，请稍候。';

  @override
  String get chat_could_not_load_friends => '无法加载好友';

  @override
  String get chat_try_again => '请重试。';

  @override
  String get chat_no_friends_yet => '暂无好友';

  @override
  String get chat_no_friends_found => '未找到好友';

  @override
  String get chat_no_friends_yet_hint => '互相关注后，好友会显示在这里。';

  @override
  String get chat_no_friends_found_hint => '请尝试其他姓名或电子邮件。';

  @override
  String get chat_online => '在线';

  @override
  String get chat_last_seen_recently => '最近上线';

  @override
  String get chat_friend => '好友';

  @override
  String get chat_message_contact => '发消息';

  @override
  String get chat_call_contact => '通话';

  @override
  String get chat_all_chats => '全部聊天';

  @override
  String get chat_unread => '未读';

  @override
  String get chat_loading_conversations => '正在加载对话';

  @override
  String get chat_loading_conversations_hint => '正在获取您的聊天，请稍候。';

  @override
  String get chat_could_not_load_chats => '无法加载聊天';

  @override
  String get chat_no_chats_found => '未找到聊天';

  @override
  String get chat_no_chats_search_hint => '请尝试其他姓名或消息。';

  @override
  String get chat_no_read_chats => '没有已读聊天';

  @override
  String get chat_no_unread_chats => '没有未读聊天';

  @override
  String get chat_no_conversations_yet => '暂无对话';

  @override
  String get chat_no_read_chats_hint => '您已读的聊天会显示在这里。';

  @override
  String get chat_no_unread_chats_hint => '有新消息时，未读聊天会显示在这里。';

  @override
  String get chat_no_conversations_hint => '开始聊天后，您的对话会显示在这里。';

  @override
  String get chat_deleted_from_list => '聊天已从您的对话列表中删除。';

  @override
  String get chat_delete_chat_failed => '无法删除聊天，请重试。';

  @override
  String get chat_typing => '正在输入…';

  @override
  String chat_last_seen_time(Object time) {
    return '最后上线 $time';
  }

  @override
  String get chat_forward_to_title => '转发给';

  @override
  String get chat_close => '关闭';

  @override
  String get chat_search_conversations_hint => '搜索会话';

  @override
  String get chat_clear_search => '清除搜索';

  @override
  String get chat_could_not_load_conversations => '无法加载会话';

  @override
  String get chat_no_other_conversations => '没有其他会话';

  @override
  String get chat_no_other_conversations_hint => '请先开始另一个聊天，然后即可将消息转发到那里。';

  @override
  String get chat_no_conversations_found => '未找到会话';

  @override
  String get chat_search_conversations_empty_hint => '请尝试其他姓名或消息。';

  @override
  String get chat_forward_to_one_chat => '转发到 1 个聊天';

  @override
  String chat_forward_to_chats_count(Object count) {
    return '转发到 $count 个聊天';
  }

  @override
  String get chat_default_wallpaper_applied => '已应用默认壁纸。';

  @override
  String get chat_wallpaper_updated => '壁纸已更新。';

  @override
  String chat_named_wallpaper_applied(Object name) {
    return '已应用$name壁纸。';
  }

  @override
  String get chat_choose_conversation_background => '为此会话选择背景';

  @override
  String get chat_default => '默认';

  @override
  String get chat_choose_from_gallery => '从图库选择';

  @override
  String get chat_solid_colors => '纯色';

  @override
  String get chat_emoji_recent => '最近';

  @override
  String get chat_emoji_smileys => '表情';

  @override
  String get chat_emoji_animals => '动物';

  @override
  String get chat_emoji_food => '食物';

  @override
  String get chat_emoji_flags => '旗帜';

  @override
  String get chat_search_emoji => '搜索表情';

  @override
  String get chat_no_emoji_found => '未找到表情';

  @override
  String get chat_share_contact => '分享联系人';

  @override
  String get chat_search_aos_users => '搜索 AOS 用户';

  @override
  String get chat_could_not_load_contacts => '无法加载联系人';

  @override
  String get chat_search_people_on_aos => '在 AOS 上搜索用户';

  @override
  String get chat_search_people_hint => '输入至少 2 个字符以查找要分享的联系人。';

  @override
  String get chat_no_contacts_found => '未找到联系人';

  @override
  String get chat_no_contacts_found_hint => '请尝试其他姓名、用户名或电子邮件。';

  @override
  String get chat_unmute => '取消静音';

  @override
  String get chat_mute => '静音';

  @override
  String get chat_end_call => '结束通话';

  @override
  String get chat_calling => '正在呼叫';

  @override
  String get chat_ringing => '正在响铃';

  @override
  String get chat_incoming_call => '来电';

  @override
  String get chat_connecting => '正在连接';

  @override
  String get chat_delete_chat_title => '删除聊天？';

  @override
  String chat_delete_chat_description(Object name) {
    return '这会从你的会话列表中移除与$name的聊天，但不会为对方删除。';
  }

  @override
  String get chat_this_user => '此用户';

  @override
  String get chat_delete => '删除';

  @override
  String get chat_view_profile => '查看个人资料';

  @override
  String get chat_view_contact => '查看联系人';

  @override
  String get chat_cannot_open_document => '无法打开此类型的文档';

  @override
  String get chat_failed_to_start_chat => '无法开始聊天，请重试。';

  @override
  String get chat_invalid_conversation_response => '会话响应无效';

  @override
  String get chat_voice_hold_to_record => '长按录制语音消息';

  @override
  String get chat_voice_tap_to_record => '点按录制语音消息';

  @override
  String get chat_voice_pause => '暂停录音';

  @override
  String get chat_voice_resume => '继续录音';

  @override
  String get chat_voice_delete_recording => '删除录音';

  @override
  String get chat_voice_send_recording => '发送语音消息';

  @override
  String get chat_voice_release_to_finish => '松开以结束语音录制';

  @override
  String get chat_microphone_permission_denied => '麦克风权限被拒绝。';

  @override
  String get chat_voice_record_start_failed => '无法开始语音录制。';

  @override
  String get chat_voice_record_finish_failed => '无法结束语音录制。';

  @override
  String get chat_language_english => '英语';

  @override
  String get chat_language_swahili => '斯瓦希里语';

  @override
  String get chat_language_french => '法语';

  @override
  String get chat_language_spanish => '西班牙语';

  @override
  String get chat_language_german => '德语';

  @override
  String get chat_language_portuguese => '葡萄牙语';

  @override
  String get chat_language_arabic => '阿拉伯语';

  @override
  String get chat_language_hausa => '豪萨语';

  @override
  String get chat_language_yoruba => '约鲁巴语';

  @override
  String get chat_language_igbo => '伊博语';

  @override
  String get chat_language_amharic => '阿姆哈拉语';

  @override
  String get chat_language_somali => '索马里语';

  @override
  String get chat_language_kinyarwanda => '卢旺达语';

  @override
  String get chat_language_luganda => '卢干达语';

  @override
  String get chat_language_zulu => '祖鲁语';

  @override
  String get chat_language_xhosa => '科萨语';

  @override
  String get chat_wallpaper_midnight => '午夜';

  @override
  String get chat_wallpaper_navy => '海军蓝';

  @override
  String get chat_wallpaper_forest => '森林';

  @override
  String get chat_wallpaper_plum => '梅子色';

  @override
  String get chat_wallpaper_charcoal => '炭灰色';

  @override
  String get chat_wallpaper_maroon => '栗色';

  @override
  String get chat_wallpaper_teal => '青绿色';

  @override
  String get chat_wallpaper_coffee => '咖啡色';
}
