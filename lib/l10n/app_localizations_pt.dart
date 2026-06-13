// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Gestão Doméstica';

  @override
  String get userSettings => 'Configurações do Usuário';

  @override
  String get csvDelimiter => 'Delimitador CSV';

  @override
  String get preferredCurrency => 'Moeda Preferida';

  @override
  String get backupFrequency => 'Frequência de Backup';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensal';

  @override
  String get appLanguage => 'Idioma do App';

  @override
  String get english => 'Inglês';

  @override
  String get spanish => 'Espanhol';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Português';

  @override
  String get dashboard => 'Painel';

  @override
  String get accounts => 'Contas';

  @override
  String get mainAccounts => 'Contas Principais';

  @override
  String get reminders => 'Lembretes';

  @override
  String get settings => 'Configurações';

  @override
  String get authenticationSettings => 'Configurações de Autenticação';

  @override
  String get username => 'Nome de Usuário';

  @override
  String get enableTwoFactorAuthentication =>
      'Habilitar Autenticação de Dois Fatores';

  @override
  String get balance => 'Saldo';

  @override
  String get noBalanceInformation => 'Nenhuma informação de saldo disponível';

  @override
  String get overall => 'Geral';

  @override
  String get noTransactionsRecorded => 'Nenhuma transação registrada ainda';

  @override
  String get count => 'Quantidade';

  @override
  String get total => 'Total';

  @override
  String get income => 'Receita';

  @override
  String get outcome => 'Despesa';

  @override
  String get expense => 'Gasto';

  @override
  String get noBalanceHistory => 'Nenhum histórico de saldo disponível ainda';

  @override
  String get balanceHistory => 'Histórico de Saldo';

  @override
  String get allCurrencies => 'Todas as Moedas';

  @override
  String get all => 'Tudo';

  @override
  String get months => 'Meses';

  @override
  String removed(String name) {
    return '$name removido';
  }

  @override
  String failedToRemove(String name) {
    return 'Falha ao remover $name';
  }

  @override
  String get showMenu => 'Mostrar menu';

  @override
  String get editAccount => 'Editar Conta';

  @override
  String get unarchive => 'Desarquivar';

  @override
  String get archive => 'Arquivar';

  @override
  String get importTransactions => 'Importar Transações';

  @override
  String get noTransactionsFoundForAccount =>
      'Nenhuma transação encontrada para esta conta';

  @override
  String get filterByName => 'Filtrar por nome';

  @override
  String get transactionsImportedSuccessfully =>
      'Transações importadas com sucesso';

  @override
  String get failedToImportTransactions => 'Falha ao importar transações';

  @override
  String get signIn => 'Entrar';

  @override
  String get logout => 'Sair';

  @override
  String get dontHaveAccount => 'Você ainda não tem uma conta?';

  @override
  String get createOne => 'Criar uma';

  @override
  String get emailOrUsername => 'E-mail ou nome de usuário';

  @override
  String get password => 'Senha';

  @override
  String get addAccount => 'Adicionar Conta';

  @override
  String get addTransaction => 'Adicionar Transação';

  @override
  String get delete => 'Excluir';

  @override
  String get unassign => 'Desvincular';

  @override
  String addAccountTo(String name) {
    return 'Adicionar Conta a $name';
  }

  @override
  String get noMoreAccountsAvailable =>
      'Não há mais contas disponíveis para adicionar.';

  @override
  String get close => 'Fechar';

  @override
  String get deleteAccount => 'Excluir Conta';

  @override
  String areYouSureDelete(String name) {
    return 'Tem certeza que deseja excluir $name?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String deleted(String name) {
    return '$name excluído';
  }

  @override
  String get budget => 'Orçamento';

  @override
  String get searchTransactions => 'Pesquisar transações';

  @override
  String get bulkTransactions => 'Transações em Lote';

  @override
  String get loggingView => 'Visualização de Logs';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get name => 'Nome';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get add => 'Adicionar';

  @override
  String get edit => 'Editar';

  @override
  String get rejectSubmissions => 'Rejeitar envios';

  @override
  String get reject => 'Rejeitar';

  @override
  String get invitationQr => 'QR de Convite';

  @override
  String get invitations => 'Convites';

  @override
  String get createInvitation => 'Criar convite';

  @override
  String get invitationDescription =>
      'Uma conta, um convite. Usuários externos enviam transações para aprovação posterior.';

  @override
  String get clearDate => 'Limpar data';

  @override
  String get noInvitationsYet => 'Nenhum convite ainda.';

  @override
  String get sortAndFilter => 'Ordenar e filtrar';

  @override
  String get createdDate => 'Data de criação';

  @override
  String get expirationDate => 'Data de expiração';

  @override
  String get allInvites => 'Todos os convites';

  @override
  String get hasExpiration => 'Tem expiração';

  @override
  String get noExpiration => 'Sem expiração';

  @override
  String get allAccounts => 'Todas as contas';

  @override
  String get allCategories => 'Todas as categorias';

  @override
  String get allStatuses => 'Todos os status';

  @override
  String get invitation => 'Convite';

  @override
  String get invitationUnavailable => 'Este convite não está disponível.';

  @override
  String categoryName(String name) {
    return 'Categoria: $name';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String expiresLabel(String date) {
    return 'Expira em: $date';
  }

  @override
  String get submitTransaction => 'Enviar transação';

  @override
  String get submitForApproval => 'Enviar para aprovação';

  @override
  String accountLabel(String name) {
    return 'Conta: $name';
  }

  @override
  String get exportTransactions => 'Exportar transações';

  @override
  String get downloadImportTemplate => 'Baixar modelo de importação';

  @override
  String get templateDownloaded => 'Modelo baixado';

  @override
  String get failedToDownloadTemplate => 'Falha ao baixar modelo';

  @override
  String get registration => 'Registro';

  @override
  String get authenticationError => 'Erro de autenticação.';

  @override
  String get couldNotAuthenticateAfterRegistration =>
      'Não foi possível autenticar o usuário após o registro.';

  @override
  String get showAllAccounts => 'Mostrar todas as contas';

  @override
  String get hideAccounts => 'Ocultar contas';

  @override
  String get searchAccounts => 'Pesquisar contas';

  @override
  String get developerMode => 'Modo Desenvolvedor';

  @override
  String get recurringTransactions => 'Transações Recorrentes';

  @override
  String get searchRecurringTransactions => 'Pesquisar transações recorrentes';

  @override
  String get addRecurringTransaction => 'Adicionar transação recorrente';

  @override
  String get noRecurringTransactionsFound =>
      'Nenhuma transação recorrente encontrada';

  @override
  String get submitAll => 'Enviar tudo';

  @override
  String get clearQueue => 'Limpar fila';

  @override
  String get dismiss => 'Ignorar';

  @override
  String get pleaseSelectAccount => 'Por favor, selecione uma conta.';

  @override
  String get pleaseSelectCategory => 'Por favor, selecione uma categoria.';

  @override
  String get nameMustBeAtLeast3Characters =>
      'O nome deve ter pelo menos 3 caracteres.';

  @override
  String get enterValidPrice => 'Insira um preço válido.';

  @override
  String get addAtLeastOneTransactionBeforeSubmitting =>
      'Adicione pelo menos uma transação antes de enviar.';

  @override
  String transactionsSubmittedSuccessfully(Object count) {
    return '$count transação(ões) enviada(s) com sucesso.';
  }

  @override
  String failedToSubmitTransactions(Object error) {
    return 'Falha ao enviar transações: $error';
  }

  @override
  String get addToQueue => 'Adicionar à fila';

  @override
  String get noTransactionsQueuedYet =>
      'Nenhuma transação na fila ainda.\nPreencha o formulário e pressione \"Adicionar à fila\".';

  @override
  String queuedTransactions(Object count) {
    return 'Na fila ($count)';
  }

  @override
  String get remove => 'Remover';

  @override
  String get transactionAccount => 'Conta';

  @override
  String get transactionCategory => 'Categoria';

  @override
  String get transactionDescription => 'Descrição';

  @override
  String get transactionAmount => 'Valor';

  @override
  String get transactionDate => 'Data';

  @override
  String get transactionType => 'Tipo';

  @override
  String get bulkTransactionsTitle => 'Transações em Lote';

  @override
  String get budgets => 'Orçamentos';

  @override
  String get showFilters => 'Mostrar Filtros';

  @override
  String get hideFilters => 'Ocultar Filtros';

  @override
  String get addBudget => 'Adicionar Orçamento';

  @override
  String get budgetStateNew => 'Novo';

  @override
  String get budgetStateActive => 'Ativo';

  @override
  String get budgetStateArchived => 'Arquivado';

  @override
  String get budgetsListEmpty => 'A lista de orçamentos está vazia';

  @override
  String budgetTarget(Object amount) {
    return 'Meta do orçamento: $amount';
  }

  @override
  String startDate(Object date) {
    return 'Início: $date';
  }

  @override
  String endDate(Object date) {
    return 'Fim: $date';
  }

  @override
  String get copy => 'Copiar';

  @override
  String get notAvailable => 'N/A';

  @override
  String get budgetName => 'Nome';

  @override
  String get budgetAmount => 'Valor';

  @override
  String get budgetStartDate => 'Data de Início';

  @override
  String get budgetEndDate => 'Data de Término';

  @override
  String get save => 'Salvar';

  @override
  String get spent => 'Gasto';

  @override
  String get budgeted => 'Orçado';

  @override
  String get remaining => 'Restante';

  @override
  String get categories => 'Categorias';

  @override
  String get noCategoriesDataAvailable =>
      'Nenhum dado de categorias disponível';

  @override
  String get categoryHistoricalChart => 'Gráfico Histórico de Categorias';

  @override
  String lastMonths(Object count) {
    return 'Últimos $count meses';
  }

  @override
  String get noHistoricalCategoryDataAvailable =>
      'Nenhum dado histórico de categoria disponível';

  @override
  String get dateFrom => 'Data De';

  @override
  String get dateTo => 'Data Até';

  @override
  String get itemsToTake => 'Itens para pegar';

  @override
  String get apply => 'Aplicar';

  @override
  String get pageSize => 'Tamanho da página';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get filterTransactions => 'Filtrar transações';

  @override
  String get selectFilterToDisplayTransactions =>
      'Selecione um filtro para exibir transações';

  @override
  String get searchTransactionByName => 'Pesquisar transação por nome';

  @override
  String get selectOption => 'Selecionar';

  @override
  String get selectCurrency => 'Selecionar moeda';

  @override
  String get selectAccount => 'Selecionar conta';

  @override
  String get selectAccounts => 'Selecionar contas';

  @override
  String get selectCategory => 'Selecionar categoria';

  @override
  String get selectCategories => 'Selecionar categorias';

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get filter => 'Filtrar';

  @override
  String get clear => 'Limpar';

  @override
  String get ok => 'Ok';

  @override
  String get unknownAccount => 'Conta desconhecida';

  @override
  String get accountNotSet => 'Conta não definida';

  @override
  String get categoryNotSet => 'Categoria não definida';

  @override
  String get createTransaction => 'Criar Transação';

  @override
  String get priceNotSet => 'Preço não definido';

  @override
  String get annually => 'Anualmente';

  @override
  String get categoryComparisonChart => 'Comparação de Categorias';

  @override
  String get noCategoryComparisonDataAvailable =>
      'Não há dados de comparação de categorias disponíveis';

  @override
  String get currentMonth => 'Mês atual';

  @override
  String get lastMonth => 'Mês anterior';

  @override
  String get referenceDate => 'Data de referência';

  @override
  String get percentageChange => 'Variação percentual';

  @override
  String get transactionsSearchStatistics => 'Estatísticas da pesquisa';

  @override
  String get transactionCounts => 'Quantidade de transações';

  @override
  String get transactionTotals => 'Totais das transações';

  @override
  String get totalIncome => 'Receitas totais';

  @override
  String get totalOutcome => 'Despesas totais';

  @override
  String get transactionsByCategory => 'Transações por categoria';

  @override
  String get transactionsByAccount => 'Transações por conta';

  @override
  String get noAccountsDataAvailable => 'Não há dados de contas disponíveis';

  @override
  String get refresh => 'Atualizar';
}
