import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @titleLobby.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get titleLobby;

  /// No description provided for @login_play.
  ///
  /// In en, this message translates to:
  /// **'> PLAY'**
  String get login_play;

  /// No description provided for @login_settings.
  ///
  /// In en, this message translates to:
  /// **'> SETTINGS'**
  String get login_settings;

  /// No description provided for @login_footer.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Albokémon\nProject for the technical test for\na Sr. Software Engineer at Albo\n\n2026 Flutter + Socket.IO'**
  String get login_footer;

  /// No description provided for @login_logo_desc.
  ///
  /// In en, this message translates to:
  /// **'Made by J. Espadas (2026)'**
  String get login_logo_desc;

  /// No description provided for @login_server_con.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server!'**
  String get login_server_con;

  /// No description provided for @login_auth_con.
  ///
  /// In en, this message translates to:
  /// **'Creating user!'**
  String get login_auth_con;

  /// No description provided for @login_textfield_hint.
  ///
  /// In en, this message translates to:
  /// **'Provide a username'**
  String get login_textfield_hint;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settings_volume;

  /// No description provided for @settings_server_address.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get settings_server_address;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings_title;

  /// No description provided for @lobby_title.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get lobby_title;

  /// No description provided for @lobby_invite_message.
  ///
  /// In en, this message translates to:
  /// **'%p wants to battle!'**
  String get lobby_invite_message;

  /// No description provided for @lobby_invite_accept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get lobby_invite_accept;

  /// No description provided for @lobby_invite_reject.
  ///
  /// In en, this message translates to:
  /// **'DECLINE'**
  String get lobby_invite_reject;

  /// No description provided for @lobby_battle_button.
  ///
  /// In en, this message translates to:
  /// **'BATTLE'**
  String get lobby_battle_button;

  /// No description provided for @lobby_online_tag.
  ///
  /// In en, this message translates to:
  /// **'Online: %p (including self)'**
  String get lobby_online_tag;

  /// No description provided for @battle_pokemon_tag.
  ///
  /// In en, this message translates to:
  /// **'POKEMON:'**
  String get battle_pokemon_tag;

  /// No description provided for @battle_pokemon_hp.
  ///
  /// In en, this message translates to:
  /// **'HEALTH:'**
  String get battle_pokemon_hp;

  /// No description provided for @battle_lives_left.
  ///
  /// In en, this message translates to:
  /// **'POKEMON LEFT:'**
  String get battle_lives_left;

  /// No description provided for @battle_current_turn.
  ///
  /// In en, this message translates to:
  /// **'CURRENT TURN:'**
  String get battle_current_turn;

  /// No description provided for @battle_current_turn_self.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get battle_current_turn_self;

  /// No description provided for @battle_current_turn_opp.
  ///
  /// In en, this message translates to:
  /// **'OPPONENT'**
  String get battle_current_turn_opp;

  /// No description provided for @battle_attack.
  ///
  /// In en, this message translates to:
  /// **'ATTACK'**
  String get battle_attack;

  /// No description provided for @battle_waiting.
  ///
  /// In en, this message translates to:
  /// **'WAITING'**
  String get battle_waiting;

  /// No description provided for @battle_exit.
  ///
  /// In en, this message translates to:
  /// **'Return to Lobby'**
  String get battle_exit;

  /// No description provided for @battle_logs.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get battle_logs;

  /// No description provided for @battle_logs_attack.
  ///
  /// In en, this message translates to:
  /// **'%p attacked %a and dealt %n damage!'**
  String get battle_logs_attack;

  /// No description provided for @battle_logs_faint.
  ///
  /// In en, this message translates to:
  /// **'%p fainted!'**
  String get battle_logs_faint;

  /// No description provided for @battle_logs_new_entry.
  ///
  /// In en, this message translates to:
  /// **'%p enters the battle!'**
  String get battle_logs_new_entry;

  /// No description provided for @battle_logs_win.
  ///
  /// In en, this message translates to:
  /// **'You win!, you defeated %p'**
  String get battle_logs_win;

  /// No description provided for @battle_logs_defeat.
  ///
  /// In en, this message translates to:
  /// **'You lost!, %p defeated you!'**
  String get battle_logs_defeat;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
