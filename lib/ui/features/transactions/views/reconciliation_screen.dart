import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/models/reconciliation.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/reconciliation_repository.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Supplies the categories offered for the movements to create.
typedef CategoriesProvider = List<CategoryModel> Function();

/// Reconciles an account against the CSV statement the bank offers for download: shows what the bank
/// reports and the app is missing, what the app has and the bank does not report, and applies only
/// what the user selects.
class ReconciliationScreen extends StatefulWidget {
  static const String fullPath = '/home_screen/reconciliation';
  static const String path = '/reconciliation';

  final AccountModel account;

  /// Both default to the registered singletons; tests pass their own.
  final ReconciliationController? controller;
  final CategoriesProvider? categoriesProvider;

  const ReconciliationScreen(this.account,
      {super.key, this.controller, this.categoriesProvider});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  late final ReconciliationController _repository =
      widget.controller ?? GetIt.I<ReconciliationRepository>();
  late final CategoriesProvider _categoriesProvider = widget.categoriesProvider ??
      () => GetIt.I<CategoryRepository>().getActiveCategories();

  /// References of the statement rows to create. Every missing row starts selected.
  final Set<String> _selectedMissing = {};

  /// Category chosen per statement row, seeded with the backend suggestion.
  final Map<String, int> _categoryByReference = {};

  /// Ids to delete. Deliberately empty at the start: deleting is destructive.
  final Set<int> _selectedExtra = {};

  bool _applying = false;

  /// The preview the current selection was seeded from.
  ReconciliationPreviewModel? _seededPreview;

  @override
  void initState() {
    super.initState();
    _repository.clear();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations.reconcileStatement} · ${widget.account.name}'),
        actions: [
          if (_repository.hasPreview)
            IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: localizations.reconciliationSelectFile,
              onPressed: _applying ? null : _pickStatement,
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _repository,
        builder: (context, _) {
          if (_repository.isLoading || _applying) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ignore a preview belonging to another account: applying it here would create that
          // account's movements on this one.
          final preview = _repository.preview;
          if (preview == null || preview.accountId != widget.account.id) {
            return _buildEmptyState(localizations);
          }

          return _buildPreview(context, localizations, preview);
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.compare_arrows, size: 64, color: Colors.blueGrey),
              const SizedBox(height: 16),
              Text(
                localizations.reconciliationNoStatementSelected,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(localizations.reconciliationSelectFile),
                onPressed: _pickStatement,
              ),
            ],
          ),
        ),
      );

  /// Seeds the selection from the preview itself, so "every missing row starts selected with its
  /// suggested category" holds however the preview arrived, not only through the file picker.
  void _seedSelectionIfNeeded(ReconciliationPreviewModel preview) {
    if (identical(_seededPreview, preview)) return;

    _seededPreview = preview;
    _selectedMissing
      ..clear()
      ..addAll(preview.missing.map((m) => m.row.reference));
    _categoryByReference.clear();
    for (final missing in preview.missing) {
      if (missing.suggestedCategoryId != null) {
        _categoryByReference[missing.row.reference] = missing.suggestedCategoryId!;
      }
    }
    // Deleting is destructive, so nothing here is preselected.
    _selectedExtra.clear();
  }

  Widget _buildPreview(BuildContext context, AppLocalizations localizations,
      ReconciliationPreviewModel preview) {
    _seedSelectionIfNeeded(preview);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          _buildSummary(context, localizations, preview),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: '${localizations.reconciliationMissingLabel} (${preview.missing.length})'),
              Tab(text: '${localizations.reconciliationExtraLabel} (${preview.extra.length})'),
              Tab(text: '${localizations.reconciliationAmbiguousLabel} (${preview.ambiguous.length})'),
              Tab(text: '${localizations.reconciliationMatchedLabel} (${preview.matched.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMissingTab(localizations, preview),
                _buildExtraTab(localizations, preview),
                _buildAmbiguousTab(localizations, preview),
                _buildMatchedTab(localizations, preview),
              ],
            ),
          ),
          _buildApplyBar(localizations, preview),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, AppLocalizations localizations,
      ReconciliationPreviewModel preview) {
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final period = preview.periodStart == null || preview.periodEnd == null
        ? ''
        : '${dateFormat.format(preview.periodStart!)} - ${dateFormat.format(preview.periodEnd!)}';

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (period.isNotEmpty)
              Text('${localizations.reconciliationPeriod}: $period',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (preview.isFullyReconciled)
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(localizations.reconciliationFullyReconciled)),
                ],
              ),
            if (preview.statementBalances != null)
              Text(
                '${localizations.balance}: '
                '${_formatAmount(preview.statementBalances!.finalBalance)}',
                style: const TextStyle(color: Colors.blueGrey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingTab(
      AppLocalizations localizations, ReconciliationPreviewModel preview) {
    final categories = _categoriesProvider();

    return _buildTab(
      hint: localizations.reconciliationMissingHint,
      itemCount: preview.missing.length,
      selectedCount: _selectedMissing.length,
      onSelectAll: (selected) => setState(() {
        _selectedMissing.clear();
        if (selected) {
          _selectedMissing.addAll(preview.missing.map((m) => m.row.reference));
        }
      }),
      localizations: localizations,
      itemBuilder: (context, index) {
        final missing = preview.missing[index];
        final reference = missing.row.reference;
        final categoryId = _categoryByReference[reference];
        final selectedCategory = categories.where((c) => c.id == categoryId).firstOrNull;

        return CheckboxListTile(
          value: _selectedMissing.contains(reference),
          onChanged: (value) => setState(() {
            if (value == true) {
              _selectedMissing.add(reference);
            } else {
              _selectedMissing.remove(reference);
            }
          }),
          title: Text(missing.row.name),
          isThreeLine: true,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_rowSubtitle(missing.row)),
              DropdownButton<CategoryModel>(
                value: selectedCategory,
                isDense: true,
                hint: Text(localizations.transactionCategory,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error, fontSize: 13)),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (category) => setState(() {
                  if (category == null) return;
                  _categoryByReference[reference] = category.id;
                }),
              ),
            ],
          ),
          secondary: _amountLabel(missing.row.price, missing.row.isIncome()),
        );
      },
    );
  }

  Widget _buildExtraTab(
      AppLocalizations localizations, ReconciliationPreviewModel preview) {
    return _buildTab(
      hint: localizations.reconciliationExtraHint,
      itemCount: preview.extra.length,
      selectedCount: _selectedExtra.length,
      onSelectAll: (selected) => setState(() {
        _selectedExtra.clear();
        if (selected) {
          _selectedExtra.addAll(preview.extra.map((t) => t.id));
        }
      }),
      localizations: localizations,
      itemBuilder: (context, index) {
        final transaction = preview.extra[index];

        return CheckboxListTile(
          value: _selectedExtra.contains(transaction.id),
          onChanged: (value) => setState(() {
            if (value == true) {
              _selectedExtra.add(transaction.id);
            } else {
              _selectedExtra.remove(transaction.id);
            }
          }),
          title: Text(transaction.name),
          subtitle: Text(
              '${_formatDate(context, transaction.date)} · ${transaction.categoryName}'),
          secondary: _amountLabel(transaction.price, transaction.isIncome()),
        );
      },
    );
  }

  Widget _buildAmbiguousTab(
      AppLocalizations localizations, ReconciliationPreviewModel preview) {
    return _buildTab(
      hint: localizations.reconciliationAmbiguousHint,
      itemCount: preview.ambiguous.length,
      localizations: localizations,
      itemBuilder: (context, index) {
        final ambiguous = preview.ambiguous[index];

        return ListTile(
          leading: const Icon(Icons.help_outline, color: Colors.orange),
          title: Text(ambiguous.row.name),
          subtitle: Text(_rowSubtitle(ambiguous.row)),
          trailing: _amountLabel(ambiguous.row.price, ambiguous.row.isIncome()),
        );
      },
    );
  }

  Widget _buildMatchedTab(
      AppLocalizations localizations, ReconciliationPreviewModel preview) {
    return _buildTab(
      hint: localizations.reconciliationMatchedHint,
      itemCount: preview.matched.length,
      localizations: localizations,
      itemBuilder: (context, index) {
        final matched = preview.matched[index];

        return ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: Text(matched.row.name),
          subtitle: Text(_rowSubtitle(matched.row)),
          trailing: _amountLabel(matched.row.price, matched.row.isIncome()),
        );
      },
    );
  }

  /// Every tab is a hint, an optional select-all and a list. [onSelectAll] being null makes the tab
  /// read-only.
  Widget _buildTab({
    required String hint,
    required int itemCount,
    required AppLocalizations localizations,
    required Widget? Function(BuildContext, int) itemBuilder,
    int selectedCount = 0,
    void Function(bool selected)? onSelectAll,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(hint,
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ),
              if (onSelectAll != null && itemCount > 0)
                TextButton(
                  onPressed: () => onSelectAll(selectedCount < itemCount),
                  child: Text(localizations.selectAll),
                ),
            ],
          ),
        ),
        Expanded(
          child: itemCount == 0
              ? const Center(child: Icon(Icons.done_all, color: Colors.green))
              : ListView.separated(
                  itemCount: itemCount,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: itemBuilder,
                ),
        ),
      ],
    );
  }

  Widget _buildApplyBar(
      AppLocalizations localizations, ReconciliationPreviewModel preview) {
    final missingWithoutCategory = _selectedMissing
        .where((reference) => _categoryByReference[reference] == null)
        .length;
    final hasSelection = _selectedMissing.isNotEmpty || _selectedExtra.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (missingWithoutCategory > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  localizations.reconciliationCategoryRequired,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: Text('${localizations.apply}'
                  '${hasSelection ? ' (${_selectedMissing.length + _selectedExtra.length})' : ''}'),
              onPressed: missingWithoutCategory > 0 ? null : () => _apply(preview),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStatement() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null) return;

      final fileContent = await result.files.first.xFile.readAsString();
      if (fileContent.isEmpty) return;

      await _repository.loadPreview(widget.account.id, fileContent);
    } catch (e) {
      if (mounted) _showMessage(localizations.failedToReadStatement, isError: true);
    }
  }

  Future<void> _apply(ReconciliationPreviewModel preview) async {
    final localizations = AppLocalizations.of(context)!;

    if (_selectedMissing.isEmpty &&
        _selectedExtra.isEmpty &&
        _repository.pendingReferenceLinks().isEmpty) {
      _showMessage(localizations.reconciliationNothingSelected);
      return;
    }

    if (_selectedExtra.isNotEmpty && !await _confirmDeletion(localizations)) {
      return;
    }

    final toCreate = preview.missing
        .where((m) => _selectedMissing.contains(m.row.reference))
        .map((m) => ReconciliationTransactionToCreate.fromRow(
            m.row, _categoryByReference[m.row.reference]!))
        .toList();

    setState(() => _applying = true);
    final result = await _repository.apply(
      widget.account.id,
      transactionsToCreate: toCreate,
      transactionIdsToDelete: _selectedExtra.toList(),
    );
    if (!mounted) return;
    setState(() => _applying = false);

    if (result == null) return;

    // One message, not two: a second snackbar would immediately hide the first.
    var message = localizations.reconciliationApplied(
        result.createdCount, result.deletedCount);
    final check = result.balanceCheck;
    if (check != null) {
      message = '$message · ${check.matches
          ? localizations.reconciliationBalanceMatches
          : localizations.reconciliationBalanceDifference(
              _formatAmount(check.difference))}';
    }

    _showMessage(message, isError: check != null && !check.matches);
  }

  Future<bool> _confirmDeletion(AppLocalizations localizations) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.reconciliationConfirmDeleteTitle),
        content: Text(localizations
            .reconciliationConfirmDeleteMessage(_selectedExtra.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  String _rowSubtitle(StatementRowModel row) =>
      '${_formatDate(context, row.date)} · ${row.reference}';

  String _formatDate(BuildContext context, DateTime date) =>
      DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);

  String _formatAmount(double amount) =>
      NumberFormat.decimalPattern(Localizations.localeOf(context).toString())
          .format(amount);

  Widget _amountLabel(double price, bool isIncome) => Text(
        _formatAmount(price),
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      );
}
