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
}
