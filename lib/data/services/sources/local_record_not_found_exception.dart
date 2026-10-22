/// An update was asked for a row that isn't there, for example one that was deleted
/// since it was loaded. Nothing was changed. Without it the update would "succeed"
/// and the screen would show a change that was never saved.
class LocalRecordNotFoundException implements Exception {
  final String what;
  final int id;

  LocalRecordNotFoundException(this.what, this.id);

  @override
  String toString() => 'LocalRecordNotFoundException($what $id)';
}
