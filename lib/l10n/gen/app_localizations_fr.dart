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
  String get watchThisLiveOnAos => 'Regardez ce direct sur AOS';

  @override
  String get unableToOpenShareOptions =>
      'Impossible d’ouvrir les options de partage.';
}
