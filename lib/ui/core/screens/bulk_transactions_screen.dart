import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/ui/core/custom/formatters/localized_number_input_formatter.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction_suggestion_option.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';

class BulkTransactionsScreen extends StatefulWidget {
  static const String fullPath = '/home_screen/bulk_transactions';
  static const String path = '/bulk_transactions';

  final AccountRepository? accountRepository;
  final CategoryRepository? categoryRepository;
  final TransactionRepository? transactionRepository;
  final TransactionService? transactionService;

  const BulkTransactionsScreen({
    super.key,
    this.accountRepository,
    this.categoryRepository,
    this.transactionRepository,
    this.transactionService,
  });

  @override
  State<BulkTransactionsScreen> createState() => _BulkTransactionsScreenState();
}

class _BulkTransactionsScreenState extends State<BulkTransactionsScreen> {
  late final AccountRepository _accountRepository;
  late final CategoryRepository _categoryRepository;
  late final TransactionRepository _transactionRepository;
  late final TransactionService _transactionService;

  final List<TransactionModel> _pendingTransactions = [];

  // Form state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  AccountModel? _selectedAccount;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.Outcome;

  List<TransactionModel> _suggestions = [];

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _accountRepository = widget.accountRepository ?? GetIt.I<AccountRepository>();
    _categoryRepository = widget.categoryRepository ?? GetIt.I<CategoryRepository>();
    _transactionRepository = widget.transactionRepository ?? GetIt.I<TransactionRepository>();
    _transactionService = widget.transactionService ?? GetIt.I<TransactionService>();

    final accounts = _accountRepository.accounts;
    if (accounts.isNotEmpty) _selectedAccount = accounts.first;

    final categories = _categoryRepository.getActiveCategories();
    if (categories.isNotEmpty) _selectedCategory = categories.first;

    fetchSuggestions();
  }

  void fetchSuggestions() async {
    try {
      final fetched = await _transactionRepository.getSuggestions();
      if (mounted) {
        setState(() {
          _suggestions = fetched;
        });
      }
    } catch (_) {}

    try {
      if (_accountRepository.accounts.isEmpty) {
        await _accountRepository.load();
        if (mounted) {
          setState(() {
            if (_selectedAccount == null && _accountRepository.accounts.isNotEmpty) {
              _selectedAccount = _accountRepository.accounts.first;
            }
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _addToQueue() {
    final localizations = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (_selectedAccount == null) {
      setState(() => _errorMessage = localizations.pleaseSelectAccount);
      return;
    }
    if (_selectedCategory == null) {
      setState(() => _errorMessage = localizations.pleaseSelectCategory);
      return;
    }
    if (name.length < 3) {
      setState(() => _errorMessage = localizations.nameMustBeAtLeast3Characters);
      return;
    }
    final price = LocalizedNumberInputFormatterHelper.parseDouble(
      priceText,
      Localizations.localeOf(context).toString(),
    );
    if (price == null || price <= 0) {
      setState(() => _errorMessage = localizations.enterValidPrice);
      return;
    }

    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _pendingTransactions.add(
        TransactionModel(
          0,
          _selectedAccount!.id,
          _selectedCategory!.id,
          name,
          price,
          _selectedDate,
          _selectedType,
          categoryName: _selectedCategory!.name,
        ),
      );
      _nameController.clear();
      _priceController.clear();
      _selectedDate = DateTime.now();
    });
  }

  void _removeFromQueue(int index) {
    setState(() => _pendingTransactions.removeAt(index));
  }

  Future<void> _editQueuedTransaction(int index) async {
    final localizations = AppLocalizations.of(context)!;
    final accounts = _accountRepository.accounts;
    final categories = _categoryRepository.getActiveCategories();
    final transaction = _pendingTransactions[index];
    final locale = Localizations.localeOf(context).toString();

    final nameController = TextEditingController(text: transaction.name);
    final priceController = TextEditingController(
      text: LocalizedNumberInputFormatterHelper.formatDouble(
        transaction.price,
        locale,
      ),
    );

    AccountModel? selectedAccount;
    for (final account in accounts) {
      if (account.id == transaction.accountId) {
        selectedAccount = account;
        break;
      }
    }
    selectedAccount ??= accounts.isNotEmpty ? accounts.first : null;

    CategoryModel? selectedCategory;
    for (final category in categories) {
      if (category.id == transaction.categoryId) {
        selectedCategory = category;
        break;
      }
    }
    selectedCategory ??= categories.isNotEmpty ? categories.first : null;

    DateTime selectedDate = transaction.date;
    TransactionType selectedType = transaction.transactionType;
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(localizations.edit),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dialogError != null) ...[
                        Text(
                          dialogError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      DropdownButtonFormField<AccountModel>(
                        initialValue: selectedAccount,
                        decoration: InputDecoration(
                          labelText: localizations.transactionAccount,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                        ),
                        items: accounts
                            .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedAccount = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<CategoryModel>(
                        initialValue: selectedCategory,
                        decoration: InputDecoration(
                          labelText: localizations.transactionCategory,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedCategory = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: localizations.transactionDescription,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.edit_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          LocalizedNumberInputFormatter(locale: locale),
                        ],
                        decoration: InputDecoration(
                          labelText: localizations.transactionAmount,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DateTimeField(
                        format: DateFormat('dd MMM yyyy'),
                        decoration: InputDecoration(
                          labelText: localizations.transactionDate,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.date_range),
                        ),
                        initialValue: selectedDate,
                        onShowPicker: (context, currentValue) => showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? selectedDate,
                          lastDate: DateTime(2100),
                        ),
                        onChanged: (date) {
                          if (date != null) {
                            setDialogState(() => selectedDate = date);
                          }
                        },
                        resetIcon: null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TransactionType>(
                        initialValue: selectedType,
                        decoration: InputDecoration(
                          labelText: localizations.transactionType,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.swap_vert),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: TransactionType.Outcome,
                            child: Text(localizations.outcome),
                          ),
                          DropdownMenuItem(
                            value: TransactionType.Income,
                            child: Text(localizations.income),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedType = v);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(localizations.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final price = LocalizedNumberInputFormatterHelper.parseDouble(
                      priceController.text.trim(),
                      locale,
                    );

                    if (selectedAccount == null) {
                      setDialogState(() => dialogError = localizations.pleaseSelectAccount);
                      return;
                    }
                    if (selectedCategory == null) {
                      setDialogState(() => dialogError = localizations.pleaseSelectCategory);
                      return;
                    }
                    if (name.length < 3) {
                      setDialogState(
                        () => dialogError = localizations.nameMustBeAtLeast3Characters,
                      );
                      return;
                    }
                    if (price == null || price <= 0) {
                      setDialogState(() => dialogError = localizations.enterValidPrice);
                      return;
                    }

                    setState(() {
                      _errorMessage = null;
                      _successMessage = null;
                      _pendingTransactions[index] = TransactionModel(
                        transaction.id,
                        selectedAccount!.id,
                        selectedCategory!.id,
                        name,
                        price,
                        selectedDate,
                        selectedType,
                        categoryName: selectedCategory!.name,
                        tags: List.from(transaction.tags),
                      );
                    });
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(localizations.save),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    priceController.dispose();
  }

  Future<void> _submitAll() async {
    final localizations = AppLocalizations.of(context)!;
    if (_pendingTransactions.isEmpty) {
      setState(() => _errorMessage = localizations.addAtLeastOneTransactionBeforeSubmitting);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final updatedAccounts = await _transactionService.bulkAdd(List.from(_pendingTransactions));
      _accountRepository.setBalances(updatedAccounts);
      setState(() {
        _successMessage = localizations.transactionsSubmittedSuccessfully(_pendingTransactions.length.toString());
        _pendingTransactions.clear();
      });
    } catch (e) {
      setState(() => _errorMessage = localizations.failedToSubmitTransactions(e.toString()));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.bulkTransactionsTitle),
        actions: [
          if (_pendingTransactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Badge(
                label: Text(_pendingTransactions.length.toString()),
                child: const Icon(Icons.list_alt),
              ),
            ),
          TextButton.icon(
            onPressed: _isSubmitting || _pendingTransactions.isEmpty ? null : _submitAll,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(localizations.submitAll),
          ),
          if (_pendingTransactions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: localizations.clearQueue,
              onPressed: () => setState(() => _pendingTransactions.clear()),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return Column(
              children: [
                if (_errorMessage != null)
                  MaterialBanner(
                    content: Text(_errorMessage!),
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    actions: [
                      TextButton(
                        onPressed: () => setState(() => _errorMessage = null),
                        child: Text(localizations.dismiss),
                      ),
                    ],
                  ),
                if (_successMessage != null)
                  MaterialBanner(
                    content: Text(_successMessage!),
                    backgroundColor: Colors.green.shade800,
                    actions: [
                      TextButton(
                        onPressed: () => setState(() => _successMessage = null),
                        child: Text(localizations.dismiss),
                      ),
                    ],
                  ),
                Expanded(
                  child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 420,
          child: Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildForm(),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildQueue(),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildForm(),
            ),
          ),
          const SizedBox(height: 16),
          _buildQueue(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final accounts = _accountRepository.accounts;
    final categories = _categoryRepository.getActiveCategories();
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(localizations.addTransaction, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),

        // Account
        DropdownButtonFormField<AccountModel>(
          key: ValueKey('account_${_selectedAccount?.id}'),
          initialValue: accounts.any((a) => a.id == _selectedAccount?.id)
              ? accounts.firstWhere((a) => a.id == _selectedAccount?.id)
              : null,
          decoration: InputDecoration(
            labelText: localizations.transactionAccount,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          ),
          items: accounts
              .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
              .toList(),
          onChanged: (v) => setState(() => _selectedAccount = v),
        ),
        const SizedBox(height: 12),

        // Category
        DropdownButtonFormField<CategoryModel>(
          key: ValueKey('category_${_selectedCategory?.id}'),
          initialValue: categories.any((c) => c.id == _selectedCategory?.id)
              ? categories.firstWhere((c) => c.id == _selectedCategory?.id)
              : null,
          decoration: InputDecoration(
            labelText: localizations.transactionCategory,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        ),
        const SizedBox(height: 12),

        // Name
        Autocomplete<TransactionSuggestionOption>(
          textEditingController: _nameController,
          focusNode: _nameFocusNode,
          displayStringForOption: (TransactionSuggestionOption option) => option.name,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<TransactionSuggestionOption>.empty();
            }
            final query = textEditingValue.text.toLowerCase();
            final matchingTransactions = _suggestions
                .where((TransactionModel option) =>
                    option.name.toLowerCase().contains(query))
                .map((TransactionModel option) => TransactionModelOption(option));
            final matchingAccounts = _accountRepository.accounts
                .where((AccountModel account) =>
                    account.name.isNotEmpty &&
                    account.name.toLowerCase().contains(query))
                .map((AccountModel account) => AccountModelOption(account));
            return [...matchingTransactions, ...matchingAccounts];
          },
          optionsViewBuilder: (context, onSelected, options) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(15),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 260,
                        maxWidth: constraints.maxWidth,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final TransactionSuggestionOption option =
                              options.elementAt(index);
                          if (option is TransactionModelOption) {
                            final TransactionModel transaction =
                                option.transaction;
                            return ListTile(
                              title: Text(transaction.name),
                              subtitle: Text(
                                '${transaction.categoryName} - \$${transaction.price}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              onTap: () => onSelected(option),
                            );
                          } else if (option is AccountModelOption) {
                            final AccountModel account = option.account;
                            return ListTile(
                              title: Text(account.name),
                              subtitle: Text(
                                'Account',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              onTap: () => onSelected(option),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          onSelected: (TransactionSuggestionOption selection) {
            if (selection is TransactionModelOption) {
              final TransactionModel selectionModel = selection.transaction;
              _nameController.text = selectionModel.name;
              final matchingCategories = _categoryRepository.getActiveCategories().where(
                (c) => c.id == selectionModel.categoryId,
              );
              if (matchingCategories.isNotEmpty) {
                _selectedCategory = matchingCategories.first;
              }
              final matchingAccounts = _accountRepository.accounts.where(
                (a) => a.id == selectionModel.accountId,
              );
              if (matchingAccounts.isNotEmpty) {
                _selectedAccount = matchingAccounts.first;
              }
              _selectedType = selectionModel.transactionType;
              _priceController.text =
                  LocalizedNumberInputFormatterHelper.formatDouble(
                selectionModel.price,
                Localizations.localeOf(context).toString(),
              );
            } else if (selection is AccountModelOption) {
              final AccountModel account = selection.account;
              _nameController.text = account.name;
              final matchingAccounts = _accountRepository.accounts.where(
                (a) => a.id == account.id,
              );
              if (matchingAccounts.isNotEmpty) {
                _selectedAccount = matchingAccounts.first;
              } else {
                _selectedAccount = account;
              }
            }
            setState(() {});
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            if (_nameController.text != controller.text &&
                _nameController.text.isNotEmpty &&
                controller.text.isEmpty) {
              controller.text = _nameController.text;
            }
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: localizations.transactionDescription,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // Price
        TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            LocalizedNumberInputFormatter(
              locale: Localizations.localeOf(context).toString(),
            ),
          ],
          decoration: InputDecoration(
            labelText: localizations.transactionAmount,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.attach_money),
          ),
        ),
        const SizedBox(height: 12),

        // Date
        DateTimeField(
          format: DateFormat('dd MMM yyyy'),
          decoration: InputDecoration(
            labelText: localizations.transactionDate,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.date_range),
          ),
          initialValue: _selectedDate,
          onShowPicker: (context, currentValue) => showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100),
          ),
          onChanged: (date) {
            if (date != null) setState(() => _selectedDate = date);
          },
          resetIcon: null,
        ),
        const SizedBox(height: 12),

        // Type
        DropdownButtonFormField<TransactionType>(
          key: ValueKey('type_$_selectedType'),
          initialValue: _selectedType,
          decoration: InputDecoration(
            labelText: localizations.transactionType,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.swap_vert),
          ),
          items: [
            DropdownMenuItem(value: TransactionType.Outcome, child: Text(localizations.outcome)),
            DropdownMenuItem(value: TransactionType.Income, child: Text(localizations.income)),
          ],
          onChanged: (v) => setState(() => _selectedType = v!),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _addToQueue,
            icon: const Icon(Icons.add),
            label: Text(localizations.addToQueue),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueue() {
    final localizations = AppLocalizations.of(context)!;
    if (_pendingTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              localizations.noTransactionsQueuedYet,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            localizations.queuedTransactions(_pendingTransactions.length.toString()),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pendingTransactions.length,
          itemBuilder: (context, index) {
            final t = _pendingTransactions[index];
            final account = _accountRepository.accounts.firstWhere(
              (a) => a.id == t.accountId,
              orElse: () => AccountModel.empty(0),
            );
            final isIncome = t.transactionType == TransactionType.Income;

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome ? Colors.green.shade800 : Colors.red.shade800,
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${account.name}  •  ${t.categoryName}  •  ${DateFormat('dd MMM yyyy').format(t.date)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'}${t.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _editQueuedTransaction(index),
                      tooltip: localizations.edit,
                      color: Colors.grey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _removeFromQueue(index),
                      tooltip: localizations.remove,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
