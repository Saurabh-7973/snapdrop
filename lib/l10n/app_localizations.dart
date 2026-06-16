import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('pt'),
    Locale('zh')
  ];

  /// No description provided for @app_share_dialog_text_1.
  ///
  /// In en, this message translates to:
  /// **'Share Snapdrop with Your Colleagues'**
  String get app_share_dialog_text_1;

  /// No description provided for @app_share_dialog_text_2.
  ///
  /// In en, this message translates to:
  /// **'You\'ve successfully shared images 3 times. Spread the word about Snapdrop so your colleagues can benefit too!'**
  String get app_share_dialog_text_2;

  /// No description provided for @app_share_dialog_share_now_button.
  ///
  /// In en, this message translates to:
  /// **'Share Now'**
  String get app_share_dialog_share_now_button;

  /// No description provided for @app_share_dialog_maybe_later_button.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get app_share_dialog_maybe_later_button;

  /// No description provided for @app_share_text_1.
  ///
  /// In en, this message translates to:
  /// **'🚀 Discover Snapdrop - the easiest way to transfer images directly to your Figma designs! 🎨\n\n'**
  String get app_share_text_1;

  /// No description provided for @app_share_text_2.
  ///
  /// In en, this message translates to:
  /// **'📲 Download now and streamline your design workflow:\n\n'**
  String get app_share_text_2;

  /// No description provided for @language_selection_herotext_1.
  ///
  /// In en, this message translates to:
  /// **'Select your'**
  String get language_selection_herotext_1;

  /// No description provided for @language_selection_herotext_2.
  ///
  /// In en, this message translates to:
  /// **'preferred language'**
  String get language_selection_herotext_2;

  /// No description provided for @language_selection_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get language_selection_continue;

  /// No description provided for @onboard_hero_text_1.
  ///
  /// In en, this message translates to:
  /// **'Share images'**
  String get onboard_hero_text_1;

  /// No description provided for @onboard_hero_text_2.
  ///
  /// In en, this message translates to:
  /// **'directly to Figma'**
  String get onboard_hero_text_2;

  /// No description provided for @onboard_step_1.
  ///
  /// In en, this message translates to:
  /// **'Select Images'**
  String get onboard_step_1;

  /// No description provided for @onboard_step_2.
  ///
  /// In en, this message translates to:
  /// **'Scan QR in Figma Plugin'**
  String get onboard_step_2;

  /// No description provided for @onboard_step_3.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get onboard_step_3;

  /// No description provided for @onboard_button_text.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboard_button_text;

  /// No description provided for @showcase_one_title.
  ///
  /// In en, this message translates to:
  /// **'Dropdown Button'**
  String get showcase_one_title;

  /// No description provided for @showcase_one_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select albums you want to choose photos from'**
  String get showcase_one_subtitle;

  /// No description provided for @showcase_two_title.
  ///
  /// In en, this message translates to:
  /// **'Select Images'**
  String get showcase_two_title;

  /// No description provided for @showcase_two_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select images you want to share'**
  String get showcase_two_subtitle;

  /// No description provided for @showcase_three_title.
  ///
  /// In en, this message translates to:
  /// **'Connect Button'**
  String get showcase_three_title;

  /// No description provided for @showcase_three_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Proceed to the next step'**
  String get showcase_three_subtitle;

  /// No description provided for @home_screen_herotext_1.
  ///
  /// In en, this message translates to:
  /// **'Select Images'**
  String get home_screen_herotext_1;

  /// No description provided for @home_screen_herotext_2.
  ///
  /// In en, this message translates to:
  /// **'to Continue'**
  String get home_screen_herotext_2;

  /// No description provided for @home_screen_herotext_3.
  ///
  /// In en, this message translates to:
  /// **'Up to 10 Images'**
  String get home_screen_herotext_3;

  /// No description provided for @home_screen_button.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get home_screen_button;

  /// No description provided for @showcase_four_title.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get showcase_four_title;

  /// No description provided for @showcase_four_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Click to Scan QR Code'**
  String get showcase_four_subtitle;

  /// No description provided for @qr_screen_herotext_1.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get qr_screen_herotext_1;

  /// No description provided for @qr_screen_herotext_2.
  ///
  /// In en, this message translates to:
  /// **'to Continue'**
  String get qr_screen_herotext_2;

  /// No description provided for @qr_screen_herotext_3.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to Connect'**
  String get qr_screen_herotext_3;

  /// No description provided for @qr_screen_info_button.
  ///
  /// In en, this message translates to:
  /// **'Open Figma -> Design File -> Plugin -> Snapdrop'**
  String get qr_screen_info_button;

  /// No description provided for @qr_screen_button_scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get qr_screen_button_scanning;

  /// No description provided for @qr_screen_button_scanning_completed.
  ///
  /// In en, this message translates to:
  /// **'Connected Successfully'**
  String get qr_screen_button_scanning_completed;

  /// No description provided for @showcase_five_title.
  ///
  /// In en, this message translates to:
  /// **'Close Button'**
  String get showcase_five_title;

  /// No description provided for @showcase_five_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Exit the Application'**
  String get showcase_five_subtitle;

  /// No description provided for @showcase_six_title.
  ///
  /// In en, this message translates to:
  /// **'Send Button'**
  String get showcase_six_title;

  /// No description provided for @showcase_six_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Send More Images'**
  String get showcase_six_subtitle;

  /// No description provided for @send_screen_hero_text_1.
  ///
  /// In en, this message translates to:
  /// **'Transferred'**
  String get send_screen_hero_text_1;

  /// No description provided for @send_screen_hero_text_2.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get send_screen_hero_text_2;

  /// No description provided for @send_screen_connected_to.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED TO'**
  String get send_screen_connected_to;

  /// No description provided for @send_screen_your_id.
  ///
  /// In en, this message translates to:
  /// **'YOUR ID'**
  String get send_screen_your_id;

  /// No description provided for @send_screen_connect_button.
  ///
  /// In en, this message translates to:
  /// **'Click to Send'**
  String get send_screen_connect_button;

  /// No description provided for @send_screen_close_button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get send_screen_close_button;

  /// No description provided for @send_screen_send_more_button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send_screen_send_more_button;

  /// No description provided for @app_conditions_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'Check your Internet Connection and try again!'**
  String get app_conditions_internet_connection;

  /// No description provided for @app_conditions_image_selection_limit.
  ///
  /// In en, this message translates to:
  /// **'Can Only select upto 10 Images!'**
  String get app_conditions_image_selection_limit;

  /// No description provided for @app_conditions_size_limit.
  ///
  /// In en, this message translates to:
  /// **'File Size Limit Exceded'**
  String get app_conditions_size_limit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'en',
        'es',
        'hi',
        'pt',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
