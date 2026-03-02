// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get titleLobby => 'Lobby';

  @override
  String get login_play => '> PLAY';

  @override
  String get login_settings => '> SETTINGS';

  @override
  String get login_footer => 'Welcome to Albokémon\nProject for the technical test for\na Sr. Software Engineer at Albo\n\n2026 Flutter + Socket.IO';

  @override
  String get login_logo_desc => 'Made by J. Espadas (2026)';

  @override
  String get login_server_con => 'Connecting to server!';

  @override
  String get login_auth_con => 'Creating user!';

  @override
  String get login_textfield_hint => 'Provide a username';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_volume => 'Volume';

  @override
  String get settings_server_address => 'Server address';

  @override
  String get settings_title => 'SETTINGS';

  @override
  String get lobby_title => 'Users';

  @override
  String get lobby_invite_message => '%p wants to battle!';

  @override
  String get lobby_invite_accept => 'ACCEPT';

  @override
  String get lobby_invite_reject => 'DECLINE';

  @override
  String get lobby_battle_button => 'BATTLE';

  @override
  String get lobby_online_tag => 'Online: %p (including self)';

  @override
  String get battle_pokemon_tag => 'POKEMON:';

  @override
  String get battle_pokemon_hp => 'HEALTH:';

  @override
  String get battle_lives_left => 'POKEMON LEFT:';

  @override
  String get battle_current_turn => 'CURRENT TURN:';

  @override
  String get battle_current_turn_self => 'YOU';

  @override
  String get battle_current_turn_opp => 'OPPONENT';

  @override
  String get battle_attack => 'ATTACK';

  @override
  String get battle_waiting => 'WAITING';

  @override
  String get battle_exit => 'Return to Lobby';

  @override
  String get battle_logs => 'Events';

  @override
  String get battle_logs_attack => '%p attacked %a and dealt %n damage!';

  @override
  String get battle_logs_faint => '%p fainted!';

  @override
  String get battle_logs_new_entry => '%p enters the battle!';

  @override
  String get battle_logs_win => 'You win!, you defeated %p';

  @override
  String get battle_logs_defeat => 'You lost!, %p defeated you!';
}
