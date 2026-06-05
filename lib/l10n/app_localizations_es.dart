// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Gestión del Hogar';

  @override
  String get userSettings => 'Ajustes de Usuario';

  @override
  String get csvDelimiter => 'Delimitador CSV';

  @override
  String get preferredCurrency => 'Moneda Preferida';

  @override
  String get backupFrequency => 'Frecuencia de Respaldo';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get appLanguage => 'Idioma de la Aplicación';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get dashboard => 'Panel de Control';

  @override
  String get accounts => 'Cuentas';

  @override
  String get mainAccounts => 'Cuentas Principales';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get settings => 'Ajustes';
}
