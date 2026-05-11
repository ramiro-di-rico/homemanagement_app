import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../services/endpoints/transaction.service.dart';
import '../../services/repositories/account.repository.dart';
import '../../services/repositories/category.repository.dart';

class BulkTransactionsScreen extends StatefulWidget {
  static const String fullPath = '/home_screen/bulk_transactions';
  static const String path = '/bulk_transactions';

  const BulkTransactionsScreen({super.key});

  @override
  State<BulkTransactionsScreen> createState() => _BulkTransactionsScreenState();
}

class _BulkTransactionsScreenState extends State<BulkTransactionsScreen> {
  final AccountRepository _accountRepository = GetIt.I<AccountRepository>();
  final CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  final TransactionService _transactionService = GetIt.I<TransactionService>();

  final List<TransactionModel> _pendingTransactions = [];

  // Form state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  AccountModel? _selectedAccount;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.Outcome;

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final accounts = _accountRepository.accounts;
    if (accounts.isNotEmpty) _selectedAccount = accounts.first;

    final categories = _categoryRepository.getActiveCategories();
    if (categories.isNotEmpty) _selectedCategory = categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addToQueue() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (_selectedAccount == null) {
      setState(() => _errorMessage = 'Please select an account.');
      return;
    }
    if (_selectedCategory == null) {
      setState(() => _errorMessage = 'Please select a category.');
      return;
    }
    if (name.length < 3) {
      setState(() => _errorMessage = 'Name must be at least 3 characters.');
      return;
    }
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      setState(() => _errorMessage = 'Enter a valid price.');
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

  Future<void> _submitAll() async {
    if (_pendingTransactions.isEmpty) {
      setState(() => _errorMessage = 'Add at least one transaction before submitting.');
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
        _successMessage = '${_pendingTransactions.length} transaction(s) submitted successfully.';
        _pendingTransactions.clear();
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to submit transactions: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Transactions'),
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
            label: const Text('Submit all'),
          ),
          if (_pendingTransactions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear queue',
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
                        child: const Text('Dismiss'),
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
                        child: const Text('Dismiss'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Add Transaction', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),

        // Account
        DropdownButtonFormField<AccountModel>(
          value: _selectedAccount,
          decoration: const InputDecoration(
            labelText: 'Account',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
          ),
          items: accounts
              .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
              .toList(),
          onChanged: (v) => setState(() => _selectedAccount = v),
        ),
        const SizedBox(height: 12),

        // Category
        DropdownButtonFormField<CategoryModel>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        ),
        const SizedBox(height: 12),

        // Name
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        const SizedBox(height: 12),

        // Price
        TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        const SizedBox(height: 12),

        // Date
        DateTimeField(
          format: DateFormat('dd MMM yyyy'),
          decoration: const InputDecoration(
            labelText: 'Date',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.date_range),
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
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.swap_vert),
          ),
          items: const [
            DropdownMenuItem(value: TransactionType.Outcome, child: Text('Outcome')),
            DropdownMenuItem(value: TransactionType.Income, child: Text('Income')),
          ],
          onChanged: (v) => setState(() => _selectedType = v!),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _addToQueue,
            icon: const Icon(Icons.add),
            label: const Text('Add to queue'),
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
    if (_pendingTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No transactions queued yet.\nFill in the form and press "Add to queue".',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
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
            'Queued (${_pendingTransactions.length})',
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
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _removeFromQueue(index),
                      tooltip: 'Remove',
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

