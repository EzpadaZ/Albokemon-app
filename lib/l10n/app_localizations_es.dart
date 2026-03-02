// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get titleLobby => 'Lobby';

  @override
  String get login_play => '> JUGAR';

  @override
  String get login_settings => '> AJUSTES';

  @override
  String get login_footer => 'Bienvenido a Albokémon\nProyecto para la prueba técnica de\nSr. Software Engineer en Albo\n\n2026 Flutter + Socket.IO';

  @override
  String get login_logo_desc => 'Hecho por J. Espadas (2026)';

  @override
  String get login_server_con => '¡Conectando al servidor!';

  @override
  String get login_auth_con => '¡Creando usuario!';

  @override
  String get login_textfield_hint => 'Ingresa un nombre de usuario';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_volume => 'Volumen';

  @override
  String get settings_server_address => 'Dirección del servidor';

  @override
  String get settings_title => 'AJUSTES';

  @override
  String get lobby_title => 'Usuarios';

  @override
  String get lobby_invite_message => '¡%p quiere pelear!';

  @override
  String get lobby_invite_accept => 'ACEPTAR';

  @override
  String get lobby_invite_reject => 'RECHAZAR';

  @override
  String get lobby_battle_button => 'BATALLA';

  @override
  String get lobby_online_tag => 'En línea: %p (incluyéndote)';

  @override
  String get battle_pokemon_tag => 'POKÉMON:';

  @override
  String get battle_pokemon_hp => 'P.V:';

  @override
  String get battle_lives_left => 'RESTANTES:';

  @override
  String get battle_current_turn => 'TURNO ACTUAL:';

  @override
  String get battle_current_turn_self => 'TÚ';

  @override
  String get battle_current_turn_opp => 'OPONENTE';

  @override
  String get battle_attack => 'ATACAR';

  @override
  String get battle_waiting => 'ESPERANDO';

  @override
  String get battle_exit => 'Regresar';

  @override
  String get battle_logs => 'Eventos';

  @override
  String get battle_logs_attack => '¡%p atacó a %a e hizo %n de daño!';

  @override
  String get battle_logs_faint => '¡%p se debilitó!';

  @override
  String get battle_logs_new_entry => '¡%p entra a la batalla!';

  @override
  String get battle_logs_win => '¡Ganaste!, derrotaste a %p';

  @override
  String get battle_logs_defeat => '¡Perdiste!, %p te derrotó';
}
