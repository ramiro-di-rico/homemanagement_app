// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Gestione Casa';

  @override
  String get userSettings => 'Impostazioni Utente';

  @override
  String get csvDelimiter => 'Delimitatore CSV';

  @override
  String get preferredCurrency => 'Valuta Preferita';

  @override
  String get backupFrequency => 'Frequenza di Backup';

  @override
  String get weekly => 'Settimanale';

  @override
  String get monthly => 'Mensile';

  @override
  String get appLanguage => 'Lingua dell\'App';

  @override
  String get english => 'Inglese';

  @override
  String get spanish => 'Spagnolo';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get accounts => 'Conti';

  @override
  String get mainAccounts => 'Conti Principali';

  @override
  String get reminders => 'Promemoria';

  @override
  String get settings => 'Impostazioni';

  @override
  String get authenticationSettings => 'Impostazioni di Autenticazione';

  @override
  String get username => 'Nome Utente';

  @override
  String get enableTwoFactorAuthentication =>
      'Abilita Autenticazione a Due Fattori';

  @override
  String get balance => 'Saldo';

  @override
  String get noBalanceInformation =>
      'Nessuna informazione sul saldo disponibile';

  @override
  String get overall => 'Complessivo';

  @override
  String get noTransactionsRecorded => 'Nessuna transazione ancora registrata';

  @override
  String get count => 'Conteggio';

  @override
  String get total => 'Totale';

  @override
  String get income => 'Entrate';

  @override
  String get outcome => 'Uscite';

  @override
  String get expense => 'Spesa';

  @override
  String get noBalanceHistory =>
      'Nessuna cronologia del saldo ancora disponibile';

  @override
  String get balanceHistory => 'Cronologia del Saldo';

  @override
  String get allCurrencies => 'Tutte le Valute';

  @override
  String get all => 'Tutto';

  @override
  String get months => 'Mesi';

  @override
  String removed(String name) {
    return '$name rimosso';
  }

  @override
  String failedToRemove(String name) {
    return 'Impossibile rimuovere $name';
  }

  @override
  String get showMenu => 'Mostra menu';

  @override
  String get editAccount => 'Modifica Conto';

  @override
  String get unarchive => 'Ripristina';

  @override
  String get archive => 'Archivia';

  @override
  String get importTransactions => 'Importa Transazioni';

  @override
  String get noTransactionsFoundForAccount =>
      'Nessuna transazione trovata per questo conto';

  @override
  String get filterByName => 'Filtra per nome';

  @override
  String get transactionsImportedSuccessfully =>
      'Transazioni importate con successo';

  @override
  String get failedToImportTransactions => 'Importazione transazioni fallita';

  @override
  String get signIn => 'Accedi';

  @override
  String get logout => 'Esci';

  @override
  String get dontHaveAccount => 'Non hai ancora un account?';

  @override
  String get createOne => 'Creane uno';

  @override
  String get emailOrUsername => 'Email o nome utente';

  @override
  String get password => 'Password';

  @override
  String get addAccount => 'Aggiungi Conto';

  @override
  String get addTransaction => 'Aggiungi Transazione';

  @override
  String get delete => 'Elimina';

  @override
  String get unassign => 'Disassegna';

  @override
  String addAccountTo(String name) {
    return 'Aggiungi Conto a $name';
  }

  @override
  String get noMoreAccountsAvailable =>
      'Non ci sono altri conti disponibili da aggiungere.';

  @override
  String get close => 'Chiudi';

  @override
  String get deleteAccount => 'Elimina Conto';

  @override
  String areYouSureDelete(String name) {
    return 'Sei sicuro di voler eliminare $name?';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String deleted(String name) {
    return '$name eliminato';
  }

  @override
  String get budget => 'Budget';

  @override
  String get searchTransactions => 'Cerca transazioni';

  @override
  String get bulkTransactions => 'Transazioni massive';

  @override
  String get loggingView => 'Vista Log';

  @override
  String get statistics => 'Statistiche';

  @override
  String get name => 'Nome';

  @override
  String get show => 'Mostra';

  @override
  String get hide => 'Nascondi';

  @override
  String get add => 'Aggiungi';

  @override
  String get edit => 'Modifica';

  @override
  String get rejectSubmissions => 'Rifiuta invii';

  @override
  String get reject => 'Rifiuta';

  @override
  String get invitationQr => 'QR di Invito';

  @override
  String get invitations => 'Inviti';

  @override
  String get createInvitation => 'Crea invito';

  @override
  String get invitationDescription =>
      'Un account, un invito. Gli utenti esterni inviano transazioni per l\'approvazione successiva.';

  @override
  String get clearDate => 'Cancella data';

  @override
  String get noInvitationsYet => 'Nessun invito ancora.';

  @override
  String get sortAndFilter => 'Ordina e filtra';

  @override
  String get createdDate => 'Data di creazione';

  @override
  String get expirationDate => 'Data di scadenza';

  @override
  String get allInvites => 'Tutti gli inviti';

  @override
  String get hasExpiration => 'Ha scadenza';

  @override
  String get noExpiration => 'Nessuna scadenza';

  @override
  String get allAccounts => 'Tutti i conti';

  @override
  String get allCategories => 'Tutte le categorie';

  @override
  String get allStatuses => 'Tutti gli stati';

  @override
  String get invitation => 'Invito';

  @override
  String get invitationUnavailable => 'Questo invito non è disponibile.';

  @override
  String categoryName(String name) {
    return 'Categoria: $name';
  }

  @override
  String statusLabel(String status) {
    return 'Stato: $status';
  }

  @override
  String expiresLabel(String date) {
    return 'Scade: $date';
  }

  @override
  String get submitTransaction => 'Invia transazione';

  @override
  String get submitForApproval => 'Invia per approvazione';

  @override
  String accountLabel(String name) {
    return 'Conto: $name';
  }

  @override
  String get exportTransactions => 'Esporta transazioni';

  @override
  String get downloadImportTemplate => 'Scarica template di importazione';

  @override
  String get templateDownloaded => 'Template scaricato';

  @override
  String get failedToDownloadTemplate => 'Download template fallito';

  @override
  String get registration => 'Registrazione';

  @override
  String get authenticationError => 'Errore di autenticazione.';

  @override
  String get couldNotAuthenticateAfterRegistration =>
      'Impossibile autenticare l\'utente dopo la registrazione.';

  @override
  String get showAllAccounts => 'Mostra tutti i conti';

  @override
  String get hideAccounts => 'Nascondi conti';

  @override
  String get searchAccounts => 'Cerca conti';

  @override
  String get developerMode => 'Modalità Sviluppatore';

  @override
  String get recurringTransactions => 'Transazioni Ricorrenti';

  @override
  String get searchRecurringTransactions => 'Cerca transazioni ricorrenti';

  @override
  String get addRecurringTransaction => 'Aggiungi transazione ricorrente';

  @override
  String get noRecurringTransactionsFound =>
      'Nessuna transazione ricorrente trovata';

  @override
  String get submitAll => 'Invia tutto';

  @override
  String get clearQueue => 'Pulisci coda';

  @override
  String get dismiss => 'Chiudi';

  @override
  String get pleaseSelectAccount => 'Seleziona un conto.';

  @override
  String get pleaseSelectCategory => 'Seleziona una categoria.';

  @override
  String get nameMustBeAtLeast3Characters =>
      'Il nome deve contenere almeno 3 caratteri.';

  @override
  String get enterValidPrice => 'Inserisci un prezzo valido.';

  @override
  String get addAtLeastOneTransactionBeforeSubmitting =>
      'Aggiungi almeno una transazione prima di inviare.';

  @override
  String transactionsSubmittedSuccessfully(Object count) {
    return '$count transazione(i) inviata(e) con successo.';
  }

  @override
  String failedToSubmitTransactions(Object error) {
    return 'Invio transazioni fallito: $error';
  }

  @override
  String get addToQueue => 'Aggiungi alla coda';

  @override
  String get noTransactionsQueuedYet =>
      'Nessuna transazione in coda.\nCompila il modulo e premi \"Aggiungi alla coda\".';

  @override
  String queuedTransactions(Object count) {
    return 'In coda ($count)';
  }

  @override
  String get remove => 'Rimuovi';

  @override
  String get transactionAccount => 'Conto';

  @override
  String get transactionCategory => 'Categoria';

  @override
  String get transactionDescription => 'Descrizione';

  @override
  String get transactionAmount => 'Importo';

  @override
  String get transactionDate => 'Data';

  @override
  String get transactionType => 'Tipo';

  @override
  String get bulkTransactionsTitle => 'Transazioni Massive';

  @override
  String get budgets => 'Budget';

  @override
  String get showFilters => 'Mostra filtri';

  @override
  String get hideFilters => 'Nascondi filtri';

  @override
  String get addBudget => 'Aggiungi budget';

  @override
  String get budgetStateNew => 'Nuovo';

  @override
  String get budgetStateActive => 'Attivo';

  @override
  String get budgetStateArchived => 'Archiviato';

  @override
  String get budgetsListEmpty => 'La lista dei budget è vuota';

  @override
  String budgetTarget(Object amount) {
    return 'Obiettivo budget: $amount';
  }

  @override
  String startDate(Object date) {
    return 'Inizio: $date';
  }

  @override
  String endDate(Object date) {
    return 'Fine: $date';
  }

  @override
  String get copy => 'Copia';

  @override
  String get notAvailable => 'N/D';

  @override
  String get budgetName => 'Nome';

  @override
  String get budgetAmount => 'Importo';

  @override
  String get budgetStartDate => 'Data di inizio';

  @override
  String get budgetEndDate => 'Data di fine';

  @override
  String get save => 'Salva';

  @override
  String get spent => 'Speso';

  @override
  String get budgeted => 'In budget';

  @override
  String get remaining => 'Rimanente';

  @override
  String get categories => 'Categorie';

  @override
  String get noCategoriesDataAvailable =>
      'Nessun dato sulle categorie disponibile';

  @override
  String get categoryHistoricalChart => 'Grafico Storico Categorie';

  @override
  String lastMonths(Object count) {
    return 'Ultimi $count mesi';
  }

  @override
  String get noHistoricalCategoryDataAvailable =>
      'Nessun dato storico sulle categorie disponibile';

  @override
  String get dateFrom => 'Dalla data';

  @override
  String get dateTo => 'Alla data';

  @override
  String get itemsToTake => 'Elementi da prendere';

  @override
  String get apply => 'Applica';

  @override
  String get pageSize => 'Dimensione pagina';

  @override
  String get clearFilters => 'Cancella filtri';

  @override
  String get filterTransactions => 'Filtra transazioni';

  @override
  String get selectFilterToDisplayTransactions =>
      'Seleziona un filtro per visualizzare le transazioni';

  @override
  String get searchTransactionByName => 'Cerca transazione per nome';

  @override
  String get selectOption => 'Seleziona';

  @override
  String get selectCurrency => 'Seleziona valuta';

  @override
  String get selectAccount => 'Seleziona conto';

  @override
  String get selectAccounts => 'Seleziona conti';

  @override
  String get selectCategory => 'Seleziona categoria';

  @override
  String get selectCategories => 'Seleziona categorie';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get filter => 'Filtra';

  @override
  String get clear => 'Cancella';

  @override
  String get ok => 'Ok';

  @override
  String get unknownAccount => 'Conto sconosciuto';

  @override
  String get accountNotSet => 'Conto non impostato';

  @override
  String get categoryNotSet => 'Categoria non impostata';

  @override
  String get createTransaction => 'Crea Transazione';

  @override
  String get priceNotSet => 'Prezzo non impostato';

  @override
  String get annually => 'Annualmente';

  @override
  String get categoryComparisonChart => 'Confronto Categorie';

  @override
  String get noCategoryComparisonDataAvailable =>
      'Nessun dato di confronto categorie disponibile';

  @override
  String get currentMonth => 'Mese corrente';

  @override
  String get lastMonth => 'Mese scorso';

  @override
  String get referenceDate => 'Data di riferimento';

  @override
  String get percentageChange => 'Variazione percentuale';

  @override
  String get transactionsSearchStatistics => 'Statistiche di ricerca';

  @override
  String get transactionCounts => 'Numero di transazioni';

  @override
  String get transactionTotals => 'Totali delle transazioni';

  @override
  String get totalIncome => 'Entrate totali';

  @override
  String get totalOutcome => 'Uscite totali';

  @override
  String get transactionsByCategory => 'Transazioni per categoria';

  @override
  String get transactionsByAccount => 'Transazioni per conto';

  @override
  String get noAccountsDataAvailable => 'Nessun dato dei conti disponibile';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get tags => 'Etichette';

  @override
  String get addTag => 'Aggiungi etichetta';

  @override
  String get selectTag => 'Seleziona etichetta';

  @override
  String get selectTags => 'Seleziona etichette';

  @override
  String get createNewTag => 'Crea nuova etichetta';

  @override
  String get noTagsAvailable => 'Nessuna etichetta disponibile';

  @override
  String get noTags => 'Nessuna etichetta';

  @override
  String get manageTransactionTags => 'Gestisci etichette della transazione';

  @override
  String transactionTagsTitle(String name) {
    return 'Etichette: $name';
  }

  @override
  String maxTagsReached(int max, int current) {
    return 'Puoi associare fino a $max etichette ($current selezionate).';
  }
}
