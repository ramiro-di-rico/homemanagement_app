/// An import started for one email is being resumed by another user.
class ImportWrongUserException implements Exception {
  /// The email the import was started for.
  final String expectedEmail;

  ImportWrongUserException(this.expectedEmail);

  @override
  String toString() => 'ImportWrongUserException: $expectedEmail';
}
