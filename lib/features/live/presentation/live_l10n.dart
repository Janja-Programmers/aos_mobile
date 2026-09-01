import 'package:africaonlinestores/l10n/gen/app_localizations.dart';

extension LiveFeatureLocalizations on AppLocalizations {
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

  String get liveViewersTitle => _pick(
    en: 'Viewers',
    fr: 'Spectateurs',
    ar: 'المشاهدون',
    sw: 'Watazamaji',
    zh: '观众',
  );
  String liveWatchingNow(int count) => _pick(
    en: '$count watching now',
    fr: '$count en direct',
    ar: '$count يشاهدون الآن',
    sw: '$count wanatazama sasa',
    zh: '$count 人正在观看',
  );
  String get liveViewerProfileTitle => _pick(
    en: 'Viewer profile',
    fr: 'Profil du spectateur',
    ar: 'ملف المشاهد',
    sw: 'Wasifu wa mtazamaji',
    zh: '观众资料',
  );
  String get liveProfileLabel => _pick(
    en: 'LIVE PROFILE',
    fr: 'PROFIL LIVE',
    ar: 'ملف البث',
    sw: 'WASIFU WA LIVE',
    zh: '直播资料',
  );
  String get liveProfileUnavailable => _pick(
    en: 'Profile unavailable',
    fr: 'Profil indisponible',
    ar: 'الملف غير متاح',
    sw: 'Wasifu haupatikani',
    zh: '资料不可用',
  );
  String get liveProfileUnavailableBody => _pick(
    en: 'This profile cannot be opened right now.',
    fr: 'Ce profil ne peut pas être ouvert pour le moment.',
    ar: 'لا يمكن فتح هذا الملف الآن.',
    sw: 'Wasifu huu hauwezi kufunguliwa sasa.',
    zh: '暂时无法打开此资料。',
  );
  String get liveFollowers => _pick(
    en: 'Followers',
    fr: 'Abonnés',
    ar: 'المتابعون',
    sw: 'Wafuasi',
    zh: '粉丝',
  );
  String get liveFollowing => _pick(
    en: 'Following',
    fr: 'Abonnements',
    ar: 'يتابع',
    sw: 'Anafuata',
    zh: '关注',
  );
  String get liveFriends => _pick(
    en: 'Friends',
    fr: 'Amis',
    ar: 'الأصدقاء',
    sw: 'Marafiki',
    zh: '好友',
  );
  String get liveFollow =>
      _pick(en: 'Follow', fr: 'Suivre', ar: 'متابعة', sw: 'Fuata', zh: '关注');
  String get liveFollowBack => _pick(
    en: 'Follow back',
    fr: 'Suivre en retour',
    ar: 'متابعة بالمقابل',
    sw: 'Fuata pia',
    zh: '回关',
  );
  String get liveYou =>
      _pick(en: 'You', fr: 'Vous', ar: 'أنت', sw: 'Wewe', zh: '你');
  String get liveOpenFullProfile => _pick(
    en: 'Open full profile',
    fr: 'Ouvrir le profil complet',
    ar: 'فتح الملف الكامل',
    sw: 'Fungua wasifu kamili',
    zh: '打开完整资料',
  );
  String get liveProfileKeepsRoom => _pick(
    en: 'Opens separately so your Live room and camera stay connected.',
    fr: 'S’ouvre séparément afin de garder le Live et la caméra connectés.',
    ar: 'يفتح بشكل منفصل ليبقى البث والكاميرا متصلين.',
    sw: 'Hufunguka kando ili Live na kamera viendelee kuunganishwa.',
    zh: '将单独打开，以保持直播间和摄像头连接。',
  );
  String get liveGuestViewer => _pick(
    en: 'Guest viewer',
    fr: 'Spectateur invité',
    ar: 'مشاهد ضيف',
    sw: 'Mtazamaji mgeni',
    zh: '访客观众',
  );
  String get liveViewProfile => _pick(
    en: 'View profile',
    fr: 'Voir le profil',
    ar: 'عرض الملف',
    sw: 'Tazama wasifu',
    zh: '查看资料',
  );
  String get liveCohostLabel => _pick(
    en: 'Co-host',
    fr: 'Co-hôte',
    ar: 'مضيف مشارك',
    sw: 'Mwenyeji mwenza',
    zh: '共同主持',
  );
  String get liveNoViewers => _pick(
    en: 'No viewers are connected right now.',
    fr: 'Aucun spectateur n’est connecté pour le moment.',
    ar: 'لا يوجد مشاهدون متصلون الآن.',
    sw: 'Hakuna watazamaji waliounganishwa sasa.',
    zh: '目前没有观众连接。',
  );
  String get liveReply =>
      _pick(en: 'Reply', fr: 'Répondre', ar: 'رد', sw: 'Jibu', zh: '回复');
  String liveReplyingTo(String name) => _pick(
    en: 'Replying to $name',
    fr: 'Réponse à $name',
    ar: 'ردًا على $name',
    sw: 'Unamjibu $name',
    zh: '回复 $name',
  );
  String get liveDeleteComment =>
      _pick(en: 'Delete', fr: 'Supprimer', ar: 'حذف', sw: 'Futa', zh: '删除');
  String get liveDeleteCommentConfirm => _pick(
    en: 'Delete this comment and its replies?',
    fr: 'Supprimer ce commentaire et ses réponses ?',
    ar: 'حذف هذا التعليق وردوده؟',
    sw: 'Futa maoni haya na majibu yake?',
    zh: '删除此评论及其回复？',
  );
  String get liveCancel =>
      _pick(en: 'Cancel', fr: 'Annuler', ar: 'إلغاء', sw: 'Ghairi', zh: '取消');
  String get liveCommentHint => _pick(
    en: 'Comment live...',
    fr: 'Commenter le Live…',
    ar: 'اكتب تعليقًا...',
    sw: 'Toa maoni...',
    zh: '发表评论…',
  );
  String get liveReplyHint => _pick(
    en: 'Write a reply...',
    fr: 'Écrire une réponse…',
    ar: 'اكتب ردًا...',
    sw: 'Andika jibu...',
    zh: '写回复…',
  );
  String get liveEndedTitle => _pick(
    en: 'Live ended',
    fr: 'Live terminé',
    ar: 'انتهى البث',
    sw: 'Live imeisha',
    zh: '直播已结束',
  );
  String get liveEndedOwnerMessage => _pick(
    en: 'Your live has ended successfully.',
    fr: 'Votre Live s’est terminé avec succès.',
    ar: 'انتهى بثك بنجاح.',
    sw: 'Live yako imekamilika vizuri.',
    zh: '你的直播已成功结束。',
  );
  String get livePeak =>
      _pick(en: 'PEAK', fr: 'PIC', ar: 'الذروة', sw: 'KILELE', zh: '峰值');
  String get liveViewersMetric => _pick(
    en: 'VIEWERS',
    fr: 'SPECTATEURS',
    ar: 'المشاهدون',
    sw: 'WATAZAMAJI',
    zh: '观众',
  );
  String get liveReactionsMetric => _pick(
    en: 'REACTIONS',
    fr: 'RÉACTIONS',
    ar: 'التفاعلات',
    sw: 'MIITIKIO',
    zh: '互动',
  );
  String get liveDone =>
      _pick(en: 'Done', fr: 'Terminé', ar: 'تم', sw: 'Imekamilika', zh: '完成');
  String get liveClose =>
      _pick(en: 'Close', fr: 'Fermer', ar: 'إغلاق', sw: 'Funga', zh: '关闭');
  String get liveTryAgain => _pick(
    en: 'Try again',
    fr: 'Réessayer',
    ar: 'حاول مجددًا',
    sw: 'Jaribu tena',
    zh: '重试',
  );
  String get liveProfileActionFailed => _pick(
    en: 'Could not update this relationship.',
    fr: 'Impossible de mettre à jour cette relation.',
    ar: 'تعذر تحديث هذه العلاقة.',
    sw: 'Imeshindikana kusasisha uhusiano huu.',
    zh: '无法更新此关系。',
  );
}
