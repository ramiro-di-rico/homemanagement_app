import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/data/repositories/user.repository.dart';
import 'package:home_management_app/data/services/identity_user_service.dart';
import 'package:home_management_app/ui/features/authentication/view_models/my_user_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Service implements IdentityUserService {
  int calls = 0;
  final user = MyUserViewModel.fromJson({'id': '1', 'email': 'a@b.com', 'username': 'a@b.com', 'language': 'en'});

  @override
  Future<MyUserViewModel> getUser() async {
    calls++;
    return user;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// `MyApp` listens to this repository, above everything. A notification sent while
/// a screen is being built, from its `initState`, is "setState() called during
/// build", so a call that changes nothing must not send one.
void main() {
  late _Service service;
  late IdentityUserRepository repository;
  late int notified;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = _Service();
    repository = IdentityUserRepository(service, UserRepository());
    notified = 0;
    repository.addListener(() => notified++);
  });

  test('the first call fetches the user and tells the listeners, once it has', () async {
    final pending = repository.getUser();
    expect(notified, 0, reason: 'nothing to tell yet');

    final user = await pending;

    expect(user, isNotNull);
    expect(service.calls, 1);
    expect(notified, 1);
  });

  test('a call that finds the user cached changes nothing, and sends nothing, not even synchronously',
      () async {
    await repository.getUser();
    notified = 0;

    final pending = repository.getUser();
    expect(notified, 0, reason: 'a synchronous notification here is the one that breaks initState');
    await pending;

    expect(service.calls, 1, reason: 'no second request');
    expect(notified, 0);
  });

  test('every later call still returns the same user', () async {
    final first = await repository.getUser();

    expect(identical(await repository.getUser(), first), isTrue);
  });
}
