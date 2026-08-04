import 'package:flutter/material.dart';
import 'package:home_management_app/data/models/reconciliation.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/transaction.service.dart';

/// What the reconciliation screen needs from its repository. Exists so the screen can be tested
/// against a fake without building the whole service graph.
abstract class ReconciliationController extends ChangeNotifier {
  ReconciliationPreviewModel? get preview;

  bool get isLoading;

  bool get hasPreview;

  Future<ReconciliationPreviewModel?> loadPreview(int accountId, String fileContent,
      {StatementFormat format});

  Future<ApplyReconciliationResultModel?> apply(
    int accountId, {
    List<ReconciliationTransactionToCreate> transactionsToCreate,
    List<int> transactionIdsToDelete,
    List<ReconciliationReferenceLink>? referencesToLink,
    bool verifyBalance,
  });

  List<ReconciliationReferenceLink> pendingReferenceLinks();

  void clear();
}

/// Drives the two steps of reconciling an account against a bank statement: a preview that only
/// reads, and an apply that performs what the user selected on it.
class ReconciliationRepository extends ChangeNotifier
    implements ReconciliationController {
  final TransactionService transactionService;
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;
  final NotifierService errorNotifierService;

  ReconciliationRepository({
    required this.transactionService,
    required this.accountRepository,
    required this.transactionRepository,
    required this.errorNotifierService,
  });

  ReconciliationPreviewModel? _preview;
  bool _loading = false;

  @override
  ReconciliationPreviewModel? get preview => _preview;

  @override
  bool get isLoading => _loading;

  @override
  bool get hasPreview => _preview != null;

  @override
  Future<ReconciliationPreviewModel?> loadPreview(
      int accountId, String fileContent,
      {StatementFormat format = StatementFormat.accountStatementCsv}) async {
    _loading = true;
    notifyListeners();

    try {
      _preview = await transactionService.previewReconciliation(
          accountId, fileContent,
          format: format);
      return _preview;
    } catch (e) {
      errorNotifierService.notify('Error reading bank statement: $e',
          isError: true);
      _preview = null;
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Applies the user's selection. [transactionIdsToDelete] deletes transactions for good, so the
  /// caller is responsible for confirming it first.
  ///
  /// References of the heuristic matches are linked on every apply: they cost nothing and make the
  /// next reconciliation of the same statement a straight reference match.
  @override
  Future<ApplyReconciliationResultModel?> apply(
    int accountId, {
    List<ReconciliationTransactionToCreate> transactionsToCreate = const [],
    List<int> transactionIdsToDelete = const [],
    List<ReconciliationReferenceLink>? referencesToLink,
    bool verifyBalance = true,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      var result = await transactionService.applyReconciliation(
        accountId,
        transactionsToCreate: transactionsToCreate,
        transactionIdsToDelete: transactionIdsToDelete,
        referencesToLink: referencesToLink ?? pendingReferenceLinks(),
        expectedFinalBalance:
            verifyBalance ? _preview?.statementBalances?.finalBalance : null,
        // The bank reports the balance at the end of the period, not today's.
        periodEnd: verifyBalance ? _preview?.periodEnd : null,
      );

      // Balances and the transaction list both changed on the server.
      await accountRepository.refresh();
      if (transactionRepository.currentAccountId == accountId) {
        await transactionRepository.refresh();
      }

      _preview = null;
      return result;
    } catch (e) {
      errorNotifierService.notify('Error applying reconciliation: $e',
          isError: true);
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// The matches of the current preview whose reference is not persisted yet.
  @override
  List<ReconciliationReferenceLink> pendingReferenceLinks() =>
      (_preview?.matched ?? const [])
          .where((m) => m.requiresReferenceLink)
          .map((m) => ReconciliationReferenceLink(
              transactionId: m.transactionId,
              externalReference: m.row.reference))
          .toList();

  @override
  void clear() {
    _preview = null;
    notifyListeners();
  }
}
