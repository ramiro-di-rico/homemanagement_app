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
  String get themeMode => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get appLanguage => 'Idioma de la Aplicación';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Portuguese';

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

  @override
  String get authenticationSettings => 'Ajustes de Autenticación';

  @override
  String get username => 'Nombre de Usuario';

  @override
  String get enableTwoFactorAuthentication =>
      'Habilitar Autenticación de Dos Factores';

  @override
  String get balance => 'Saldo';

  @override
  String get noBalanceInformation => 'No hay información de saldo disponible';

  @override
  String get overall => 'General';

  @override
  String get noTransactionsRecorded =>
      'No hay transacciones registradas todavía';

  @override
  String get count => 'Cantidad';

  @override
  String get total => 'Total';

  @override
  String get income => 'Ingresos';

  @override
  String get outcome => 'Egresos';

  @override
  String get expense => 'Gastos';

  @override
  String get noBalanceHistory => 'No hay historial de saldo disponible todavía';

  @override
  String get balanceHistory => 'Historial de Saldo';

  @override
  String get allCurrencies => 'Todas las Monedas';

  @override
  String get all => 'Todo';

  @override
  String get months => 'Meses';

  @override
  String removed(String name) {
    return '$name eliminado';
  }

  @override
  String failedToRemove(String name) {
    return 'Error al eliminar $name';
  }

  @override
  String get showMenu => 'Mostrar menú';

  @override
  String get editAccount => 'Editar Cuenta';

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get archive => 'Archivar';

  @override
  String get importTransactions => 'Importar Transacciones';

  @override
  String get noTransactionsFoundForAccount =>
      'No se encontraron transacciones para esta cuenta';

  @override
  String get filterByName => 'Filtrar por nombre';

  @override
  String get transactionsImportedSuccessfully =>
      'Transacciones importadas con éxito';

  @override
  String get failedToImportTransactions => 'Error al importar transacciones';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get dontHaveAccount => '¿Aún no tienes una cuenta?';

  @override
  String get createOne => 'Crea una';

  @override
  String get emailOrUsername => 'Correo o nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get addAccount => 'Añadir Cuenta';

  @override
  String get addTransaction => 'Añadir Transacción';

  @override
  String get dictateTransaction => 'Dictar transacción';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get microphonePermissionDenied =>
      'Se necesita permiso del micrófono para dictar';

  @override
  String get voicePreviewFailed =>
      'No se pudo entender el audio. Inténtalo de nuevo.';

  @override
  String voiceHeard(String text) {
    return 'Escuché: $text';
  }

  @override
  String get attachDocument => 'Adjuntar comprobante';

  @override
  String get documentPreviewFailed =>
      'No se pudieron leer los archivos seleccionados. Inténtalo de nuevo.';

  @override
  String documentsSkipped(int count) {
    return '$count archivo(s) no se pudieron leer';
  }

  @override
  String get selectDocumentPreview => 'Selecciona qué comprobante usar';

  @override
  String get delete => 'Eliminar';

  @override
  String get unassign => 'Desasignar';

  @override
  String addAccountTo(String name) {
    return 'Añadir Cuenta a $name';
  }

  @override
  String get noMoreAccountsAvailable =>
      'No hay más cuentas disponibles para añadir.';

  @override
  String get close => 'Cerrar';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String areYouSureDelete(String name) {
    return '¿Estás seguro de que quieres eliminar $name?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String deleted(String name) {
    return '$name eliminado';
  }

  @override
  String get budget => 'Presupuesto';

  @override
  String get searchTransactions => 'Buscar transacciones';

  @override
  String get bulkTransactions => 'Transacciones masivas';

  @override
  String get loggingView => 'Vista de Registros';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get name => 'Nombre';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get add => 'Añadir';

  @override
  String get edit => 'Editar';

  @override
  String get rejectSubmissions => 'Rechazar envíos';

  @override
  String get reject => 'Rechazar';

  @override
  String get invitationQr => 'QR de Invitación';

  @override
  String get invitations => 'Invitaciones';

  @override
  String get createInvitation => 'Crear invitación';

  @override
  String get invitationDescription =>
      'Una cuenta, una invitación. Los usuarios externos envían transacciones para su aprobación posterior.';

  @override
  String get clearDate => 'Limpiar fecha';

  @override
  String get noInvitationsYet => 'No hay invitaciones todavía.';

  @override
  String get sortAndFilter => 'Ordenar y filtrar';

  @override
  String get createdDate => 'Fecha de creación';

  @override
  String get expirationDate => 'Fecha de vencimiento';

  @override
  String get allInvites => 'Todas las invitaciones';

  @override
  String get hasExpiration => 'Tiene vencimiento';

  @override
  String get noExpiration => 'Sin vencimiento';

  @override
  String get allAccounts => 'Todas las cuentas';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get allStatuses => 'Todos los estados';

  @override
  String get invitation => 'Invitación';

  @override
  String get invitationUnavailable => 'Esta invitación no está disponible.';

  @override
  String categoryName(String name) {
    return 'Categoría: $name';
  }

  @override
  String statusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String expiresLabel(String date) {
    return 'Vence: $date';
  }

  @override
  String get submitTransaction => 'Enviar transacción';

  @override
  String get submitForApproval => 'Enviar para aprobación';

  @override
  String accountLabel(String name) {
    return 'Cuenta: $name';
  }

  @override
  String get exportTransactions => 'Exportar transacciones';

  @override
  String get downloadImportTemplate => 'Descargar plantilla de importación';

  @override
  String get templateDownloaded => 'Plantilla descargada';

  @override
  String get failedToDownloadTemplate => 'Error al descargar la plantilla';

  @override
  String get registration => 'Registro';

  @override
  String get authenticationError => 'Error de autenticación.';

  @override
  String get couldNotAuthenticateAfterRegistration =>
      'No se pudo autenticar al usuario después del registro.';

  @override
  String get showAllAccounts => 'Mostrar todas las cuentas';

  @override
  String get hideAccounts => 'Ocultar cuentas';

  @override
  String get searchAccounts => 'Buscar cuentas';

  @override
  String get searchCategories => 'Buscar categorías';

  @override
  String get developerMode => 'Modo Desarrollador';

  @override
  String get recurringTransactions => 'Transacciones Recurrentes';

  @override
  String get searchRecurringTransactions => 'Buscar transacciones recurrentes';

  @override
  String get addRecurringTransaction => 'Añadir transacción recurrente';

  @override
  String get noRecurringTransactionsFound =>
      'No se encontraron transacciones recurrentes';

  @override
  String get submitAll => 'Enviar todo';

  @override
  String get clearQueue => 'Limpiar cola';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get pleaseSelectAccount => 'Por favor selecciona una cuenta.';

  @override
  String get pleaseSelectCategory => 'Por favor selecciona una categoría.';

  @override
  String get nameMustBeAtLeast3Characters =>
      'El nombre debe tener al menos 3 caracteres.';

  @override
  String get enterValidPrice => 'Ingresa un precio válido.';

  @override
  String get addAtLeastOneTransactionBeforeSubmitting =>
      'Agrega al menos una transacción antes de enviar.';

  @override
  String transactionsSubmittedSuccessfully(Object count) {
    return '$count transacción(es) enviada(s) con éxito.';
  }

  @override
  String failedToSubmitTransactions(Object error) {
    return 'Error al enviar las transacciones: $error';
  }

  @override
  String get addToQueue => 'Agregar a la cola';

  @override
  String get noTransactionsQueuedYet =>
      'Todavía no hay transacciones en la cola.\nCompleta el formulario y presiona \"Agregar a la cola\".';

  @override
  String queuedTransactions(Object count) {
    return 'En cola ($count)';
  }

  @override
  String get remove => 'Quitar';

  @override
  String get transactionAccount => 'Cuenta';

  @override
  String get transactionCategory => 'Categoría';

  @override
  String get transactionDescription => 'Descripción';

  @override
  String get transactionAmount => 'Monto';

  @override
  String get transactionDate => 'Fecha';

  @override
  String get transactionType => 'Tipo';

  @override
  String get bulkTransactionsTitle => 'Transacciones masivas';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get showFilters => 'Mostrar filtros';

  @override
  String get hideFilters => 'Ocultar filtros';

  @override
  String get addBudget => 'Agregar presupuesto';

  @override
  String get budgetStateNew => 'Nuevo';

  @override
  String get budgetStateActive => 'Activo';

  @override
  String get budgetStateArchived => 'Archivado';

  @override
  String get budgetsListEmpty => 'La lista de presupuestos está vacía';

  @override
  String budgetTarget(Object amount) {
    return 'Objetivo del presupuesto: $amount';
  }

  @override
  String startDate(Object date) {
    return 'Inicio: $date';
  }

  @override
  String endDate(Object date) {
    return 'Fin: $date';
  }

  @override
  String get copy => 'Copiar';

  @override
  String get notAvailable => 'N/D';

  @override
  String get budgetName => 'Nombre';

  @override
  String get budgetAmount => 'Monto';

  @override
  String get budgetStartDate => 'Fecha de inicio';

  @override
  String get budgetEndDate => 'Fecha de fin';

  @override
  String get save => 'Guardar';

  @override
  String get spent => 'Gastado';

  @override
  String get budgeted => 'Presupuestado';

  @override
  String get remaining => 'Restante';

  @override
  String get categories => 'Categorías';

  @override
  String get noCategoriesDataAvailable =>
      'No hay datos de categorías disponibles';

  @override
  String get categoryHistoricalChart => 'Gráfico histórico de categorías';

  @override
  String lastMonths(Object count) {
    return 'Últimos $count meses';
  }

  @override
  String get noHistoricalCategoryDataAvailable =>
      'No hay datos históricos de categorías disponibles';

  @override
  String get dateFrom => 'Fecha desde';

  @override
  String get dateTo => 'Fecha hasta';

  @override
  String get itemsToTake => 'Cantidad de elementos';

  @override
  String get apply => 'Aplicar';

  @override
  String get pageSize => 'Tamaño de página';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get filterTransactions => 'Filtrar transacciones';

  @override
  String get selectFilterToDisplayTransactions =>
      'Selecciona un filtro para mostrar transacciones';

  @override
  String get searchTransactionByName => 'Buscar transacción por nombre';

  @override
  String get selectOption => 'Seleccionar';

  @override
  String get selectCurrency => 'Seleccionar moneda';

  @override
  String get selectAccount => 'Seleccionar cuenta';

  @override
  String get selectAccounts => 'Seleccionar cuentas';

  @override
  String get selectCategory => 'Seleccionar categoría';

  @override
  String get selectCategories => 'Seleccionar categorías';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get filter => 'Filtrar';

  @override
  String get clear => 'Limpiar';

  @override
  String get ok => 'Aceptar';

  @override
  String get unknownAccount => 'Cuenta desconocida';

  @override
  String get accountNotSet => 'Cuenta no establecida';

  @override
  String get categoryNotSet => 'Categoría no establecida';

  @override
  String get createTransaction => 'Crear Transacción';

  @override
  String get priceNotSet => 'Precio no establecido';

  @override
  String get annually => 'Anualmente';

  @override
  String get categoryComparisonChart => 'Comparación de Categorías';

  @override
  String get noCategoryComparisonDataAvailable =>
      'No hay datos de comparación de categorías disponibles';

  @override
  String get currentMonth => 'Mes actual';

  @override
  String get lastMonth => 'Mes anterior';

  @override
  String get referenceDate => 'Fecha de referencia';

  @override
  String get percentageChange => 'Cambio porcentual';

  @override
  String get transactionsSearchStatistics => 'Estadísticas de búsqueda';

  @override
  String get transactionCounts => 'Cantidad de transacciones';

  @override
  String get transactionTotals => 'Totales de transacciones';

  @override
  String get totalIncome => 'Ingresos totales';

  @override
  String get totalOutcome => 'Egresos totales';

  @override
  String get transactionsByCategory => 'Transacciones por categoría';

  @override
  String get transactionsByAccount => 'Transacciones por cuenta';

  @override
  String get noAccountsDataAvailable => 'No hay datos de cuentas disponibles';

  @override
  String get refresh => 'Actualizar';

  @override
  String get tags => 'Etiquetas';

  @override
  String get addTag => 'Añadir etiqueta';

  @override
  String get selectTag => 'Seleccionar etiqueta';

  @override
  String get selectTags => 'Seleccionar etiquetas';

  @override
  String get createNewTag => 'Crear nueva etiqueta';

  @override
  String get noTagsAvailable => 'Aún no hay etiquetas disponibles';

  @override
  String get noTags => 'Sin etiquetas';

  @override
  String get manageTransactionTags => 'Gestionar etiquetas de la transacción';

  @override
  String transactionTagsTitle(String name) {
    return 'Etiquetas: $name';
  }

  @override
  String get bulkTag => 'Etiquetado Masivo';

  @override
  String bulkTaggingTransactions(int count) {
    return 'Etiquetando $count transacciones';
  }

  @override
  String maxTagsReached(int max, int current) {
    return 'Puedes adjuntar hasta $max etiquetas ($current seleccionadas).';
  }

  @override
  String get transactionProjections => 'Proyección de gastos';

  @override
  String get noProjectionDataAvailable =>
      'No hay datos de proyección disponibles';

  @override
  String get projectedNextMonth => 'Próximo mes';

  @override
  String get projectedNext3Months => 'Próximos 3 meses';

  @override
  String get monthlyAverage => 'Promedio mensual';

  @override
  String basedOnLastMonths(int count) {
    return 'Basado en los últimos $count meses';
  }

  @override
  String get lookbackMonths => 'Meses hacia atrás';

  @override
  String get reconcileStatement => 'Conciliar extracto';

  @override
  String get reconciliationSelectFile => 'Elegir archivo del extracto';

  @override
  String get reconciliationNoStatementSelected =>
      'Elegí el archivo CSV que te da el banco para empezar';

  @override
  String get reconciliationPeriod => 'Período';

  @override
  String get reconciliationMatchedLabel => 'Conciliadas';

  @override
  String get reconciliationMissingLabel => 'Faltantes';

  @override
  String get reconciliationExtraLabel => 'No están en el extracto';

  @override
  String get reconciliationAmbiguousLabel => 'Ambiguas';

  @override
  String get reconciliationPossibleMatchesLabel => 'Posibles coincidencias';

  @override
  String get reconciliationPossibleMatchesHint =>
      'Movimientos que parecen ser del mismo comercio pero no coinciden del todo. Vinculá los que sean el mismo movimiento.';

  @override
  String reconciliationPossibleMatchDifference(String difference) {
    return '$difference de diferencia';
  }

  @override
  String reconciliationPossibleMatchDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días de diferencia',
      one: '1 día de diferencia',
      zero: 'mismo día',
    );
    return '$_temp0';
  }

  @override
  String get reconciliationLink => 'Vincular';

  @override
  String get reconciliationUnlink => 'Deshacer';

  @override
  String reconciliationLinkedRow(String name) {
    return 'Se vincula con $name — no se va a crear';
  }

  @override
  String reconciliationLinkedTransaction(String name) {
    return 'Se vincula con $name — no se va a eliminar';
  }

  @override
  String get reconciliationMatchedHint =>
      'Ya están en la app. No hay nada que hacer.';

  @override
  String get reconciliationMissingHint =>
      'Movimientos que el banco informa y no están en la app. Se van a crear los seleccionados.';

  @override
  String get reconciliationExtraHint =>
      'Transacciones de la app que el banco no informa. Se van a eliminar las seleccionadas.';

  @override
  String get reconciliationAmbiguousHint =>
      'Movimientos que podrían corresponder a más de una transacción. Resolvelos a mano desde la lista de transacciones.';

  @override
  String get reconciliationFullyReconciled =>
      'Este extracto está completamente conciliado';

  @override
  String get reconciliationConfirmDeleteTitle => '¿Eliminar transacciones?';

  @override
  String reconciliationConfirmDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se van a eliminar $count transacciones de forma permanente.',
      one: 'Se va a eliminar 1 transacción de forma permanente.',
    );
    return '$_temp0';
  }

  @override
  String reconciliationApplied(int created, int deleted) {
    return '$created creadas, $deleted eliminadas';
  }

  @override
  String get reconciliationBalanceMatches =>
      'El saldo de la cuenta coincide con el extracto';

  @override
  String reconciliationBalanceDifference(String difference) {
    return 'Diferencia contra el extracto: $difference';
  }

  @override
  String get reconciliationCategoryRequired =>
      'Elegí una categoría para cada movimiento a crear';

  @override
  String get reconciliationNothingSelected =>
      'No hay nada seleccionado para aplicar';

  @override
  String get failedToReadStatement => 'No se pudo leer el extracto';

  @override
  String get reconciliationNearPeriodEdge =>
      'Podría pertenecer a un extracto vecino — revisá antes de eliminar';

  @override
  String reconciliationBalanceMatchesAsOf(String date) {
    return 'El saldo de la cuenta al $date coincide con el extracto';
  }

  @override
  String reconciliationBalanceDifferenceAsOf(String date, String difference) {
    return 'Diferencia contra el extracto al $date: $difference';
  }

  @override
  String get savingsRate => 'Tasa de ahorro';

  @override
  String get savingsRateThisMonth => 'Este mes';

  @override
  String get savingsRateAverage => 'Promedio';

  @override
  String get savingsRateTotalIncome => 'Ingresos';

  @override
  String get savingsRateTotalExpense => 'Gastos';

  @override
  String get savingsRateTotalSaved => 'Ahorrado';

  @override
  String get noSavingsRateDataAvailable => 'No hay datos de tasa de ahorro';

  @override
  String get useWithoutAccount => 'Usar sin registrarme';

  @override
  String get localModeUnavailableTitle => 'Modo local no disponible';

  @override
  String get localModeKeyringUnavailable =>
      'El modo local necesita el almacén seguro de credenciales del sistema para guardar su clave de cifrado, pero no está disponible o está bloqueado. Desbloquéalo e inténtalo de nuevo.';

  @override
  String get localDataCannotBeOpened => 'No se pueden abrir tus datos locales';

  @override
  String get retry => 'Reintentar';

  @override
  String get accountHasTransactions =>
      'Esta cuenta tiene transacciones, por lo que no se puede eliminar. Elimina primero sus transacciones o archívala.';

  @override
  String get categoryInUse =>
      'Esta categoría se usa en transacciones, por lo que no se puede eliminar. Puedes desactivarla en su lugar.';

  @override
  String get deactivateCategory => 'Desactivar';

  @override
  String get categoryNameTaken => 'Ya existe una categoría con este nombre.';

  @override
  String get changeNotSaved =>
      'No se pudo guardar el cambio. No se modificó nada.';

  @override
  String get localModeBanner =>
      'Estás trabajando de forma local en este equipo';

  @override
  String get createOnlineAccount => 'Crear cuenta online';

  @override
  String get signInExistingAccount => 'Iniciar sesión en una cuenta existente';

  @override
  String get signInExistingAccountConfirm =>
      'Tus datos locales se quedarán en este equipo y no se moverán a esa cuenta. Elige \"Usar sin registrarme\" más tarde para volver a ellos.';

  @override
  String get useOnlineAccountInstead => 'Usar una cuenta online';

  @override
  String get startWithEmptyData => 'Empezar con datos vacíos';

  @override
  String get localDataKeyMissing =>
      'La clave que protege tus datos locales ya no existe, por ejemplo tras reinstalar el sistema, así que los datos no se pueden abrir. Tu archivo se conservó y no se borró nada.';

  @override
  String get localDataUnreadable =>
      'No se puede leer el archivo de datos locales. Se conservó y no se borró nada.';

  @override
  String get localDataFileMissing =>
      'No se encontró tu archivo de datos locales. Si lo moviste, vuelve a ponerlo y reintenta. Si no, puedes empezar de nuevo con datos vacíos.';

  @override
  String get localDataRetryFailed =>
      'Todavía no se pueden abrir tus datos locales.';

  @override
  String get localModeEmptyDescription =>
      'Tus datos se guardan cifrados solo en este equipo.';

  @override
  String get createFirstAccount => 'Crea tu primera cuenta';

  @override
  String get importTitle => 'Moviendo tus datos a tu cuenta online';

  @override
  String get importProgressCategories => 'Moviendo categorías';

  @override
  String get importProgressAccounts => 'Moviendo cuentas';

  @override
  String get importProgressTransactions => 'Moviendo transacciones';

  @override
  String get importVerifying => 'Comprobando saldos';

  @override
  String get importDone => 'Tus datos ya están en tu cuenta online.';

  @override
  String importBalanceMismatch(String account, String local, String server) {
    return 'El saldo de $account no coincide: $local aquí, $server online.';
  }

  @override
  String get importFailed =>
      'El traslado no terminó. Tus datos locales están intactos y no se perdió nada.';

  @override
  String get importResume => 'Terminar de mover tus datos locales';

  @override
  String importCurrencyMissing(String currencies) {
    return 'La cuenta online no ofrece estas monedas: $currencies. Todavía no se pueden mover tus datos.';
  }

  @override
  String get emailAlreadyRegistered =>
      'Este correo ya está registrado. Usa otro correo.';

  @override
  String importWrongUser(String email) {
    return 'El traslado se inició para $email. Inicia sesión con esa cuenta para terminarlo.';
  }

  @override
  String get importPendingReadOnly =>
      'Tus datos locales se están moviendo a tu cuenta online, así que no se pueden modificar hasta que termine.';

  @override
  String get localSwitchFailed =>
      'Tu cuenta se creó, pero la aplicación no pudo cambiar a ella todavía. Tus datos locales están intactos. Usa \"Iniciar sesión en una cuenta existente\" para continuar.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get importWaitingForServer =>
      'Esperando a que tu cuenta online esté lista';

  @override
  String get importServerNotReady =>
      'Tu cuenta online todavía no está lista. Tus datos locales están intactos, así que vuelve a intentarlo en un momento.';
}

/// The translations for Spanish Castilian, as used in Argentina (`es_AR`).
class AppLocalizationsEsAr extends AppLocalizationsEs {
  AppLocalizationsEsAr() : super('es_AR');

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

  @override
  String get authenticationSettings => 'Ajustes de Autenticación';

  @override
  String get username => 'Nombre de Usuario';

  @override
  String get enableTwoFactorAuthentication =>
      'Habilitar Autenticación de Dos Factores';

  @override
  String get balance => 'Saldo';

  @override
  String get noBalanceInformation => 'No hay información de saldo disponible';

  @override
  String get overall => 'General';

  @override
  String get noTransactionsRecorded =>
      'No hay transacciones registradas todavía';

  @override
  String get count => 'Cantidad';

  @override
  String get total => 'Total';

  @override
  String get income => 'Ingresos';

  @override
  String get outcome => 'Egresos';

  @override
  String get expense => 'Gastos';

  @override
  String get noBalanceHistory => 'No hay historial de saldo disponible todavía';

  @override
  String get balanceHistory => 'Historial de Saldo';

  @override
  String get allCurrencies => 'Todas las Monedas';

  @override
  String get all => 'Todo';

  @override
  String get months => 'Meses';

  @override
  String removed(String name) {
    return '$name eliminado';
  }

  @override
  String failedToRemove(String name) {
    return 'Error al eliminar $name';
  }

  @override
  String get showMenu => 'Mostrar menú';

  @override
  String get editAccount => 'Editar Cuenta';

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get archive => 'Archivar';

  @override
  String get importTransactions => 'Importar Transacciones';

  @override
  String get noTransactionsFoundForAccount =>
      'No se encontraron transacciones para esta cuenta';

  @override
  String get filterByName => 'Filtrar por nombre';

  @override
  String get transactionsImportedSuccessfully =>
      'Transacciones importadas con éxito';

  @override
  String get failedToImportTransactions => 'Error al importar transacciones';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get dontHaveAccount => '¿Todavía no tenés una cuenta?';

  @override
  String get createOne => 'Creá una';

  @override
  String get emailOrUsername => 'Correo o nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get addAccount => 'Agregar Cuenta';

  @override
  String get addTransaction => 'Agregar Transacción';

  @override
  String get dictateTransaction => 'Dictar transacción';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get microphonePermissionDenied =>
      'Se necesita permiso del micrófono para dictar';

  @override
  String get voicePreviewFailed =>
      'No se pudo entender el audio. Probá de nuevo.';

  @override
  String voiceHeard(String text) {
    return 'Escuché: $text';
  }

  @override
  String get attachDocument => 'Adjuntar comprobante';

  @override
  String get documentPreviewFailed =>
      'No se pudieron leer los archivos seleccionados. Probá de nuevo.';

  @override
  String documentsSkipped(int count) {
    return '$count archivo(s) no se pudieron leer';
  }

  @override
  String get selectDocumentPreview => 'Seleccioná qué comprobante usar';

  @override
  String get delete => 'Eliminar';

  @override
  String get unassign => 'Desasignar';

  @override
  String addAccountTo(String name) {
    return 'Agregar Cuenta a $name';
  }

  @override
  String get noMoreAccountsAvailable =>
      'No hay más cuentas disponibles para agregar.';

  @override
  String get close => 'Cerrar';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String areYouSureDelete(String name) {
    return '¿Estás seguro de que querés eliminar $name?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String deleted(String name) {
    return '$name eliminado';
  }

  @override
  String get budget => 'Presupuesto';

  @override
  String get searchTransactions => 'Buscar transacciones';

  @override
  String get bulkTransactions => 'Transacciones masivas';

  @override
  String get loggingView => 'Vista de Registros';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get name => 'Nombre';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get add => 'Agregar';

  @override
  String get edit => 'Editar';

  @override
  String get rejectSubmissions => 'Rechazar envíos';

  @override
  String get reject => 'Rechazar';

  @override
  String get invitationQr => 'QR de Invitación';

  @override
  String get invitations => 'Invitaciones';

  @override
  String get createInvitation => 'Crear invitación';

  @override
  String get invitationDescription =>
      'Una cuenta, una invitación. Los usuarios externos envían transacciones para su aprobación posterior.';

  @override
  String get clearDate => 'Limpiar fecha';

  @override
  String get noInvitationsYet => 'No hay invitaciones todavía.';

  @override
  String get sortAndFilter => 'Ordenar y filtrar';

  @override
  String get createdDate => 'Fecha de creación';

  @override
  String get expirationDate => 'Fecha de vencimiento';

  @override
  String get allInvites => 'Todas las invitaciones';

  @override
  String get hasExpiration => 'Tiene vencimiento';

  @override
  String get noExpiration => 'Sin vencimiento';

  @override
  String get allAccounts => 'Todas las cuentas';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get allStatuses => 'Todos los estados';

  @override
  String get invitation => 'Invitación';

  @override
  String get invitationUnavailable => 'Esta invitación no está disponible.';

  @override
  String categoryName(String name) {
    return 'Categoría: $name';
  }

  @override
  String statusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String expiresLabel(String date) {
    return 'Vence: $date';
  }

  @override
  String get submitTransaction => 'Enviar transacción';

  @override
  String get submitForApproval => 'Enviar para aprobación';

  @override
  String accountLabel(String name) {
    return 'Cuenta: $name';
  }

  @override
  String get exportTransactions => 'Exportar transacciones';

  @override
  String get downloadImportTemplate => 'Descargar plantilla de importación';

  @override
  String get templateDownloaded => 'Plantilla descargada';

  @override
  String get failedToDownloadTemplate => 'Error al descargar la plantilla';

  @override
  String get registration => 'Registro';

  @override
  String get authenticationError => 'Error de autenticación.';

  @override
  String get couldNotAuthenticateAfterRegistration =>
      'No se pudo autenticar al usuario después del registro.';

  @override
  String get showAllAccounts => 'Mostrar todas las cuentas';

  @override
  String get hideAccounts => 'Ocultar cuentas';

  @override
  String get searchAccounts => 'Buscar cuentas';

  @override
  String get searchCategories => 'Buscar categorías';

  @override
  String get developerMode => 'Modo Desarrollador';

  @override
  String get recurringTransactions => 'Transacciones Recurrentes';

  @override
  String get searchRecurringTransactions => 'Buscar transacciones recurrentes';

  @override
  String get addRecurringTransaction => 'Agregar transacción recurrente';

  @override
  String get noRecurringTransactionsFound =>
      'No se encontraron transacciones recurrentes';

  @override
  String get submitAll => 'Enviar todo';

  @override
  String get clearQueue => 'Limpiar cola';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get pleaseSelectAccount => 'Por favor seleccioná una cuenta.';

  @override
  String get pleaseSelectCategory => 'Por favor seleccioná una categoría.';

  @override
  String get nameMustBeAtLeast3Characters =>
      'El nombre debe tener al menos 3 caracteres.';

  @override
  String get enterValidPrice => 'Ingresá un precio válido.';

  @override
  String get addAtLeastOneTransactionBeforeSubmitting =>
      'Agregá al menos una transacción antes de enviar.';

  @override
  String transactionsSubmittedSuccessfully(Object count) {
    return '$count transacción(es) enviada(s) con éxito.';
  }

  @override
  String failedToSubmitTransactions(Object error) {
    return 'Error al enviar las transacciones: $error';
  }

  @override
  String get addToQueue => 'Agregar a la cola';

  @override
  String get noTransactionsQueuedYet =>
      'Todavía no hay transacciones en la cola.\nCompletá el formulario y presioná \"Agregar a la cola\".';

  @override
  String queuedTransactions(Object count) {
    return 'En cola ($count)';
  }

  @override
  String get remove => 'Quitar';

  @override
  String get transactionAccount => 'Cuenta';

  @override
  String get transactionCategory => 'Categoría';

  @override
  String get transactionDescription => 'Descripción';

  @override
  String get transactionAmount => 'Monto';

  @override
  String get transactionDate => 'Fecha';

  @override
  String get transactionType => 'Tipo';

  @override
  String get bulkTransactionsTitle => 'Transacciones masivas';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get showFilters => 'Mostrar filtros';

  @override
  String get hideFilters => 'Ocultar filtros';

  @override
  String get addBudget => 'Agregar presupuesto';

  @override
  String get budgetStateNew => 'Nuevo';

  @override
  String get budgetStateActive => 'Activo';

  @override
  String get budgetStateArchived => 'Archivado';

  @override
  String get budgetsListEmpty => 'La lista de presupuestos está vacía';

  @override
  String budgetTarget(Object amount) {
    return 'Objetivo del presupuesto: $amount';
  }

  @override
  String startDate(Object date) {
    return 'Inicio: $date';
  }

  @override
  String endDate(Object date) {
    return 'Fin: $date';
  }

  @override
  String get copy => 'Copiar';

  @override
  String get notAvailable => 'N/D';

  @override
  String get budgetName => 'Nombre';

  @override
  String get budgetAmount => 'Monto';

  @override
  String get budgetStartDate => 'Fecha de inicio';

  @override
  String get budgetEndDate => 'Fecha de fin';

  @override
  String get save => 'Guardar';

  @override
  String get spent => 'Gastado';

  @override
  String get budgeted => 'Presupuestado';

  @override
  String get remaining => 'Restante';

  @override
  String get categories => 'Categorías';

  @override
  String get noCategoriesDataAvailable =>
      'No hay datos de categorías disponibles';

  @override
  String get categoryHistoricalChart => 'Gráfico histórico de categorías';

  @override
  String lastMonths(Object count) {
    return 'Últimos $count meses';
  }

  @override
  String get noHistoricalCategoryDataAvailable =>
      'No hay datos históricos de categorías disponibles';

  @override
  String get dateFrom => 'Fecha desde';

  @override
  String get dateTo => 'Fecha hasta';

  @override
  String get itemsToTake => 'Cantidad de elementos';

  @override
  String get apply => 'Aplicar';

  @override
  String get pageSize => 'Tamaño de página';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get filterTransactions => 'Filtrar transacciones';

  @override
  String get selectFilterToDisplayTransactions =>
      'Seleccioná un filtro para mostrar transacciones';

  @override
  String get searchTransactionByName => 'Buscar transacción por nombre';

  @override
  String get selectOption => 'Seleccionar';

  @override
  String get selectCurrency => 'Seleccionar moneda';

  @override
  String get selectAccount => 'Seleccionar cuenta';

  @override
  String get selectAccounts => 'Seleccionar cuentas';

  @override
  String get selectCategory => 'Seleccionar categoría';

  @override
  String get selectCategories => 'Seleccionar categorías';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get filter => 'Filtrar';

  @override
  String get clear => 'Limpiar';

  @override
  String get ok => 'Aceptar';

  @override
  String get unknownAccount => 'Cuenta desconocida';

  @override
  String get accountNotSet => 'Cuenta no establecida';

  @override
  String get categoryNotSet => 'Categoría no establecida';

  @override
  String get createTransaction => 'Crear Transacción';

  @override
  String get priceNotSet => 'Precio no establecido';

  @override
  String get annually => 'Anualmente';

  @override
  String get categoryComparisonChart => 'Comparación de Categorías';

  @override
  String get noCategoryComparisonDataAvailable =>
      'No hay datos de comparación de categorías disponibles';

  @override
  String get currentMonth => 'Mes actual';

  @override
  String get lastMonth => 'Mes anterior';

  @override
  String get referenceDate => 'Fecha de referencia';

  @override
  String get percentageChange => 'Cambio porcentual';

  @override
  String get transactionsSearchStatistics => 'Estadísticas de búsqueda';

  @override
  String get transactionCounts => 'Cantidad de transacciones';

  @override
  String get transactionTotals => 'Totales de transacciones';

  @override
  String get totalIncome => 'Ingresos totales';

  @override
  String get totalOutcome => 'Egresos totales';

  @override
  String get transactionsByCategory => 'Transacciones por categoría';

  @override
  String get transactionsByAccount => 'Transacciones por cuenta';

  @override
  String get noAccountsDataAvailable => 'No hay datos de cuentas disponibles';

  @override
  String get refresh => 'Actualizar';

  @override
  String get tags => 'Etiquetas';

  @override
  String get addTag => 'Agregar etiqueta';

  @override
  String get selectTag => 'Seleccionar etiqueta';

  @override
  String get selectTags => 'Seleccionar etiquetas';

  @override
  String get createNewTag => 'Crear nueva etiqueta';

  @override
  String get noTagsAvailable => 'Todavía no hay etiquetas disponibles';

  @override
  String get noTags => 'Sin etiquetas';

  @override
  String get manageTransactionTags => 'Gestionar etiquetas de la transacción';

  @override
  String transactionTagsTitle(String name) {
    return 'Etiquetas: $name';
  }

  @override
  String maxTagsReached(int max, int current) {
    return 'Podés adjuntar hasta $max etiquetas ($current seleccionadas).';
  }

  @override
  String get transactionProjections => 'Proyección de gastos';

  @override
  String get noProjectionDataAvailable =>
      'No hay datos de proyección disponibles';

  @override
  String get projectedNextMonth => 'Próximo mes';

  @override
  String get projectedNext3Months => 'Próximos 3 meses';

  @override
  String get monthlyAverage => 'Promedio mensual';

  @override
  String basedOnLastMonths(int count) {
    return 'Basado en los últimos $count meses';
  }

  @override
  String get lookbackMonths => 'Meses hacia atrás';

  @override
  String get reconcileStatement => 'Conciliar extracto';

  @override
  String get reconciliationSelectFile => 'Elegir archivo del extracto';

  @override
  String get reconciliationNoStatementSelected =>
      'Elegí el archivo CSV que te da el banco para empezar';

  @override
  String get reconciliationPeriod => 'Período';

  @override
  String get reconciliationMatchedLabel => 'Conciliadas';

  @override
  String get reconciliationMissingLabel => 'Faltantes';

  @override
  String get reconciliationExtraLabel => 'No están en el extracto';

  @override
  String get reconciliationAmbiguousLabel => 'Ambiguas';

  @override
  String get reconciliationPossibleMatchesLabel => 'Posibles coincidencias';

  @override
  String get reconciliationPossibleMatchesHint =>
      'Movimientos que parecen ser del mismo comercio pero no coinciden del todo. Vinculá los que sean el mismo movimiento.';

  @override
  String reconciliationPossibleMatchDifference(String difference) {
    return '$difference de diferencia';
  }

  @override
  String reconciliationPossibleMatchDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días de diferencia',
      one: '1 día de diferencia',
      zero: 'mismo día',
    );
    return '$_temp0';
  }

  @override
  String get reconciliationLink => 'Vincular';

  @override
  String get reconciliationUnlink => 'Deshacer';

  @override
  String reconciliationLinkedRow(String name) {
    return 'Se vincula con $name — no se va a crear';
  }

  @override
  String reconciliationLinkedTransaction(String name) {
    return 'Se vincula con $name — no se va a eliminar';
  }

  @override
  String get reconciliationMatchedHint =>
      'Ya están en la app. No hay nada que hacer.';

  @override
  String get reconciliationMissingHint =>
      'Movimientos que el banco informa y no están en la app. Se van a crear los seleccionados.';

  @override
  String get reconciliationExtraHint =>
      'Transacciones de la app que el banco no informa. Se van a eliminar las seleccionadas.';

  @override
  String get reconciliationAmbiguousHint =>
      'Movimientos que podrían corresponder a más de una transacción. Resolvelos a mano desde la lista de transacciones.';

  @override
  String get reconciliationFullyReconciled =>
      'Este extracto está completamente conciliado';

  @override
  String get reconciliationConfirmDeleteTitle => '¿Eliminar transacciones?';

  @override
  String reconciliationConfirmDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se van a eliminar $count transacciones de forma permanente.',
      one: 'Se va a eliminar 1 transacción de forma permanente.',
    );
    return '$_temp0';
  }

  @override
  String reconciliationApplied(int created, int deleted) {
    return '$created creadas, $deleted eliminadas';
  }

  @override
  String get reconciliationBalanceMatches =>
      'El saldo de la cuenta coincide con el extracto';

  @override
  String reconciliationBalanceDifference(String difference) {
    return 'Diferencia contra el extracto: $difference';
  }

  @override
  String get reconciliationCategoryRequired =>
      'Elegí una categoría para cada movimiento a crear';

  @override
  String get reconciliationNothingSelected =>
      'No hay nada seleccionado para aplicar';

  @override
  String get failedToReadStatement => 'No se pudo leer el extracto';

  @override
  String get reconciliationNearPeriodEdge =>
      'Podría pertenecer a un extracto vecino — revisá antes de eliminar';

  @override
  String reconciliationBalanceMatchesAsOf(String date) {
    return 'El saldo de la cuenta al $date coincide con el extracto';
  }

  @override
  String reconciliationBalanceDifferenceAsOf(String date, String difference) {
    return 'Diferencia contra el extracto al $date: $difference';
  }

  @override
  String get savingsRate => 'Tasa de ahorro';

  @override
  String get savingsRateThisMonth => 'Este mes';

  @override
  String get savingsRateAverage => 'Promedio';

  @override
  String get savingsRateTotalIncome => 'Ingresos';

  @override
  String get savingsRateTotalExpense => 'Gastos';

  @override
  String get savingsRateTotalSaved => 'Ahorrado';

  @override
  String get noSavingsRateDataAvailable => 'No hay datos de tasa de ahorro';

  @override
  String get useWithoutAccount => 'Usar sin registrarme';

  @override
  String get localModeUnavailableTitle => 'Modo local no disponible';

  @override
  String get localModeKeyringUnavailable =>
      'El modo local necesita el almacén seguro de credenciales del sistema para guardar su clave de cifrado, pero no está disponible o está bloqueado. Desbloquealo y volvé a intentar.';

  @override
  String get localDataCannotBeOpened => 'No se pueden abrir tus datos locales';

  @override
  String get retry => 'Reintentar';

  @override
  String get accountHasTransactions =>
      'Esta cuenta tiene transacciones, por lo que no se puede eliminar. Eliminá primero sus transacciones o archivala.';

  @override
  String get categoryInUse =>
      'Esta categoría se usa en transacciones, por lo que no se puede eliminar. Podés desactivarla en su lugar.';

  @override
  String get deactivateCategory => 'Desactivar';

  @override
  String get categoryNameTaken => 'Ya existe una categoría con este nombre.';

  @override
  String get changeNotSaved =>
      'No se pudo guardar el cambio. No se modificó nada.';

  @override
  String get localModeBanner =>
      'Estás trabajando de forma local en esta computadora';

  @override
  String get createOnlineAccount => 'Crear cuenta online';

  @override
  String get signInExistingAccount => 'Iniciar sesión en una cuenta existente';

  @override
  String get signInExistingAccountConfirm =>
      'Tus datos locales se quedarán en esta computadora y no se moverán a esa cuenta. Elegí \"Usar sin registrarme\" más tarde para volver a ellos.';

  @override
  String get useOnlineAccountInstead => 'Usar una cuenta online';

  @override
  String get startWithEmptyData => 'Empezar con datos vacíos';

  @override
  String get localDataKeyMissing =>
      'La clave que protege tus datos locales ya no existe, por ejemplo tras reinstalar el sistema, así que los datos no se pueden abrir. Tu archivo se conservó y no se borró nada.';

  @override
  String get localDataUnreadable =>
      'No se puede leer el archivo de datos locales. Se conservó y no se borró nada.';

  @override
  String get localDataFileMissing =>
      'No se encontró tu archivo de datos locales. Si lo moviste, volvé a ponerlo y reintentá. Si no, podés empezar de nuevo con datos vacíos.';

  @override
  String get localDataRetryFailed =>
      'Todavía no se pueden abrir tus datos locales.';

  @override
  String get localModeEmptyDescription =>
      'Tus datos se guardan cifrados solo en esta computadora.';

  @override
  String get createFirstAccount => 'Creá tu primera cuenta';

  @override
  String get importTitle => 'Moviendo tus datos a tu cuenta online';

  @override
  String get importProgressCategories => 'Moviendo categorías';

  @override
  String get importProgressAccounts => 'Moviendo cuentas';

  @override
  String get importProgressTransactions => 'Moviendo transacciones';

  @override
  String get importVerifying => 'Verificando saldos';

  @override
  String get importDone => 'Tus datos ya están en tu cuenta online.';

  @override
  String importBalanceMismatch(String account, String local, String server) {
    return 'El saldo de $account no coincide: $local acá, $server online.';
  }

  @override
  String get importFailed =>
      'El traslado no terminó. Tus datos locales están intactos y no se perdió nada.';

  @override
  String get importResume => 'Terminá de mover tus datos locales';

  @override
  String importCurrencyMissing(String currencies) {
    return 'La cuenta online no ofrece estas monedas: $currencies. Todavía no se pueden mover tus datos.';
  }

  @override
  String get emailAlreadyRegistered =>
      'Este correo ya está registrado. Usá otro correo.';

  @override
  String importWrongUser(String email) {
    return 'El traslado se inició para $email. Iniciá sesión con esa cuenta para terminarlo.';
  }

  @override
  String get importPendingReadOnly =>
      'Tus datos locales se están moviendo a tu cuenta online, así que no se pueden modificar hasta que termine.';

  @override
  String get localSwitchFailed =>
      'Tu cuenta se creó, pero la aplicación todavía no pudo cambiar a ella. Tus datos locales están intactos. Usá \"Iniciar sesión en una cuenta existente\" para continuar.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get importWaitingForServer =>
      'Esperando a que tu cuenta online esté lista';

  @override
  String get importServerNotReady =>
      'Tu cuenta online todavía no está lista. Tus datos locales están intactos, así que volvé a intentarlo en un momento.';
}
