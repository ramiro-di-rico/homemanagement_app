import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/models/reconciliation.dart';
import 'package:home_management_app/domain/models/transaction.dart';

/// A preview as the API returns it: expense rows carry transactionType 1, income 0.
Map<String, dynamic> previewJson() => {
      'accountId': 3,
      'periodStart': '2026-07-01T00:00:00Z',
      'periodEnd': '2026-07-31T00:00:00Z',
      'statementBalances': {
        'initialBalance': 27831.04,
        'credits': 2442863.41,
        'debits': -2356197.67,
        'finalBalance': 114496.78,
      },
      'matched': [
        {
          'row': rowJson('111', 'Pago con QR Coto', 1000.0, 1),
          'transactionId': 41,
          'matchKind': 1,
          'requiresReferenceLink': true,
        },
        {
          'row': rowJson('112', 'Rendimientos', 13.24, 0),
          'transactionId': 42,
          'matchKind': 0,
          'requiresReferenceLink': false,
        },
      ],
      'missing': [
        {
          'row': rowJson('222', 'Pago Sushimei', 9000.0, 1),
          'suggestedCategoryId': 7,
        },
        {
          'row': rowJson('223', 'Pago Un comercio nuevo', 500.0, 1),
          'suggestedCategoryId': null,
        },
      ],
      'extra': [
        {
          'id': 99,
          'accountId': 3,
          'categoryId': 1,
          'name': 'Duplicado',
          'price': 500.0,
          'date': '2026-07-15T00:00:00Z',
          'transactionType': 1,
          'categoryName': 'Food',
          'tags': [],
        },
      ],
      'ambiguous': [
        {
          'row': rowJson('333', 'Pago Coto', 2000.0, 1),
          'candidateTransactionIds': [51, 52],
          'suggestedCategoryId': 7,
        },
      ],
    };

Map<String, dynamic> rowJson(
        String reference, String name, double price, int type) =>
    {
      'reference': reference,
      'name': name,
      'price': price,
      'date': '2026-07-15T00:00:00Z',
      'transactionType': type,
    };

void main() {
  group('ReconciliationPreviewModel', () {
    test('fromJson reads every classification list', () {
      final preview = ReconciliationPreviewModel.fromJson(previewJson());

      expect(preview.accountId, 3);
      expect(preview.matched.length, 2);
      expect(preview.missing.length, 2);
      expect(preview.extra.length, 1);
      expect(preview.ambiguous.length, 1);
      expect(preview.periodStart, DateTime.parse('2026-07-01T00:00:00Z'));
      expect(preview.periodEnd, DateTime.parse('2026-07-31T00:00:00Z'));
      expect(preview.statementBalances!.finalBalance, 114496.78);
    });

    test('fromJson maps the amount sign back to a transaction type', () {
      final preview = ReconciliationPreviewModel.fromJson(previewJson());

      expect(preview.matched[0].row.transactionType, TransactionType.Outcome);
      expect(preview.matched[1].row.transactionType, TransactionType.Income);
      expect(preview.matched[1].row.isIncome(), isTrue);
    });

    test('fromJson maps the match kind', () {
      final preview = ReconciliationPreviewModel.fromJson(previewJson());

      expect(preview.matched[0].matchKind, MatchKind.exactDate);
      expect(preview.matched[0].requiresReferenceLink, isTrue);
      expect(preview.matched[1].matchKind, MatchKind.reference);
      expect(preview.matched[1].requiresReferenceLink, isFalse);
    });

    test('fromJson keeps a missing row without suggestion as null', () {
      final preview = ReconciliationPreviewModel.fromJson(previewJson());

      expect(preview.missing[0].suggestedCategoryId, 7);
      expect(preview.missing[1].suggestedCategoryId, isNull);
    });

    test('fromJson reads extra transactions as regular transactions', () {
      final preview = ReconciliationPreviewModel.fromJson(previewJson());

      expect(preview.extra.first.id, 99);
      expect(preview.extra.first.name, 'Duplicado');
      expect(preview.extra.first.price, 500.0);
    });

    test('fromJson reads the candidates of an ambiguous row', () {
      final preview = ReconciliationPreviewModel.fromJson(previewJson());

      expect(preview.ambiguous.first.candidateTransactionIds, [51, 52]);
    });

    test('counts what is left to reconcile', () {
      final preview = ReconciliationPreviewModel.fromJson(previewJson());

      expect(preview.pendingCount, 4);
      expect(preview.isFullyReconciled, isFalse);
    });

    test('a statement with nothing pending is fully reconciled', () {
      final json = previewJson()
        ..['missing'] = []
        ..['extra'] = []
        ..['ambiguous'] = [];

      final preview = ReconciliationPreviewModel.fromJson(json);

      expect(preview.isFullyReconciled, isTrue);
      expect(preview.pendingCount, 0);
    });

    test('fromJson tolerates missing lists and balances', () {
      final preview = ReconciliationPreviewModel.fromJson({
        'accountId': 3,
        'periodStart': null,
        'periodEnd': null,
        'statementBalances': null,
      });

      expect(preview.matched, isEmpty);
      expect(preview.missing, isEmpty);
      expect(preview.extra, isEmpty);
      expect(preview.ambiguous, isEmpty);
      expect(preview.statementBalances, isNull);
      expect(preview.isFullyReconciled, isTrue);
    });
  });

  group('ReconciliationTransactionToCreate', () {
    test('fromRow carries the bank reference so the next run matches by it', () {
      final preview = ReconciliationPreviewModel.fromJson(previewJson());

      final toCreate = ReconciliationTransactionToCreate.fromRow(
          preview.missing.first.row, 7);

      expect(toCreate.externalReference, '222');
      expect(toCreate.name, 'Pago Sushimei');
      expect(toCreate.price, 9000.0);
      expect(toCreate.categoryId, 7);
    });

    test('toJson serializes the transaction type the way the API expects', () {
      final expense = ReconciliationTransactionToCreate(
        name: 'Pago Sushimei',
        price: 9000,
        date: DateTime.utc(2026, 7, 16),
        transactionType: TransactionType.Outcome,
        categoryId: 7,
        externalReference: '222',
      );

      final income = ReconciliationTransactionToCreate(
        name: 'Rendimientos',
        price: 13.24,
        date: DateTime.utc(2026, 7, 16),
        transactionType: TransactionType.Income,
        categoryId: 7,
      );

      expect(expense.toJson()['transactionType'], 1);
      expect(income.toJson()['transactionType'], 0);
      expect(income.toJson()['externalReference'], isNull);
    });
  });

  group('ApplyReconciliationResultModel', () {
    test('fromJson reads the counters and the balance check', () {
      final result = ApplyReconciliationResultModel.fromJson({
        'createdCount': 3,
        'deletedCount': 1,
        'linkedCount': 68,
        'balanceCheck': {
          'expected': 114496.78,
          'actual': 114496.78,
          'difference': 0.0,
          'matches': true,
        },
      });

      expect(result.createdCount, 3);
      expect(result.deletedCount, 1);
      expect(result.linkedCount, 68);
      expect(result.changedCount, 4);
      expect(result.balanceCheck!.matches, isTrue);
    });

    test('fromJson tolerates an apply without balance check', () {
      final result = ApplyReconciliationResultModel.fromJson({
        'createdCount': 0,
        'deletedCount': 1,
        'linkedCount': 0,
        'balanceCheck': null,
      });

      expect(result.balanceCheck, isNull);
      expect(result.changedCount, 1);
    });
  });

  group('StatementFormat', () {
    test('exposes the name the API binds to', () {
      expect(StatementFormat.accountStatementCsv.apiName, 'AccountStatementCsv');
    });
  });
}
