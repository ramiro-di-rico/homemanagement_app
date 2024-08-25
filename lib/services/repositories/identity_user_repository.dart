
import '../../models/view-models/my_user_view_model.dart';
import '../endpoints/identity_user_service.dart';

class IdentityUserRepository{
  IdentityUserService _identityUserApi;
  late MyUserViewModel? _currentUser = null;

  IdentityUserRepository(this._identityUserApi);

  Future<MyUserViewModel?> getUser() async {
    _currentUser = _currentUser ?? await _identityUserApi.getUser();
    return _currentUser;
  }
}