// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get onboarding_language_title => 'Choisissez votre langue';

  @override
  String get onboarding_language_subtitle =>
      'L’application s’affichera dans la langue sélectionnée';

  @override
  String get onboarding_language_placeholder => 'Sélectionnez votre langue';

  @override
  String get onboarding_language_picker => 'Sélectionner la langue';

  @override
  String get onboarding_use_current_location => 'Utiliser la position actuelle';

  @override
  String get onboarding_use_country_currency => 'Utiliser la devise du pays';

  @override
  String get onboarding_loading_title => 'Chargement des options';

  @override
  String get onboarding_loading_message =>
      'Nous chargeons vos options de configuration. Vous pouvez réessayer ou ignorer pour le moment.';

  @override
  String get onboarding_offline_title => 'Pas de connexion Internet';

  @override
  String get onboarding_offline_message =>
      'Impossible de charger ces options. Réessayez une fois connecté, ou ignorez pour le moment sans enregistrer de valeurs inventées.';

  @override
  String get common_try_again => 'Réessayer';

  @override
  String get common_no_languages => 'Aucune langue disponible';

  @override
  String get common_no_countries => 'Aucun pays disponible';

  @override
  String get common_search => 'Rechercher';

  @override
  String get common_no_results => 'Aucune option correspondante';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_discard_changes_title => 'Annuler les modifications ?';

  @override
  String get common_discard_changes_message =>
      'Des modifications ne sont pas enregistrées. Voulez-vous les annuler ?';

  @override
  String get common_keep_editing => 'Continuer la modification';

  @override
  String get common_discard => 'Annuler';

  @override
  String get common_selection_required =>
      'Sélectionnez une option valide pour continuer.';

  @override
  String get onboarding_currency_title => 'Choisissez votre devise';

  @override
  String get onboarding_currency_subtitle =>
      'Les prix seront affichés dans la devise sélectionnée';

  @override
  String get onboarding_currency_placeholder => 'Sélectionnez votre devise';

  @override
  String get onboarding_currency_picker => 'Sélectionner la devise';

  @override
  String get onboarding_country_title => 'Définissez votre pays';

  @override
  String get onboarding_country_subtitle =>
      'Nous vous montrerons des produits et vendeurs proches de vous';

  @override
  String get onboarding_country_placeholder => 'Sélectionnez votre pays';

  @override
  String get onboarding_country_picker => 'Sélectionner le pays';

  @override
  String get common_continue => 'Continuer';

  @override
  String get common_skip_for_now => 'Ignorer pour le moment';

  @override
  String get common_get_started => 'Commencer';

  @override
  String get common_no_currencies => 'Aucune devise disponible';

  @override
  String get auth_register_title => 'Créer un compte';

  @override
  String get auth_register_subtitle =>
      'Entrez vos informations pour créer votre compte';

  @override
  String get auth_full_name => 'Nom complet';

  @override
  String get auth_email_address => 'Adresse e-mail';

  @override
  String get auth_password => 'Mot de passe';

  @override
  String get auth_confirm_password => 'Confirmer le mot de passe';

  @override
  String get auth_accept_terms_error =>
      'Veuillez accepter les Conditions et la Politique de confidentialité';

  @override
  String get auth_terms_and_conditions => 'Conditions générales';

  @override
  String get auth_privacy_policy => 'Politique de confidentialité';

  @override
  String get auth_agree_prefix => 'J\'accepte ';

  @override
  String get auth_and => ' et ';

  @override
  String get auth_register_button => 'S\'inscrire';

  @override
  String auth_unexpected_error(Object error) {
    return 'Erreur inattendue : $error';
  }

  @override
  String get auth_already_have_account => 'Vous avez déjà un compte ? ';

  @override
  String get auth_login => 'Connexion';

  @override
  String get auth_login_title => 'Bonjour, bon retour';

  @override
  String get auth_login_subtitle => 'Connectez-vous à votre compte';

  @override
  String get auth_remember_me => 'Se souvenir de moi';

  @override
  String get auth_forgot_password => 'Mot de passe oublié ?';

  @override
  String get auth_login_button => 'Connexion';

  @override
  String get auth_no_account => 'Vous n\'avez pas de compte ?';

  @override
  String get auth_register => 'S\'inscrire';

  @override
  String get auth_continue_google => 'Continuer avec Google';

  @override
  String get auth_or => 'ou';

  @override
  String get auth_send_otp => 'Envoyer OTP';

  @override
  String get auth_mail_reset_password =>
      'Entrez votre adresse e-mail pour réinitialiser votre mot de passe';

  @override
  String get auth_password_updated_title =>
      'Mot de passe mis à jour\navec succès';

  @override
  String get auth_password_updated_message =>
      'Votre mot de passe a été mis à jour avec succès';

  @override
  String get auth_password_updated_button => 'Aller à la connexion';

  @override
  String get auth_email_verification_title => 'Vérification de l\'email';

  @override
  String get auth_enter_verification_code => 'Entrez le code de vérification';

  @override
  String get auth_verification_code_sent_to => 'Nous avons envoyé le code à';

  @override
  String get auth_email_verified_title => 'Email vérifié\navec succès';

  @override
  String get auth_email_verified_message =>
      'Votre email a été vérifié avec succès';

  @override
  String get auth_email_verified_button => 'Aller à la connexion';

  @override
  String get auth_digit_code => 'Entrez le code à 6 chiffres';

  @override
  String get auth_resend_code => 'Vous n\'avez pas reçu le code ? ';

  @override
  String get auth_resend => 'Renvoyer';

  @override
  String get auth_resend_in => 'Renvoyer dans ';

  @override
  String get nav_home => 'Accueil';

  @override
  String get nav_categories => 'Catégories';

  @override
  String get nav_selling => 'Vendre';

  @override
  String get nav_contact => 'Contact';

  @override
  String get nav_account => 'Compte';

  @override
  String get common_see_all => 'Voir tout';

  @override
  String get home_flash_sales => 'Ventes flash AOS';

  @override
  String get home_services_near_you => 'Services près de vous';

  @override
  String get home_new_products => 'Nouveaux produits AOS';

  @override
  String get home_electronic_deals => 'Offres électroniques AOS';

  @override
  String get home_deals => 'Offres AOS';

  @override
  String get home_furniture => 'Meubles';

  @override
  String get home_electronics => 'Électronique';

  @override
  String get home_fashion => 'Mode';

  @override
  String get home_babies_kids => 'Bébés et enfants';

  @override
  String get home_beauty => 'Beauté';

  @override
  String get home_photography_tips => 'Conseils de photographie';

  @override
  String get home_boost_marketing_reach => 'Augmentez votre portée marketing';

  @override
  String get home_ranking_tips =>
      'Essayez les meilleurs conseils de classement';

  @override
  String get home_learn => 'Apprendre';

  @override
  String get home_top_deals => 'Meilleures offres';

  @override
  String get home_best_prices => 'Meilleurs prix';

  @override
  String get home_shop_now => 'Acheter maintenant';

  @override
  String get home_you_might_be_looking_for => 'Vous pourriez chercher';

  @override
  String get ads_no_more_ads => 'Plus d\'annonces';

  @override
  String get location_all_locations => 'Tous les emplacements';

  @override
  String get search_placeholder => 'Rechercher ici...';

  @override
  String get search_button => 'Rechercher';

  @override
  String get ads_my_listings => 'Mes annonces';

  @override
  String get ads_no_listings_yet => 'Aucune annonce pour le moment';

  @override
  String get ads_no_listings_message =>
      'Vous n\'avez encore publié aucune annonce.';

  @override
  String get ads_start_selling_message =>
      'Commencez à vendre en créant votre première annonce';

  @override
  String get ads_post_first_ad => 'Publiez votre première annonce';

  @override
  String get ads_learn_sell_faster => 'Apprenez à vendre plus rapidement';

  @override
  String get ads_create_ad => 'Créer une annonce';

  @override
  String get ads_update_ad => 'Mettre à jour l\'annonce';

  @override
  String get account_title => 'Compte';

  @override
  String get account_get_verified => 'Se faire vérifier';

  @override
  String get account_boost_trust => 'Augmentez la confiance et la crédibilité';

  @override
  String get account_settings => 'Paramètres du compte';

  @override
  String get account_passwords_security => 'Mots de passe et sécurité';

  @override
  String get account_notifications_preferences =>
      'Préférences de notifications';

  @override
  String get account_guest_title => 'Bienvenue sur AOS';

  @override
  String get account_guest_description =>
      'Connectez-vous pour accéder à votre compte, gérer vos annonces et plus encore';

  @override
  String get app_preferences => 'Préférences de l\'application';

  @override
  String get settings_dark_mode => 'Mode sombre';

  @override
  String get common_other => 'Autre';

  @override
  String get common_discover_more => 'Découvrir plus';

  @override
  String get settings_privacy_policy => 'Politique de confidentialité';

  @override
  String get settings_preferences => 'Préférences';

  @override
  String get settings_manage_app => 'Gérer le fonctionnement de l\'application';

  @override
  String get settings_language => 'Langue';

  @override
  String get settings_language_description =>
      'Contrôle la façon dont le texte apparaît dans l\'application.';

  @override
  String get settings_country => 'Pays';

  @override
  String get settings_country_description =>
      'Détermine les annonces proches et où vos annonces apparaissent.';

  @override
  String get settings_seller_country_locked_description =>
      'Le pays est verrouillé pour les comptes vendeurs afin de protéger les données de la place de marché.';

  @override
  String get settings_seller_country_locked =>
      'Le pays ne peut pas être modifié pour un compte vendeur.';

  @override
  String get common_locked => 'Verrouillé';

  @override
  String get settings_preference_updated => 'Préférence mise à jour.';

  @override
  String get settings_currency => 'Devise';

  @override
  String get settings_currency_description =>
      'Utilisé pour les prix lors de la consultation et de la publication des annonces.';

  @override
  String get settings_terms_conditions => 'Conditions générales';

  @override
  String get onboarding_preference_error =>
      'Impossible d’enregistrer votre préférence. Veuillez réessayer.';

  @override
  String get session_restore_offline_title => 'Vous êtes hors connexion';

  @override
  String get session_restore_offline_message =>
      'AOS n’a pas pu vérifier votre session existante. Reconnectez-vous puis réessayez. Votre session enregistrée n’a pas été supprimée.';

  @override
  String get session_restore_unavailable_title =>
      'Impossible de restaurer votre session';

  @override
  String get session_restore_unavailable_message =>
      'AOS ne peut pas vérifier votre session existante pour le moment. Réessayez. Votre session enregistrée n’a pas été supprimée.';

  @override
  String get privacy_cover_accessibility_label =>
      'AOS protège les informations de votre compte.';

  @override
  String get appLockScreenAccessibilityLabel => 'AOS est verrouillé';

  @override
  String get appLockTitle => 'Déverrouiller AOS';

  @override
  String get appLockPrompt => 'Saisissez le verrouillage pour continuer.';

  @override
  String get appLockUnlock => 'Déverrouiller';

  @override
  String get appLockAuthenticating => 'Authentification…';

  @override
  String get appLockLogout => 'Se déconnecter';

  @override
  String get appLockForgottenCredentialHelp =>
      'Réinitialisez le verrouillage pour vous déconnecter et supprimer un identifiant local oublié.';

  @override
  String get appLockUnlockReason => 'Authentifiez-vous pour déverrouiller AOS.';

  @override
  String get appLockEnableReason =>
      'Authentifiez-vous pour activer le verrou biométrique.';

  @override
  String get appLockDisableReason =>
      'Authentifiez-vous pour désactiver le verrouillage.';

  @override
  String get appLockCancelled =>
      'Authentification annulée. Votre session reste ouverte.';

  @override
  String get appLockTemporaryLockout =>
      'Trop de tentatives. Réessayez plus tard ou réinitialisez le verrouillage.';

  @override
  String get appLockPermanentLockout =>
      'La biométrie est verrouillée. Utilisez la récupération de l’appareil ou réinitialisez le verrouillage.';

  @override
  String get appLockNoDeviceCredential =>
      'Configurez d’abord une empreinte, Face ID ou une autre biométrie dans les réglages de l’appareil.';

  @override
  String get appLockUnsupported =>
      'L’authentification native est indisponible sur cet appareil.';

  @override
  String get appLockTryAgain => 'Réessayer';

  @override
  String get appLockFailed => 'Échec de l’authentification. Réessayez.';

  @override
  String get appLockSettingTitle => 'Verrouillage de l’application';

  @override
  String get appLockSettingDescription =>
      'Protégez les zones privées avec un PIN à 4 chiffres, un schéma ou la biométrie.';

  @override
  String get appLockTimingTitle => 'Délai de verrouillage';

  @override
  String get appLockTimingImmediately => 'Immédiatement';

  @override
  String get appLockTimingThirtySeconds => 'Après 30 secondes';

  @override
  String get appLockTimingOneMinute => 'Après 1 minute';

  @override
  String get appLockTimingFiveMinutes => 'Après 5 minutes';

  @override
  String get wishlist_add => 'Ajouter à la liste de souhaits';

  @override
  String get wishlist_remove => 'Retirer de la liste de souhaits';

  @override
  String get wishlist_update_error =>
      'Impossible de mettre à jour votre liste de souhaits. Réessayez.';

  @override
  String get appLockBiometricPrompt =>
      'Utilisez votre empreinte, votre visage ou une autre biométrie enregistrée pour continuer.';

  @override
  String get appLockUseBiometrics => 'Utiliser la biométrie';

  @override
  String get appLockReset => 'Réinitialiser le verrouillage';

  @override
  String get appLockResetHelp =>
      'PIN ou schéma oublié ? La réinitialisation vous déconnecte et supprime le verrou local.';

  @override
  String get appLockResetTitle => 'Réinitialiser le verrouillage ?';

  @override
  String get appLockResetMessage =>
      'Vous serez déconnecté, le verrou enregistré sera supprimé et l’application publique s’ouvrira. Reconnectez-vous pour créer un nouveau verrou.';

  @override
  String get appLockResetConfirm => 'Réinitialiser et se déconnecter';

  @override
  String get appLockCancel => 'Annuler';

  @override
  String get appLockClear => 'Effacer';

  @override
  String get appLockEnterPin => 'Saisissez votre PIN à 4 chiffres';

  @override
  String get appLockEnterPattern => 'Dessinez votre schéma';

  @override
  String get appLockInvalidCredential => 'Ce verrou est incorrect. Réessayez.';

  @override
  String get appLockPinHelp => 'Utilisez exactement 4 chiffres.';

  @override
  String get appLockPatternHelp => 'Reliez au moins 4 points.';

  @override
  String get appLockConfirmPin => 'Confirmez votre PIN';

  @override
  String get appLockConfirmPattern => 'Confirmez votre schéma';

  @override
  String get appLockConfirmationMismatch =>
      'La confirmation ne correspond pas. Réessayez.';

  @override
  String get appLockContinue => 'Continuer';

  @override
  String get appLockConfirm => 'Confirmer';

  @override
  String get appLockStorageFailure =>
      'Les paramètres du verrouillage n’ont pas pu être enregistrés de façon sécurisée. Réessayez.';

  @override
  String get appLockConfigured => 'Le verrouillage est activé';

  @override
  String get appLockProcessRestartNote =>
      'AOS se verrouille toujours après l’arrêt ou le redémarrage de l’application.';

  @override
  String get appLockChangeMethod => 'Changer la méthode';

  @override
  String get appLockDisable => 'Désactiver le verrouillage';

  @override
  String get appLockChooseMethod => 'Choisissez une méthode';

  @override
  String get appLockMethodHelp =>
      'Le PIN et le schéma ne sont stockés que sous forme de hachages salés sécurisés. Les données biométriques restent gérées par l’appareil.';

  @override
  String get appLockMethodPin => 'PIN à 4 chiffres';

  @override
  String get appLockMethodPattern => 'Schéma';

  @override
  String get appLockMethodBiometric => 'Empreinte ou biométrie';

  @override
  String get appLockChangeReason =>
      'Authentifiez-vous pour modifier le verrouillage.';

  @override
  String get appLockTimingFiveSeconds => 'Après 5 secondes';

  @override
  String get appLockTimingTenSeconds => 'Après 10 secondes';

  @override
  String get appLockTimingFifteenSeconds => 'Après 15 secondes';

  @override
  String get appLockPinInputAccessibility => 'Saisie du PIN';

  @override
  String get appLockPatternInputAccessibility => 'Saisie du schéma';

  @override
  String get appLockPatternPointAccessibility => 'Point du schéma';

  @override
  String get ads_location_select_title => 'Sélectionner un lieu';

  @override
  String ads_location_results_more(Object count) {
    return 'Plus de $count lieux trouvés';
  }

  @override
  String ads_location_results_exact(Object count) {
    return '$count lieux trouvés';
  }

  @override
  String get ad_media_download_image => 'Télécharger l’image';

  @override
  String get ad_media_saved_to_gallery => 'Image enregistrée dans la galerie.';

  @override
  String get liveLikeAction => 'Aimer le direct';

  @override
  String get liveShareAction => 'Partager le direct';

  @override
  String get liveMuteAction => 'Couper le microphone';

  @override
  String get liveUnmuteAction => 'Activer le microphone';

  @override
  String get liveFlipCameraAction => 'Changer de caméra';

  @override
  String get liveGoLiveAction => 'PASSER EN DIRECT';

  @override
  String get liveStartingAction => 'Démarrage...';

  @override
  String get liveDetailsTitle => 'Détails du direct';

  @override
  String get liveEditDetailsAction => 'Modifier les détails du direct';

  @override
  String get liveEditDetailsHint =>
      'Touchez pour modifier le titre ou la couverture';

  @override
  String get liveCoverLabel => 'Photo de couverture';

  @override
  String get liveChangeCoverAction => 'Changer la couverture';

  @override
  String get liveChooseCoverFromGallery => 'Choisir dans la galerie';

  @override
  String get liveTakeCoverPhoto => 'Prendre une photo';

  @override
  String get liveTitleLabel => 'Titre du direct';

  @override
  String get liveTitleHint => 'Ajoutez un titre au direct';

  @override
  String get liveTitleRequired => 'Ajoutez un titre au direct pour continuer.';

  @override
  String get liveCoverRequired =>
      'Ajoutez une photo de couverture pour continuer.';

  @override
  String get liveUploadingCover => 'Importation de la couverture...';

  @override
  String get liveCameraStarting => 'Démarrage de la caméra...';

  @override
  String get liveCameraUnavailable => 'Aperçu de la caméra indisponible';

  @override
  String get liveCameraStartError =>
      'Impossible de démarrer l’aperçu de la caméra.';

  @override
  String get liveNoAlternateCameraError =>
      'Aucune autre caméra n’est disponible.';

  @override
  String get liveCameraFlipError => 'Impossible de changer de caméra.';

  @override
  String get liveCoverUploadError =>
      'Impossible d’importer la couverture du direct.';

  @override
  String get liveCoverSelectionError =>
      'Impossible de sélectionner une couverture pour le direct.';

  @override
  String get watchThisLiveOnAos => 'Regardez ce direct sur AOS';

  @override
  String get unableToOpenShareOptions =>
      'Impossible d’ouvrir les options de partage.';

  @override
  String get chat_connect_title => 'AOS Connect';

  @override
  String get chat_close_connect => 'Fermer Connect';

  @override
  String get chat_close_search => 'Fermer la recherche';

  @override
  String get chat_search => 'Rechercher';

  @override
  String get chat_more_options => 'Plus d’options';

  @override
  String get chat_search_chats_hint => 'Rechercher des discussions…';

  @override
  String get chat_search_calls_hint => 'Rechercher des appels…';

  @override
  String get chat_all_marked_read =>
      'Toutes les discussions ont été marquées comme lues.';

  @override
  String get chat_some_mark_read_failed =>
      'Certaines discussions n’ont pas pu être marquées comme lues.';

  @override
  String get chat_clear_call_log_title => 'Effacer le journal des appels ?';

  @override
  String get chat_clear_call_log_body =>
      'Cela supprime votre historique d’appels visible. Les données des autres utilisateurs ne sont pas supprimées.';

  @override
  String get chat_cancel => 'Annuler';

  @override
  String get chat_clear => 'Effacer';

  @override
  String get chat_call_log_cleared => 'Journal des appels effacé.';

  @override
  String get chat_call_log_clear_failed =>
      'Impossible d’effacer le journal des appels.';

  @override
  String get chat_clear_call_log => 'Effacer le journal des appels';

  @override
  String get chat_settings => 'Paramètres';

  @override
  String get chat_mark_all_read => 'Tout marquer comme lu';

  @override
  String get chat_starred_messages => 'Messages favoris';

  @override
  String get chat_chats => 'Discussions';

  @override
  String get chat_new_conversation => 'Nouvelle discussion';

  @override
  String get chat_new => 'Nouveau';

  @override
  String get chat_calls => 'Appels';

  @override
  String get chat_back => 'Retour';

  @override
  String get chat_call => 'Appeler';

  @override
  String get chat_video_call => 'Appel vidéo';

  @override
  String get chat_change_wallpaper => 'Changer le fond d’écran';

  @override
  String get chat_user_might_be_offline =>
      'L’utilisateur est peut-être hors ligne';

  @override
  String get chat_failed_to_start_call => 'Impossible de démarrer l’appel';

  @override
  String get chat_gallery => 'Galerie';

  @override
  String get chat_camera => 'Caméra';

  @override
  String get chat_voice_call => 'Appel vocal';

  @override
  String get chat_location => 'Localisation';

  @override
  String get chat_document => 'Document';

  @override
  String get chat_contact => 'Contact';

  @override
  String get chat_attachment_upload_failed =>
      'Échec de l’envoi de la pièce jointe. Réessayez.';

  @override
  String get chat_message_hint => 'Message';

  @override
  String get chat_share_location_title => 'Partager la localisation';

  @override
  String get chat_retry => 'Réessayer';

  @override
  String get chat_could_not_load_messages =>
      'Impossible de charger les messages';

  @override
  String get chat_check_connection_try_again =>
      'Vérifiez votre connexion et réessayez.';

  @override
  String get chat_no_messages_yet => 'Aucun message';

  @override
  String get chat_no_messages_hint =>
      'Envoyez un message pour commencer cette discussion.';

  @override
  String get chat_older_messages_load_failed =>
      'Impossible de charger les anciens messages.';

  @override
  String get chat_reply => 'Répondre';

  @override
  String get chat_edit => 'Modifier';

  @override
  String get chat_copy => 'Copier';

  @override
  String get chat_forward => 'Transférer';

  @override
  String get chat_translate_again => 'Retraduire';

  @override
  String get chat_translate => 'Traduire';

  @override
  String get chat_unstar => 'Retirer des favoris';

  @override
  String get chat_star => 'Ajouter aux favoris';

  @override
  String get chat_delete_for_me => 'Supprimer pour moi';

  @override
  String get chat_delete_for_everyone => 'Supprimer pour tout le monde';

  @override
  String get chat_message_reactions => 'Réactions au message';

  @override
  String get chat_choose_another_reaction => 'Choisir une autre réaction';

  @override
  String chat_react_with(Object emoji) {
    return 'Réagir avec $emoji';
  }

  @override
  String chat_remove_reaction(Object emoji) {
    return 'Retirer la réaction $emoji';
  }

  @override
  String get chat_editing_message => 'Modification du message';

  @override
  String get chat_cancel_editing => 'Annuler la modification';

  @override
  String get chat_copied_to_clipboard => 'Copié dans le presse-papiers';

  @override
  String get chat_message_still_failed =>
      'Le message n’a toujours pas été envoyé. Réessayez.';

  @override
  String get chat_send_ad_failed =>
      'Impossible d’envoyer le message de l’annonce. Réessayez.';

  @override
  String get chat_send_failed => 'Impossible d’envoyer le message. Réessayez.';

  @override
  String get chat_star_update_failed =>
      'Impossible de mettre à jour le favori.';

  @override
  String get chat_reaction_update_failed =>
      'Impossible de mettre à jour la réaction.';

  @override
  String get chat_forward_failed => 'Impossible de transférer le message.';

  @override
  String get chat_forwarded => 'Message transféré.';

  @override
  String chat_forwarded_to_chats(Object count) {
    return 'Message transféré vers $count discussions.';
  }

  @override
  String get chat_translate_failed => 'Impossible de traduire le message.';

  @override
  String get chat_delete_failed => 'Impossible de supprimer le message.';

  @override
  String get chat_deleted_for_everyone =>
      'Message supprimé pour tout le monde.';

  @override
  String get chat_deleted_for_you => 'Message supprimé pour vous.';

  @override
  String get chat_edit_failed => 'Impossible de modifier le message.';

  @override
  String get chat_settings_title => 'Paramètres de discussion';

  @override
  String get chat_privacy => 'Confidentialité';

  @override
  String get chat_read_receipts => 'Confirmations de lecture';

  @override
  String get chat_read_receipts_managed =>
      'Gérées par AOS pour la remise des messages';

  @override
  String get chat_last_seen_online => 'Dernière connexion et en ligne';

  @override
  String get chat_no_backend_preference =>
      'Aucune préférence de compte n’est exposée par le serveur';

  @override
  String get chat_blocked_contacts => 'Contacts bloqués';

  @override
  String get chat_chats_section => 'Discussions';

  @override
  String get chat_wallpaper => 'Fond d’écran des discussions';

  @override
  String get chat_wallpaper_description =>
      'Définir le fond d’écran par défaut des discussions';

  @override
  String get chat_enter_is_send => 'Entrée pour envoyer';

  @override
  String get chat_enter_is_send_description =>
      'La touche Entrée envoie votre message';

  @override
  String get chat_media_auto_download =>
      'Téléchargement automatique des médias';

  @override
  String get chat_unavailable_backend =>
      'Non disponible dans le contrat serveur actuel';

  @override
  String get chat_notifications => 'Notifications';

  @override
  String get chat_message_notifications => 'Notifications de messages';

  @override
  String get chat_call_notifications => 'Notifications d’appels';

  @override
  String get chat_system_notification_settings =>
      'Contrôlées par les paramètres de notification du système';

  @override
  String get chat_on => 'Activé';

  @override
  String get chat_off => 'Désactivé';

  @override
  String get chat_starred_load_failed =>
      'Impossible de charger les messages favoris';

  @override
  String get chat_no_starred_messages => 'Aucun message favori';

  @override
  String get chat_no_starred_messages_hint =>
      'Les messages ajoutés aux favoris apparaîtront ici.';

  @override
  String get chat_unstar_message => 'Retirer le message des favoris';

  @override
  String get chat_unstar_failed =>
      'Impossible de retirer le message des favoris.';

  @override
  String get chat_message_unstarred => 'Message retiré des favoris.';

  @override
  String get chat_attachment => 'Pièce jointe';

  @override
  String get chat_you => 'Vous';

  @override
  String get chat_other_user => 'Autre utilisateur';

  @override
  String get chat_aos_user => 'Utilisateur AOS';

  @override
  String get chat_sending => 'Envoi…';

  @override
  String get chat_edited => 'Modifié';

  @override
  String get chat_starred => 'Favori';

  @override
  String get chat_translated => 'Traduit';

  @override
  String get chat_failed_to_send => 'Échec de l’envoi';

  @override
  String get chat_read => 'Lu';

  @override
  String get chat_delivered => 'Remis';

  @override
  String get chat_sent => 'Envoyé';

  @override
  String get chat_forwarded_label => 'Transféré';

  @override
  String get chat_deleted_message => 'Ce message a été supprimé';

  @override
  String get chat_translating => 'Traduction…';

  @override
  String get chat_tap_to_retry => 'Appuyer pour réessayer';

  @override
  String get chat_translate_to => 'Traduire vers';

  @override
  String chat_translate_to_language(Object language) {
    return 'Traduire vers $language';
  }

  @override
  String get chat_voice_release_cancel => 'Relâchez pour annuler';

  @override
  String get chat_voice_recording_locked => 'Enregistrement verrouillé';

  @override
  String get chat_voice_slide_cancel => 'Glissez vers la gauche pour annuler';

  @override
  String chat_voice_recording_status(Object duration, Object instruction) {
    return 'Enregistrement vocal $duration. $instruction';
  }

  @override
  String chat_starred_message_from(Object sender) {
    return 'Message favori de $sender';
  }

  @override
  String get chat_verified_sellers => 'Vendeurs vérifiés';

  @override
  String get chat_friends => 'Amis';

  @override
  String get chat_search_sellers_hint => 'Rechercher des vendeurs…';

  @override
  String get chat_search_friends_hint => 'Rechercher des amis…';

  @override
  String get chat_loading_sellers => 'Chargement des vendeurs';

  @override
  String get chat_loading_sellers_hint =>
      'Veuillez patienter pendant la recherche de vendeurs vérifiés.';

  @override
  String get chat_could_not_load_sellers =>
      'Impossible de charger les vendeurs';

  @override
  String get chat_no_verified_sellers => 'Aucun vendeur vérifié';

  @override
  String get chat_no_sellers_found => 'Aucun vendeur trouvé';

  @override
  String get chat_no_verified_sellers_hint =>
      'Les vendeurs vérifiés apparaîtront ici lorsqu’ils seront disponibles.';

  @override
  String get chat_no_sellers_found_hint =>
      'Essayez un autre nom, une autre catégorie ou un autre lieu.';

  @override
  String get chat_refresh => 'Actualiser';

  @override
  String get chat_loading_friends => 'Chargement des amis';

  @override
  String get chat_loading_friends_hint =>
      'Veuillez patienter pendant la recherche de vos amis.';

  @override
  String get chat_could_not_load_friends => 'Impossible de charger les amis';

  @override
  String get chat_try_again => 'Veuillez réessayer.';

  @override
  String get chat_no_friends_yet => 'Aucun ami pour le moment';

  @override
  String get chat_no_friends_found => 'Aucun ami trouvé';

  @override
  String get chat_no_friends_yet_hint =>
      'Vos amis apparaîtront ici lorsque vous vous suivrez mutuellement.';

  @override
  String get chat_no_friends_found_hint =>
      'Essayez un autre nom ou une autre adresse e-mail.';

  @override
  String get chat_online => 'En ligne';

  @override
  String get chat_last_seen_recently => 'Vu récemment';

  @override
  String get chat_friend => 'Ami';

  @override
  String get chat_message_contact => 'Message';

  @override
  String get chat_call_contact => 'Appeler';

  @override
  String get chat_all_chats => 'Toutes les discussions';

  @override
  String get chat_unread => 'Non lues';

  @override
  String get chat_loading_conversations => 'Chargement des discussions';

  @override
  String get chat_loading_conversations_hint =>
      'Veuillez patienter pendant le chargement de vos discussions.';

  @override
  String get chat_could_not_load_chats =>
      'Impossible de charger les discussions';

  @override
  String get chat_no_chats_found => 'Aucune discussion trouvée';

  @override
  String get chat_no_chats_search_hint =>
      'Essayez un autre nom ou un autre message.';

  @override
  String get chat_no_read_chats => 'Aucune discussion lue';

  @override
  String get chat_no_unread_chats => 'Aucune discussion non lue';

  @override
  String get chat_no_conversations_yet => 'Aucune discussion pour le moment';

  @override
  String get chat_no_read_chats_hint =>
      'Les discussions déjà lues apparaîtront ici.';

  @override
  String get chat_no_unread_chats_hint =>
      'Les discussions non lues apparaîtront ici à l’arrivée de nouveaux messages.';

  @override
  String get chat_no_conversations_hint =>
      'Vos discussions apparaîtront ici lorsque vous commencerez à échanger.';

  @override
  String get chat_deleted_from_list => 'Discussion supprimée de votre liste.';

  @override
  String get chat_delete_chat_failed =>
      'Impossible de supprimer la discussion. Réessayez.';

  @override
  String get chat_typing => 'Écrit…';

  @override
  String chat_last_seen_time(Object time) {
    return 'Vu à $time';
  }

  @override
  String get chat_forward_to_title => 'Transférer à';

  @override
  String get chat_close => 'Fermer';

  @override
  String get chat_search_conversations_hint => 'Rechercher des conversations';

  @override
  String get chat_clear_search => 'Effacer la recherche';

  @override
  String get chat_could_not_load_conversations =>
      'Impossible de charger les conversations';

  @override
  String get chat_no_other_conversations => 'Aucune autre conversation';

  @override
  String get chat_no_other_conversations_hint =>
      'Démarrez d’abord une autre discussion pour pouvoir y transférer des messages.';

  @override
  String get chat_no_conversations_found => 'Aucune conversation trouvée';

  @override
  String get chat_search_conversations_empty_hint =>
      'Essayez un autre nom ou message.';

  @override
  String get chat_forward_to_one_chat => 'Transférer à 1 discussion';

  @override
  String chat_forward_to_chats_count(Object count) {
    return 'Transférer à $count discussions';
  }

  @override
  String get chat_default_wallpaper_applied =>
      'Fond d’écran par défaut appliqué.';

  @override
  String get chat_wallpaper_updated => 'Fond d’écran mis à jour.';

  @override
  String chat_named_wallpaper_applied(Object name) {
    return 'Fond d’écran $name appliqué.';
  }

  @override
  String get chat_choose_conversation_background =>
      'Choisissez un arrière-plan pour cette conversation';

  @override
  String get chat_default => 'Par défaut';

  @override
  String get chat_choose_from_gallery => 'Choisir dans la galerie';

  @override
  String get chat_solid_colors => 'Couleurs unies';

  @override
  String get chat_emoji_recent => 'Récents';

  @override
  String get chat_emoji_smileys => 'Visages';

  @override
  String get chat_emoji_animals => 'Animaux';

  @override
  String get chat_emoji_food => 'Nourriture';

  @override
  String get chat_emoji_flags => 'Drapeaux';

  @override
  String get chat_search_emoji => 'Rechercher un emoji';

  @override
  String get chat_no_emoji_found => 'Aucun emoji trouvé';

  @override
  String get chat_share_contact => 'Partager un contact';

  @override
  String get chat_search_aos_users => 'Rechercher des utilisateurs AOS';

  @override
  String get chat_could_not_load_contacts =>
      'Impossible de charger les contacts';

  @override
  String get chat_search_people_on_aos => 'Rechercher des personnes sur AOS';

  @override
  String get chat_search_people_hint =>
      'Saisissez au moins 2 caractères pour trouver un contact à partager.';

  @override
  String get chat_no_contacts_found => 'Aucun contact trouvé';

  @override
  String get chat_no_contacts_found_hint =>
      'Essayez un autre nom, nom d’utilisateur ou e-mail.';

  @override
  String get chat_unmute => 'Réactiver le son';

  @override
  String get chat_mute => 'Couper le son';

  @override
  String get chat_end_call => 'Terminer l’appel';

  @override
  String get chat_calling => 'Appel en cours';

  @override
  String get chat_ringing => 'Sonnerie';

  @override
  String get chat_incoming_call => 'Appel entrant';

  @override
  String get chat_connecting => 'Connexion';

  @override
  String get chat_delete_chat_title => 'Supprimer la discussion ?';

  @override
  String chat_delete_chat_description(Object name) {
    return 'Cela retirera votre discussion avec $name de votre liste. Elle ne sera pas supprimée pour l’autre utilisateur.';
  }

  @override
  String get chat_this_user => 'cet utilisateur';

  @override
  String get chat_delete => 'Supprimer';

  @override
  String get chat_view_profile => 'Voir le profil';

  @override
  String get chat_view_contact => 'Voir le contact';

  @override
  String get chat_cannot_open_document =>
      'Impossible d’ouvrir ce type de document';

  @override
  String get chat_failed_to_start_chat =>
      'Impossible de démarrer la discussion. Réessayez.';

  @override
  String get chat_invalid_conversation_response =>
      'Réponse de conversation invalide';

  @override
  String get chat_voice_hold_to_record =>
      'Maintenez pour enregistrer un message vocal';

  @override
  String get chat_voice_tap_to_record =>
      'Appuyez pour enregistrer un message vocal';

  @override
  String get chat_voice_pause => 'Mettre l’enregistrement en pause';

  @override
  String get chat_voice_resume => 'Reprendre l’enregistrement';

  @override
  String get chat_voice_delete_recording => 'Supprimer l’enregistrement';

  @override
  String get chat_voice_send_recording => 'Envoyer le message vocal';

  @override
  String get chat_voice_release_to_finish =>
      'Relâchez pour terminer l’enregistrement vocal';

  @override
  String get chat_microphone_permission_denied =>
      'Autorisation du microphone refusée.';

  @override
  String get chat_voice_record_start_failed =>
      'Impossible de démarrer l’enregistrement vocal.';

  @override
  String get chat_voice_record_finish_failed =>
      'Impossible de terminer l’enregistrement vocal.';

  @override
  String get chat_language_english => 'Anglais';

  @override
  String get chat_language_swahili => 'Swahili';

  @override
  String get chat_language_french => 'Français';

  @override
  String get chat_language_spanish => 'Espagnol';

  @override
  String get chat_language_german => 'Allemand';

  @override
  String get chat_language_portuguese => 'Portugais';

  @override
  String get chat_language_arabic => 'Arabe';

  @override
  String get chat_language_hausa => 'Haoussa';

  @override
  String get chat_language_yoruba => 'Yoruba';

  @override
  String get chat_language_igbo => 'Igbo';

  @override
  String get chat_language_amharic => 'Amharique';

  @override
  String get chat_language_somali => 'Somali';

  @override
  String get chat_language_kinyarwanda => 'Kinyarwanda';

  @override
  String get chat_language_luganda => 'Luganda';

  @override
  String get chat_language_zulu => 'Zoulou';

  @override
  String get chat_language_xhosa => 'Xhosa';

  @override
  String get chat_wallpaper_midnight => 'Minuit';

  @override
  String get chat_wallpaper_navy => 'Bleu marine';

  @override
  String get chat_wallpaper_forest => 'Forêt';

  @override
  String get chat_wallpaper_plum => 'Prune';

  @override
  String get chat_wallpaper_charcoal => 'Anthracite';

  @override
  String get chat_wallpaper_maroon => 'Bordeaux';

  @override
  String get chat_wallpaper_teal => 'Sarcelle';

  @override
  String get chat_wallpaper_coffee => 'Café';

  @override
  String get chat_audio_call => 'Appel audio';

  @override
  String get chat_clear_chat => 'Effacer la discussion';

  @override
  String get chat_audio => 'Audio';

  @override
  String get chat_view_replied_message => 'Voir le message cité';

  @override
  String get chat_replied_message_unavailable =>
      'Le message cité n’est plus disponible.';

  @override
  String get chat_clear_chat_title => 'Effacer la discussion ?';

  @override
  String get chat_clear_chats_title => 'Effacer les discussions ?';

  @override
  String get chat_clear_chat_description =>
      'Cette action efface tous les messages visibles de cette discussion uniquement pour vous. L’autre participant conservera sa copie.';

  @override
  String chat_clear_selected_chats_description(Object count) {
    return 'Effacer les messages visibles de $count discussions sélectionnées uniquement pour vous ? Les autres participants conserveront leurs copies.';
  }

  @override
  String get chat_chat_cleared => 'Discussion effacée.';

  @override
  String get chat_clear_chat_failed => 'Impossible d’effacer la discussion.';

  @override
  String get chat_select_conversations => 'Sélectionner des discussions';

  @override
  String chat_selected_conversations(Object count) {
    return '$count sélectionnées';
  }

  @override
  String get chat_cancel_selection => 'Annuler la sélection';

  @override
  String get chat_mark_as_read => 'Marquer comme lu';

  @override
  String get chat_clear_chats => 'Effacer les discussions';

  @override
  String get chat_delete_conversations => 'Supprimer la discussion';

  @override
  String get chat_delete_conversations_title => 'Supprimer les discussions ?';

  @override
  String chat_delete_selected_conversations_description(Object count) {
    return 'Cette action retirera $count discussions sélectionnées de votre liste. Elles ne seront pas supprimées pour les autres participants.';
  }

  @override
  String chat_selected_marked_read(Object count) {
    return '$count discussions sélectionnées marquées comme lues.';
  }

  @override
  String chat_selected_chats_cleared(Object count) {
    return '$count discussions sélectionnées effacées.';
  }

  @override
  String chat_selected_chats_deleted(Object count) {
    return '$count discussions sélectionnées supprimées.';
  }

  @override
  String get chat_selected_action_partial_failure =>
      'Certaines discussions sélectionnées n’ont pas pu être mises à jour.';

  @override
  String get profilePhotoRemoveAction => 'Supprimer la photo';

  @override
  String get profilePhotoRemoved => 'Photo de profil supprimée.';

  @override
  String get sellerBannerChangeAction => 'Modifier la bannière';

  @override
  String get sellerBannerRemoveAction => 'Supprimer la bannière';

  @override
  String get sellerBannerUpdated => 'Bannière de la boutique mise à jour.';

  @override
  String get sellerBannerRemoved => 'Bannière de la boutique supprimée.';

  @override
  String get chat_answer_call => 'Répondre';

  @override
  String get chat_decline_call => 'Refuser';

  @override
  String get chat_incoming_voice_call => 'Appel vocal entrant';

  @override
  String get chat_incoming_video_call => 'Appel vidéo entrant';

  @override
  String get chat_minimize_call => 'Réduire l’appel';

  @override
  String get chat_call_ended => 'Appel terminé';

  @override
  String get chat_call_cancelled => 'Appel annulé';

  @override
  String get chat_call_failed => 'Échec de l’appel';

  @override
  String get chat_waiting_for_video => 'En attente de la vidéo…';

  @override
  String get chat_waiting_for_connection => 'En attente de la connexion…';

  @override
  String get chat_camera_starting => 'Démarrage de la caméra…';

  @override
  String get chat_camera_off => 'Caméra désactivée';

  @override
  String get chat_switch_camera => 'Changer de caméra';

  @override
  String get chat_switch_to_video_call => 'Passer à un appel vidéo ?';

  @override
  String get chat_switch_to_video => 'Passer en vidéo';

  @override
  String get chat_video_upgrade_failed => 'Échec du passage à la vidéo';
}
