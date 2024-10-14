import 'package:flutter/widgets.dart';

import '../../models/recurring_transaction.dart';
import '../endpoints/recurring_transaction_service.dart';
import '../infra/error_notifier_service.dart';

class RecurringTransactionRepository extends ChangeNotifier {
  RecurringTransactionService _recurringTransactionService;
  NotifierService notifierService;
  final List<RecurringTransaction> recurringTransactions = [];
  bool loading = false;

  RecurringTransactionRepository(this._recurringTransactionService, this.notifierService);

  Future load() async {
    loading = true;
    notifyListeners();
    var result = await this._recurringTransactionService.getAll();
    this.recurringTransactions.clear();
    this.recurringTransactions.addAll(result);
    loading = false;
    notifyListeners();
  }

  Future add(RecurringTransaction recurringTransaction) async {
    try {
      loading = true;
      await this._recurringTransactionService.create(recurringTransaction);
      this.recurringTransactions.add(recurringTransaction);
      notifierService.notify('Recurring transaction added successfully');
      await load();
    } catch (ex) {
      print(ex);
      notifierService.notify('Failed to add recurring transaction');
    }
    finally {
      loading = false;
      notifyListeners();
    }
  }

  Future update(RecurringTransaction recurringTransaction) async {
    try {
      loading = true;
      await _recurringTransactionService.update(recurringTransaction);
      notifierService.notify('Recurring transaction updated successfully');
    } catch (ex) {
      notifierService.notify('Failed to update recurring transaction');
    }
    finally {
      loading = false;
      notifyListeners();
    }
  }

  Future delete(RecurringTransaction recurringTransaction) async {
    try {
      loading = true;
      await _recurringTransactionService.delete(recurringTransaction.id);
      recurringTransactions.remove(recurringTransaction);
      notifierService.notify('Recurring transaction deleted successfully');
    } catch (ex) {
      notifierService.notify('Failed to delete recurring transaction');
    }
    finally {
      loading = false;
      notifyListeners();
    }
  }
}