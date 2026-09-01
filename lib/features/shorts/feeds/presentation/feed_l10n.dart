import 'package:africaonlinestores/l10n/gen/app_localizations.dart';

extension FeedFeatureLocalizations on AppLocalizations {
  String _pick({
    required String en,
    required String fr,
    required String ar,
    required String sw,
    required String zh,
  }) {
    return switch (localeName.split('_').first.toLowerCase()) {
      'fr' => fr,
      'ar' => ar,
      'sw' => sw,
      'zh' => zh,
      _ => en,
    };
  }

  String get feedForYou => _pick(
    en: 'For You',
    fr: 'Pour vous',
    ar: 'لك',
    sw: 'Kwa Ajili Yako',
    zh: '为你推荐',
  );

  String get feedFollowing => _pick(
    en: 'Following',
    fr: 'Abonnements',
    ar: 'المتابَعون',
    sw: 'Unaowafuata',
    zh: '关注',
  );

  String get feedLive =>
      _pick(en: 'Live', fr: 'Live', ar: 'مباشر', sw: 'Live', zh: '直播');

  String get feedSearchHint => _pick(
    en: 'Discover shorts, lives & shops...',
    fr: 'Découvrez des shorts, lives et boutiques...',
    ar: 'اكتشف المقاطع والبثوث والمتاجر...',
    sw: 'Gundua shorts, live na maduka...',
    zh: '发现短视频、直播和店铺…',
  );

  String get feedNotifications => _pick(
    en: 'Notifications',
    fr: 'Notifications',
    ar: 'الإشعارات',
    sw: 'Arifa',
    zh: '通知',
  );

  String get feedCategoryAll =>
      _pick(en: 'All', fr: 'Tout', ar: 'الكل', sw: 'Zote', zh: '全部');

  String get feedCategoryShop =>
      _pick(en: 'Shop', fr: 'Boutique', ar: 'تسوّق', sw: 'Duka', zh: '购物');

  String get feedCreator => _pick(
    en: 'Creator',
    fr: 'Créateur',
    ar: 'منشئ المحتوى',
    sw: 'Mbunifu',
    zh: '创作者',
  );

  String get feedCategoryGeo =>
      _pick(en: 'Geo', fr: 'Geo', ar: 'Geo', sw: 'Geo', zh: 'Geo');

  String get feedCategoryVibes =>
      _pick(en: 'Vibes', fr: 'Vibes', ar: 'Vibes', sw: 'Vibes', zh: 'Vibes');

  String get feedCategoryLearn =>
      _pick(en: 'Learn', fr: 'Apprendre', ar: 'تعلّم', sw: 'Jifunze', zh: '学习');

  String get feedLiveNow => _pick(
    en: 'LIVE now',
    fr: 'EN DIRECT',
    ar: 'مباشر الآن',
    sw: 'LIVE sasa',
    zh: '正在直播',
  );

  String get feedLiveNowSubtitle => _pick(
    en: 'Watch creators live across AOS.',
    fr: 'Regardez les créateurs en direct sur AOS.',
    ar: 'شاهد المبدعين مباشرة على AOS.',
    sw: 'Tazama wabunifu live kote AOS.',
    zh: '观看 AOS 创作者直播。',
  );

  String get feedRefreshLives => _pick(
    en: 'Refresh live streams',
    fr: 'Actualiser les lives',
    ar: 'تحديث البثوث المباشرة',
    sw: 'Onyesha upya live',
    zh: '刷新直播',
  );

  String get feedCouldNotLoad => _pick(
    en: 'Could not load this feed.',
    fr: 'Impossible de charger ce fil.',
    ar: 'تعذر تحميل هذه الخلاصة.',
    sw: 'Imeshindikana kupakia mkondo huu.',
    zh: '无法加载此动态。',
  );

  String get feedTryAgain => _pick(
    en: 'Try again',
    fr: 'Réessayer',
    ar: 'حاول مجددًا',
    sw: 'Jaribu tena',
    zh: '重试',
  );

  String get feedCouldNotLoadMore => _pick(
    en: 'Could not load more.',
    fr: 'Impossible de charger davantage.',
    ar: 'تعذر تحميل المزيد.',
    sw: 'Imeshindikana kupakia zaidi.',
    zh: '无法加载更多内容。',
  );

  String get feedFollowingShorts => _pick(
    en: 'Following Shorts',
    fr: 'Shorts suivis',
    ar: 'مقاطع من تتابعهم',
    sw: 'Shorts za unaowafuata',
    zh: '关注的短视频',
  );

  String get feedRefresh => _pick(
    en: 'Refresh',
    fr: 'Actualiser',
    ar: 'تحديث',
    sw: 'Onyesha upya',
    zh: '刷新',
  );

  String feedNoCategoryShortsTitle(String category) => _pick(
    en: 'No $category shorts yet',
    fr: 'Aucun short $category pour le moment',
    ar: 'لا توجد مقاطع $category حتى الآن',
    sw: 'Bado hakuna shorts za $category',
    zh: '暂无“$category”短视频',
  );

  String get feedNoCategoryShortsMessage => _pick(
    en: 'There are no shorts in this category right now. Pull down or tap refresh to check again.',
    fr: 'Aucun short dans cette catégorie pour le moment. Tirez vers le bas ou actualisez pour réessayer.',
    ar: 'لا توجد مقاطع في هذه الفئة الآن. اسحب للأسفل أو اضغط على التحديث للمحاولة مجددًا.',
    sw: 'Hakuna shorts katika kundi hili sasa. Vuta chini au bonyeza kuonyesha upya ili kujaribu tena.',
    zh: '此分类目前没有短视频。下拉或点击刷新再次查看。',
  );

  String get feedNoShortsTitle => _pick(
    en: 'No shorts yet',
    fr: 'Aucun short pour le moment',
    ar: 'لا توجد مقاطع حتى الآن',
    sw: 'Bado hakuna shorts',
    zh: '暂无短视频',
  );

  String get feedNoFollowingShortsTitle => _pick(
    en: 'No following shorts yet',
    fr: 'Aucun short des comptes suivis',
    ar: 'لا توجد مقاطع ممن تتابعهم',
    sw: 'Bado hakuna shorts za unaowafuata',
    zh: '暂无关注账号的短视频',
  );

  String get feedNoLivesTitle => _pick(
    en: 'No live streams yet',
    fr: 'Aucun live pour le moment',
    ar: 'لا توجد بثوث مباشرة الآن',
    sw: 'Bado hakuna live',
    zh: '暂无直播',
  );

  String get feedNoShortsMessage => _pick(
    en: 'Fresh shorts will appear here when creators start posting.',
    fr: 'Les nouveaux shorts apparaîtront ici lorsque les créateurs publieront.',
    ar: 'ستظهر المقاطع الجديدة هنا عندما يبدأ المبدعون بالنشر.',
    sw: 'Shorts mpya zitaonekana hapa wabunifu wanapoanza kuchapisha.',
    zh: '创作者发布后，新短视频会显示在这里。',
  );

  String get feedNoFollowingShortsMessage => _pick(
    en: 'Follow creators and shops to see their latest shorts here.',
    fr: 'Suivez des créateurs et des boutiques pour voir leurs derniers shorts ici.',
    ar: 'تابع المبدعين والمتاجر لمشاهدة أحدث مقاطعهم هنا.',
    sw: 'Fuata wabunifu na maduka ili kuona shorts zao mpya hapa.',
    zh: '关注创作者和店铺，即可在这里看到他们的最新短视频。',
  );

  String get feedNoLivesMessage => _pick(
    en: 'Live streams will appear here when creators go live.',
    fr: 'Les lives apparaîtront ici lorsque les créateurs seront en direct.',
    ar: 'ستظهر البثوث هنا عندما يبدأ المبدعون البث المباشر.',
    sw: 'Live zitaonekana hapa wabunifu wanapoanza kutangaza.',
    zh: '创作者开播后，直播会显示在这里。',
  );

  String get feedLiveBadge =>
      _pick(en: 'LIVE', fr: 'LIVE', ar: 'مباشر', sw: 'LIVE', zh: '直播');

  String get feedShopBadge =>
      _pick(en: 'Shop', fr: 'Boutique', ar: 'تسوّق', sw: 'Duka', zh: '购物');

  String get feedGeoBadge => feedCategoryGeo;

  String get feedVibesBadge => feedCategoryVibes;

  String get feedLearnBadge => feedCategoryLearn;

  String get feedProcessing => _pick(
    en: 'Processing',
    fr: 'Traitement',
    ar: 'قيد المعالجة',
    sw: 'Inachakatwa',
    zh: '处理中',
  );

  String get feedFailed =>
      _pick(en: 'Failed', fr: 'Échec', ar: 'فشل', sw: 'Imeshindwa', zh: '失败');

  String get feedHidden =>
      _pick(en: 'Hidden', fr: 'Masqué', ar: 'مخفي', sw: 'Imefichwa', zh: '已隐藏');

  String get feedDeleted => _pick(
    en: 'Deleted',
    fr: 'Supprimé',
    ar: 'محذوف',
    sw: 'Imefutwa',
    zh: '已删除',
  );

  String get feedFollowers => _pick(
    en: 'Followers',
    fr: 'Abonnés',
    ar: 'المتابعون',
    sw: 'Wafuasi',
    zh: '粉丝',
  );

  String get feedFriends => _pick(
    en: 'Friends',
    fr: 'Amis',
    ar: 'الأصدقاء',
    sw: 'Marafiki',
    zh: '好友',
  );

  String get feedOnlyMe => _pick(
    en: 'Only me',
    fr: 'Moi uniquement',
    ar: 'أنا فقط',
    sw: 'Mimi pekee',
    zh: '仅自己',
  );

  String get feedPrivate =>
      _pick(en: 'Private', fr: 'Privé', ar: 'خاص', sw: 'Faragha', zh: '私密');

  String feedLikesSemantics(int count) => _pick(
    en: '$count likes',
    fr: '$count mentions J’aime',
    ar: '$count إعجاب',
    sw: 'Imependwa mara $count',
    zh: '$count 个赞',
  );

  String feedViewersSemantics(int count) => _pick(
    en: '$count viewers',
    fr: '$count spectateurs',
    ar: '$count مشاهد',
    sw: 'Watazamaji $count',
    zh: '$count 位观众',
  );

  String feedShortCardSemantics(String creator, String caption) => _pick(
    en: caption.isEmpty ? 'Short by $creator' : '$caption, by $creator',
    fr: caption.isEmpty ? 'Short de $creator' : '$caption, par $creator',
    ar: caption.isEmpty ? 'مقطع بواسطة $creator' : '$caption، بواسطة $creator',
    sw: caption.isEmpty ? 'Short ya $creator' : '$caption, ya $creator',
    zh: caption.isEmpty ? '$creator 的短视频' : '$caption，作者 $creator',
  );

  String feedLiveCardSemantics(String host, String title, int viewers) => _pick(
    en: '$title, live by $host, $viewers viewers',
    fr: '$title, en direct par $host, $viewers spectateurs',
    ar: '$title، بث مباشر بواسطة $host، $viewers مشاهد',
    sw: '$title, live ya $host, watazamaji $viewers',
    zh: '$title，$host 正在直播，$viewers 位观众',
  );
}
