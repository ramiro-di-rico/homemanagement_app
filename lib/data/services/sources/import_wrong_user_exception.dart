/// An import started for one email is being resumed by another user.
class ImportWrongUserException implements Exception {
  @override
  String toString() => 'ImportWrongUserException';
}
