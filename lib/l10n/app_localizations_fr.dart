// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get app_share_dialog_text_1 => 'Partagez Snapdrop avec vos collègues';

  @override
  String get app_share_dialog_text_2 =>
      'Vous avez déjà partagé des images 3 fois. Parlez de Snapdrop autour de vous pour que vos collègues en profitent aussi !';

  @override
  String get app_share_dialog_share_now_button => 'Partager';

  @override
  String get app_share_dialog_maybe_later_button => 'Plus tard';

  @override
  String get app_share_text_1 =>
      '🚀 Découvrez Snapdrop - le moyen le plus simple d\'envoyer vos images directement dans vos maquettes Figma ! 🎨\n\n';

  @override
  String get app_share_text_2 =>
      '📲 Téléchargez-le et simplifiez votre flux de travail :\n\n';

  @override
  String get language_selection_herotext_1 => 'Choisissez votre';

  @override
  String get language_selection_herotext_2 => 'langue préférée';

  @override
  String get language_selection_continue => 'Continuer';

  @override
  String get onboard_hero_text_1 => 'Envoyez vos images';

  @override
  String get onboard_hero_text_2 => 'directement dans Figma';

  @override
  String get onboard_subline =>
      'Du téléphone au canevas, en quelques secondes.';

  @override
  String get onboard_step_1 =>
      'Choisissez jusqu\'à 10 images sur votre téléphone';

  @override
  String get onboard_step_2 => 'Scannez le QR code du plugin Figma';

  @override
  String get onboard_step_3 => 'Elles arrivent directement sur votre canevas';

  @override
  String get onboard_button_text => 'Commencer';

  @override
  String get onboarding_title => 'Envoyez vos photos directement dans Figma';

  @override
  String get onboarding_subtitle =>
      'Snapdrop envoie les images de votre téléphone vers votre canevas Figma — via le plugin sur ordinateur.';

  @override
  String get onboarding_step1_title =>
      'Ouvrez Snapdrop dans Figma sur votre ordinateur';

  @override
  String get onboarding_step1_desc =>
      'Le plugin affiche un QR code sur votre écran.';

  @override
  String get onboarding_step2_title =>
      'Choisissez vos photos, puis scannez ce QR code';

  @override
  String get onboarding_step2_desc =>
      'Pointez votre téléphone vers le code pour vous connecter.';

  @override
  String get onboarding_step3_title => 'Vos photos arrivent dans Figma';

  @override
  String get onboarding_step3_desc =>
      'Elles apparaissent sur votre canevas, prêtes à l\'emploi.';

  @override
  String get onboarding_note =>
      'Le QR code vient du plugin Figma sur ordinateur — pas de cette application, ni de Figma mobile.';

  @override
  String get onboarding_cta => 'Commencer';

  @override
  String get scan_subtitle => 'Visez le code affiché par votre plugin Figma';

  @override
  String get scan_help_link => 'Où est le QR code ?';

  @override
  String get qr_help_title => 'Où est le QR code ?';

  @override
  String get qr_help_step1 => 'Ouvrez Figma sur votre ordinateur.';

  @override
  String get qr_help_step2 =>
      'Lancez le plugin Snapdrop — Menu > Plugins, ou recherchez « Snapdrop ».';

  @override
  String get qr_help_step3 =>
      'Un QR code apparaît. Pointez votre téléphone dessus.';

  @override
  String get qr_help_note =>
      'Il faut Figma sur ordinateur. Le code est généré par le plugin, pas par cette application.';

  @override
  String get qr_help_dismiss => 'J\'ai compris';

  @override
  String get showcase_one_title => 'Menu déroulant';

  @override
  String get showcase_one_subtitle =>
      'Choisissez l\'album dans lequel piocher vos photos';

  @override
  String get showcase_two_title => 'Sélection des images';

  @override
  String get showcase_two_subtitle => 'Sélectionnez les images à partager';

  @override
  String get showcase_three_title => 'Bouton Connecter';

  @override
  String get showcase_three_subtitle => 'Passez à l\'étape suivante';

  @override
  String get home_screen_herotext_1 => 'Choisissez des images';

  @override
  String get home_screen_herotext_2 => 'pour continuer';

  @override
  String get home_screen_herotext_3 => 'Jusqu\'à 10 images';

  @override
  String get home_screen_button => 'Connecter';

  @override
  String get send_button => 'Envoyer';

  @override
  String get connection_connected => 'Connecté';

  @override
  String get connection_not_connected =>
      'Non connecté — scannez pour vous connecter';

  @override
  String get home_album_view_all => 'Tout voir';

  @override
  String get empty_state_title => 'Aucune image ici';

  @override
  String get empty_state_body =>
      'Les photos de cet album apparaîtront ici. Essayez un autre album ci-dessus.';

  @override
  String get empty_state_none_title => 'Aucune photo trouvée';

  @override
  String get empty_state_none_body =>
      'Ajoutez des photos à votre galerie — ou autorisez l\'accès aux photos — puis actualisez.';

  @override
  String get empty_state_refresh => 'Actualiser';

  @override
  String get album_search_hint => 'Rechercher un album';

  @override
  String get album_search_empty => 'Aucun album de ce nom';

  @override
  String get language_sheet_title => 'Choisir la langue';

  @override
  String get help_button => 'Aide';

  @override
  String size_limit_message(String limit, String size) {
    return 'Chaque image doit faire moins de $limit Mo (la plus lourde fait $size Mo).';
  }

  @override
  String get showcase_four_title => 'Scanner de QR code';

  @override
  String get showcase_four_subtitle => 'Touchez pour scanner le QR code';

  @override
  String get qr_screen_herotext_1 => 'Scannez le QR code';

  @override
  String get qr_screen_herotext_2 => 'pour continuer';

  @override
  String get qr_screen_herotext_3 => 'Scannez le QR code pour vous connecter';

  @override
  String get qr_timed_out_label => 'Délai dépassé';

  @override
  String get qr_timed_out_message =>
      'Aucun QR code scanné — il a peut-être expiré.';

  @override
  String get qr_invalid_label => 'Ce code n\'a pas fonctionné';

  @override
  String get qr_invalid_message =>
      'Ce n\'est pas un code Snapdrop. Scannez le QR affiché par le plugin Figma sur ordinateur.';

  @override
  String get qr_restart_scan => 'Relancer le scan';

  @override
  String get no_internet_connection => 'Pas de connexion Internet';

  @override
  String get connection_lost => 'Connexion perdue';

  @override
  String get connection_lost_body =>
      'La session s\'est interrompue. Reconnectez-vous pour continuer l\'envoi.';

  @override
  String get reconnect_button => 'Se reconnecter';

  @override
  String get qr_screen_info_button =>
      'Ouvrez Figma -> Fichier de design -> Plugin -> Snapdrop';

  @override
  String get qr_screen_button_scanning => 'Scan en cours...';

  @override
  String get qr_screen_button_scanning_completed => 'Connexion réussie';

  @override
  String get showcase_five_title => 'Bouton Fermer';

  @override
  String get showcase_five_subtitle => 'Quitter l\'application';

  @override
  String get showcase_six_title => 'Bouton Envoyer';

  @override
  String get showcase_six_subtitle => 'Envoyer d\'autres images';

  @override
  String get send_screen_hero_text_1 => 'Transférées';

  @override
  String get send_screen_hero_text_2 => 'images';

  @override
  String get send_screen_transferring => 'Transfert de';

  @override
  String get send_screen_complete_1 => 'Transfert';

  @override
  String get send_screen_complete_2 => 'terminé';

  @override
  String get send_screen_connected_to => 'CONNECTÉ À';

  @override
  String get send_screen_your_id => 'VOTRE ID';

  @override
  String get send_screen_connect_button => 'Toucher pour envoyer';

  @override
  String get send_screen_close_button => 'Fermer';

  @override
  String get send_screen_send_more_button => 'Envoyer';

  @override
  String get app_conditions_internet_connection =>
      'Vérifiez votre connexion Internet et réessayez !';

  @override
  String get app_conditions_image_selection_limit =>
      'Vous ne pouvez sélectionner que 10 images maximum !';

  @override
  String get app_conditions_size_limit => 'Taille de fichier dépassée';

  @override
  String get permission_dialog_title => 'Autoriser l\'accès aux photos';

  @override
  String get permission_dialog_body =>
      'Snapdrop a besoin de vos photos pour les envoyer vers Figma. Rien ne quitte votre téléphone tant que vous n\'avez pas choisi et envoyé.';

  @override
  String get permission_dialog_allow => 'Autoriser';

  @override
  String get permission_dialog_exit => 'Quitter';

  @override
  String get exit_dialog_title => 'Quitter Snapdrop ?';

  @override
  String get exit_dialog_body =>
      'Votre sélection actuelle ne sera pas conservée.';

  @override
  String get exit_dialog_exit => 'Quitter';

  @override
  String get exit_dialog_cancel => 'Annuler';

  @override
  String get share_dialog_title => 'Snapdrop vous plaît ?';

  @override
  String get share_dialog_body =>
      'S\'il vous a fait gagner du temps, le partager avec un autre designer aide plus qu\'on ne le croit.';

  @override
  String get share_dialog_share => 'Partager';

  @override
  String get share_dialog_maybe_later => 'Plus tard';
}
