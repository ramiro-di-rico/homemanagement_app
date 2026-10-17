import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/services/account.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/transaction.dart';

class FakeAccountService implements AccountService {
  List<AccountModel> Function() onFetch;

  FakeAccountService(this.onFetch);

  @override
  Future<List<AccountModel>> fetchAccounts() async => onFetch();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AccountModel buildAccount(int id, double balance, {bool isHidden = false}) =>
    AccountModel(
      id,
      'Account $id',
      balance,
      false,
      AccountType.Cash,
      1,
      1,
      false,
      isHidden,
    );

void main() {
  late AccountRepository repository;
  late FakeAccountService service;

  setUp(() async {
    service = FakeAccountService(
      () => [buildAccount(1, 100), buildAccount(2, 50, isHidden: true)],
    );
    repository = AccountRepository(
      accountService: service,
      notifierService: NotifierService(),
    );
    await repository.load();
  });

  group('AccountRepository.getById', () {
    test('returns the repository instance that balance updates change', () {
      final account = repository.getById(1)!;

      repository.updateBalance(1, 30, TransactionType.Income);
      expect(repository.getById(1)!.balance, 130);
      expect(identical(repository.getById(1), account), isTrue);

      repository.updateBalance(1, 10, TransactionType.Outcome);
      expect(repository.getById(1)!.balance, 120);

      repository.revertBalance(1, 10, TransactionType.Outcome);
      expect(repository.getById(1)!.balance, 130);

      repository.setBalance(buildAccount(1, 999));
      expect(repository.getById(1)!.balance, 999);
    });

    test('returns null for an unknown id', () {
      expect(repository.getById(42), isNull);
    });

    test('finds a hidden account', () {
      expect(repository.getById(2), isNotNull);
      expect(repository.accounts.any((a) => a.id == 2), isFalse);
    });
  });

  group('AccountRepository reload', () {
    test(
      'getById returns the new instance after load replaces accounts',
      () async {
        final stale = repository.getById(1)!;
        service.onFetch = () => [
          buildAccount(1, 250),
          buildAccount(2, 50, isHidden: true),
        ];

        await repository.load();

        final fresh = repository.getById(1)!;
        expect(identical(fresh, stale), isFalse);
        expect(fresh.balance, 250);

        repository.updateBalance(1, 20, TransactionType.Outcome);
        expect(repository.getById(1)!.balance, 230);
        // The pre-reload instance no longer receives updates, which is why a
        // screen must resolve the account by id instead of keeping a copy.
        expect(stale.balance, 100);
      },
    );
  });
}
